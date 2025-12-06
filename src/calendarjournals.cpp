// SPDX-FileCopyrightText: 2025 Damien Caliste
//
// SPDX-License-Identifier: BSD-3-Clause

#include "calendarjournals.h"

#include <Accounts/Account>
#include <extendedcalendar.h>
#include <sqlitestorage.h>

#include <QDebug>

namespace {
    const QByteArray APP = QByteArrayLiteral("VOLATILE");
    const QByteArray TIMESTAMP = QByteArrayLiteral("TIME-STAMP");
    const QByteArray FAVORITE = QByteArrayLiteral("FAVORITE");

    QDateTime timeStamp(const KCalendarCore::Incidence &incidence)
    {
        return QDateTime::fromString(incidence.customProperty(APP, TIMESTAMP), Qt::ISODate);
    }

    void setTimeStamp(KCalendarCore::Incidence::Ptr incidence, const QDateTime &stamp)
    {
        incidence->setCustomProperty(APP, TIMESTAMP, stamp.toString(Qt::ISODate));
    }
}

Worker::Worker(QObject *parent)
    : QObject(parent)
{
}

Worker::~Worker()
{
    if (mStorage) {
        mStorage->unregisterObserver(this);
        mStorage->close();
    }
}

void Worker::open(const QString &databasePath)
{
    mKCal::ExtendedCalendar::Ptr calendar(new mKCal::ExtendedCalendar(QTimeZone::utc()));
    if (databasePath.isEmpty()) {
        mStorage = calendar->defaultStorage(calendar);
    } else {
        mStorage = mKCal::ExtendedStorage::Ptr(new mKCal::SqliteStorage(calendar, databasePath));
    }
    mStorage->open();
    mStorage->registerObserver(this);

    listNotebooks();
}

void Worker::listNotebooks()
{
    mKCal::Notebook::List notebooks;
    for (const mKCal::Notebook::Ptr &notebook : mStorage->notebooks()) {
        if (notebook->journalsAllowed()
            && !notebook->account().isEmpty()
            && !notebook->isReadOnly()) {
            mKCal::Notebook::Ptr nb(new mKCal::Notebook(*notebook));
            if (nb->description().isEmpty() && !nb->account().isEmpty()) {
                if (!mAccountManager) {
                    mAccountManager = new Accounts::Manager(this);
                }
                bool ok = false;
                int accountId = nb->account().toInt(&ok);
                if (ok && accountId > 0) {
                    Accounts::Account *account = Accounts::Account::fromId(mAccountManager, accountId);
                    if (account) {
                        nb->setCustomProperty("accountIcon", mAccountManager->provider(account->providerName()).iconName());
                        nb->setDescription(account->displayName());
                    }
                    delete account;
                }
            }
            notebooks << nb;
        }
    }
    emit notebookList(notebooks);
}

void Worker::reload(const QString &notebookUid)
{
    KCalendarCore::Incidence::List incidences;
    if (!mStorage->allIncidences(&incidences, notebookUid)) {
        qWarning() << "cannot load all incidences from notebook" << notebookUid;
    }
    KCalendarCore::Journal::List journals;
    for (const KCalendarCore::Incidence::Ptr &incidence : incidences) {
        if (incidence->type() == KCalendarCore::IncidenceBase::TypeJournal)
            journals << incidence.staticCast<KCalendarCore::Journal>();
    }
    std::sort(journals.begin(), journals.end(),
              [] (const KCalendarCore::Journal::Ptr &a,
                  const KCalendarCore::Journal::Ptr &b) {
                  const QString favA = a->customProperty(APP, FAVORITE);
                  const QString favB = b->customProperty(APP, FAVORITE);
                  bool aIsFavorite = !favA.isEmpty() && favB.isEmpty();
                  bool bIsFavorite = !favB.isEmpty() && favA.isEmpty();
                  // Reverse sorting, last modified first.
                  return aIsFavorite
                      || (!bIsFavorite && (timeStamp(*a) > timeStamp(*b)));
              });
    mNotebookUid = notebookUid;
    emit loaded(journals);
}

