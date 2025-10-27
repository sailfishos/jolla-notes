// SPDX-FileCopyrightText: 2025 Damien Caliste
//
// SPDX-License-Identifier: BSD-3-Clause

#ifndef CALENDARJOURNALS_H
#define CALENDARJOURNALS_H

#include <QObject>
#include <QThread>
#include <QMap>

#include <KCalendarCore/Journal>
#include <extendedstorage.h>
#include <extendedstorageobserver.h>
#include <Accounts/Manager>

class CalendarJournal
{
    Q_GADGET
    Q_PROPERTY(QString uid READ uid)
    Q_PROPERTY(QString title READ title)
    Q_PROPERTY(QString body READ body)
    Q_PROPERTY(QString color READ color)
    Q_PROPERTY(QDateTime dateTime READ dateTime)

public:
    CalendarJournal() {}
    CalendarJournal(KCalendarCore::Journal::Ptr journal)
        : mJournal(journal) {}
    ~CalendarJournal() {}

    QString uid() const
    {
        return mJournal ? mJournal->uid() : QString();
    }

    QString title() const
    {
        return mJournal ? mJournal->summary() : QString();
    }

    QString body() const
    {
        return mJournal ? mJournal->description() : QString();
    }

    QString color() const
    {
        return mJournal ? mJournal->color() : QString();
    }

    QDateTime dateTime() const
    {
        return mJournal ? mJournal->dtStart() : QDateTime();
    }

private:
    KCalendarCore::Journal::Ptr mJournal;
};
Q_DECLARE_METATYPE(CalendarJournal)

class CalendarSource
{
    Q_GADGET
    Q_PROPERTY(QString label READ label)
    Q_PROPERTY(QString description READ description)
    Q_PROPERTY(QString icon READ icon)
    Q_PROPERTY(QString uid READ uid)

public:
    CalendarSource() {}
    CalendarSource(mKCal::Notebook::Ptr notebook)
        : mNotebook(notebook) {}
    ~CalendarSource() {}

    QString label() const
    {
        return mNotebook ? mNotebook->name() : QString();
    }

    QString description() const
    {
        return mNotebook ? mNotebook->description() : QString();
    }

    QString icon() const
    {
        return mNotebook ? mNotebook->customProperty("accountIcon") : QString();
    }

    QString uid() const
    {
        return mNotebook ? mNotebook->uid() : QString();
    }

private:
    mKCal::Notebook::Ptr mNotebook;
};
Q_DECLARE_METATYPE(CalendarSource)

class Worker : public QObject, public mKCal::ExtendedStorageObserver
{
    Q_OBJECT

public:
    Worker(QObject *parent = nullptr);
    ~Worker();

    void storageModified(mKCal::ExtendedStorage *storage, const QString &info);
    void storageUpdated(mKCal::ExtendedStorage *storage,
                        const KCalendarCore::Incidence::List &added,
                        const KCalendarCore::Incidence::List &modified,
                        const KCalendarCore::Incidence::List &deleted);

public slots:
    void open(const QString &databasePath);
    void listNotebooks();
    void reload(const QString &notebookUid);
    void add(KCalendarCore::Journal *journal);
    void update(KCalendarCore::Journal *journal);
    void remove(const QString &uid);

signals:
    void notebookList(mKCal::Notebook::List notebooks);
    void loaded(KCalendarCore::Journal::List journals);

 private:
    Accounts::Manager *mAccountManager = nullptr;
    mKCal::ExtendedStorage::Ptr mStorage;
    QString mNotebookUid;
};

class CalendarJournals : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString databasePath READ databasePath WRITE setDatabasePath NOTIFY databasePathChanged)
    Q_PROPERTY(bool ready READ ready NOTIFY readyChanged)
    Q_PROPERTY(QVariantList notebooks READ notebooks NOTIFY notebooksChanged)
    Q_PROPERTY(QString notebookUid READ notebookUid WRITE setNotebookUid NOTIFY notebookUidChanged)

public:
    CalendarJournals(QObject *parent = nullptr);
    ~CalendarJournals();

    QString databasePath() const;
    void setDatabasePath(const QString &path);

    bool ready() const;

    QString notebookUid() const;
    void setNotebookUid(const QString &uid);

    QVariantList notebooks() const;

    Q_INVOKABLE QStringList listJournalUids(const QString &filter = QString()) const;
    Q_INVOKABLE QVariant journal(const QString &uid) const;

    Q_INVOKABLE QVariant add(const QString &body, const QString &color);
    Q_INVOKABLE void updateBody(const QString &uid, const QString &body);
    Q_INVOKABLE void updateColorString(const QString &uid, const QString &color);
    Q_INVOKABLE void updateTimeStamp(const QString &uid);
    Q_INVOKABLE void remove(const QString &uid);

signals:
    void databasePathChanged();
    void readyChanged();
    void notebookUidChanged();
    void notebooksChanged();
    void modified();

private:
    void onNotebookListed(mKCal::Notebook::List notebooks);
    void onJournalLoaded(KCalendarCore::Journal::List journals);

    bool mReady = false;
    QString mDatabasePath;
    QString mNotebookUid;
    mKCal::Notebook::List mNotebooks;
    KCalendarCore::Journal::List mJournals;
    QMap<QString, KCalendarCore::Journal::Ptr> mJournalsByUid;
    QThread mWorkerThread;
    Worker mWorker;
};

#endif