void Worker::add(KCalendarCore::Journal *journal)
{
    // Taking ownership here.
    KCalendarCore::Journal::Ptr data(journal);

    if (!mStorage->calendar()->addJournal(data)
        || !mStorage->calendar()->setNotebook(data, mNotebookUid)
        || !mStorage->save()) {
        qWarning() << "cannot save new journal to notebook" << mNotebookUid;
    }
}

void Worker::update(KCalendarCore::Journal *journal)
{
    if (!mStorage->load(journal->uid())) {
        qWarning() << "cannot find journal from notebook" << mNotebookUid;
        add(journal);
    } else {
        KCalendarCore::Journal::Ptr old = mStorage->calendar()->journal(journal->uid());
        if (old) {
            old->startUpdates();
            *old.staticCast<KCalendarCore::IncidenceBase>() = *static_cast<KCalendarCore::IncidenceBase*>(journal);
            old->endUpdates();

            delete journal;
            if (!mStorage->save()) {
                qWarning() << "cannot update journal from notebook" << mNotebookUid;
            }
        }
    }
}

void Worker::remove(const QString &uid)
{
    if (mStorage->load(uid)) {
        KCalendarCore::Journal::Ptr old = mStorage->calendar()->journal(uid);
        if (old) {
            if (!mStorage->calendar()->deleteJournal(old)
                || !mStorage->save()) {
                qWarning() << "cannot delete journal from notebook" << mNotebookUid;
            }
        }
    }
}

void Worker::storageModified(mKCal::ExtendedStorage *storage, const QString &info)
{
    Q_UNUSED(storage);
    Q_UNUSED(info);

    listNotebooks();
    reload(mNotebookUid);
}

void Worker::storageUpdated(mKCal::ExtendedStorage *storage,
                            const KCalendarCore::Incidence::List &added,
                            const KCalendarCore::Incidence::List &modified,
                            const KCalendarCore::Incidence::List &deleted)
{
    Q_UNUSED(storage);
    Q_UNUSED(added);
    Q_UNUSED(modified);
    Q_UNUSED(deleted);

    // We're responsible for the modification, do nothing, already handled.
}

Q_DECLARE_METATYPE(KCalendarCore::Journal::List)
Q_DECLARE_METATYPE(mKCal::Notebook::List)
CalendarJournals::CalendarJournals(QObject *parent)
    : QObject(parent)
{
    qRegisterMetaType<KCalendarCore::Journal::List>();
    qRegisterMetaType<KCalendarCore::Journal*>();
    qRegisterMetaType<mKCal::Notebook::List>();

    mWorker.moveToThread(&mWorkerThread);
    connect(&mWorker, &Worker::notebookList, this, &CalendarJournals::onNotebookListed);
    connect(&mWorker, &Worker::loaded, this, &CalendarJournals::onJournalLoaded);

    mWorkerThread.setObjectName("mKCal worker");
    mWorkerThread.start();
}

CalendarJournals::~CalendarJournals()
{
    mWorkerThread.quit();
    mWorkerThread.wait();
}

bool CalendarJournals::ready() const
{
    return mReady;
}

QString CalendarJournals::databasePath() const
{
    return mDatabasePath;
}

void CalendarJournals::setDatabasePath(const QString &path)
{
    if (path == mDatabasePath)
        return;

    mDatabasePath = path;
    emit databasePathChanged();

    QMetaObject::invokeMethod(&mWorker, "open", Qt::QueuedConnection,
                              Q_ARG(QString, path));
}

QVariantList CalendarJournals::notebooks() const
{
    QVariantList sources;
    for (const mKCal::Notebook::Ptr &notebook : mNotebooks) {
        sources << QVariant::fromValue(CalendarSource(notebook));
    }
    return sources;
}

QString CalendarJournals::notebookUid() const
{
    return mNotebookUid;
}

void CalendarJournals::setNotebookUid(const QString &uid)
{
    if (uid == mNotebookUid)
        return;

    mNotebookUid = uid;
    emit notebookUidChanged();

    if (mReady) {
        mReady = false;
        emit readyChanged();
    }

    QMetaObject::invokeMethod(&mWorker, "reload", Qt::QueuedConnection,
                              Q_ARG(QString, mNotebookUid));
}

QStringList CalendarJournals::listJournalUids(const QString &filter) const
{
    QStringList uids;
    for (const KCalendarCore::Journal::Ptr &journal : mJournals) {
        if (filter.isEmpty() || journal->description().contains(filter)) {
            uids.append(journal->uid());
        }
    }
    return uids;
}

QVariant CalendarJournals::journal(const QString &uid) const
{
    return QVariant::fromValue(CalendarJournal(mJournalsByUid.value(uid)));
}

void CalendarJournals::onNotebookListed(mKCal::Notebook::List notebooks)
{
    mNotebooks = notebooks;
    emit notebooksChanged();

    if (notebooks.count() == 1) {
        setNotebookUid(notebooks.first()->uid());
    }
}

void CalendarJournals::onJournalLoaded(KCalendarCore::Journal::List journals)
{
    mJournals.clear();
    mJournalsByUid.clear();
    for (const KCalendarCore::Journal::Ptr &journal : journals) {
        mJournals << journal;
        mJournalsByUid.insert(journal->uid(), journal);
    }

    if (!mReady) {
        mReady = true;
        emit readyChanged();
    }

    emit modified();
}

QVariant CalendarJournals::add(const QString &body, const QString &color)
{
    KCalendarCore::Journal::Ptr item(new KCalendarCore::Journal);
    item->setDescription(body);
    item->setColor(color);
    item->setDtStart(QDateTime::currentDateTimeUtc());
    setTimeStamp(item, QDateTime::currentDateTimeUtc());

    mJournals.prepend(item);
    mJournalsByUid.insert(item->uid(), item);

    // The worker will take ownership of the clone.
    QMetaObject::invokeMethod(&mWorker, "add", Qt::QueuedConnection,
                              Q_ARG(KCalendarCore::Journal*, item->clone()));

    return journal(item->uid());
}

void CalendarJournals::updateBody(const QString &uid, const QString &body)
{
    KCalendarCore::Journal::Ptr journal(mJournalsByUid.value(uid));
    if (!journal) {
        qWarning() << "no journal with uid" << uid;
        return;
    }

    journal->setDescription(body);

    // The worker will take ownership of the clone.
    QMetaObject::invokeMethod(&mWorker, "update", Qt::QueuedConnection,
                              Q_ARG(KCalendarCore::Journal*, journal->clone()));
}

void CalendarJournals::updateColorString(const QString &uid, const QString &color)
{
    KCalendarCore::Journal::Ptr journal(mJournalsByUid.value(uid));
    if (!journal) {
        qWarning() << "no journal with uid" << uid;
        return;
    }

    journal->setColor(color);

    // The worker will take ownership of the clone.
    QMetaObject::invokeMethod(&mWorker, "update", Qt::QueuedConnection,
                              Q_ARG(KCalendarCore::Journal*, journal->clone()));
}

void CalendarJournals::updateTimeStamp(const QString &uid)
{
    KCalendarCore::Journal::Ptr journal(mJournalsByUid.value(uid));
    if (!journal) {
        qWarning() << "no journal with uid" << uid;
        return;
    }
    
    setTimeStamp(journal, QDateTime::currentDateTimeUtc());
    journal->setCustomProperty(APP, FAVORITE, QStringLiteral("true"));

    // The worker will take ownership of the clone.
    QMetaObject::invokeMethod(&mWorker, "update", Qt::QueuedConnection,
                              Q_ARG(KCalendarCore::Journal*, journal->clone()));

    // Need to reorder the list, journal will be first now.
    mJournals.removeOne(journal);
    mJournals.prepend(journal);
}

void CalendarJournals::remove(const QString &uid)
{
    KCalendarCore::Journal::Ptr journal = mJournalsByUid.take(uid);
    mJournals.removeOne(journal);
    
    QMetaObject::invokeMethod(&mWorker, "remove", Qt::QueuedConnection,
                              Q_ARG(QString, uid));
}
