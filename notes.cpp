#include <QGuiApplication>
#include <QQuickView>
#include <QQmlEngine>
#include <QQmlContext>
#include <QStandardPaths>
#include <QDir>
#include <QLocale>
#include <QTranslator>

#include "vnote.h"
#include "sailfishapplication.h"

VNoteConverter::VNoteConverter(QObject *parent)
    : QObject(parent)
{
}

QString VNoteConverter::vNote(const QString &noteText,
                              const QDateTime &createdDate,
                              const QDateTime &modifiedDate) const
{
    QString vnoteTemplate = QString::fromLatin1(
        "BEGIN:VNOTE\r\n"
        "VERSION:1.1\r\n"
        "DCREATED:%1\r\n"
        "LAST-MODIFIED:%2\r\n"
        "BODY;CHARSET=UTF-8;ENCODING=BASE64:%3\r\n"
        "END:VNOTE\r\n\r\n");

    QDateTime currentDateTime = QDateTime::currentDateTime();
    QString isoDateCreated = createdDate.isValid() ?
                             createdDate.toString(Qt::ISODate) :
                             currentDateTime.toString(Qt::ISODate);
    QString isoDateModified = modifiedDate.isValid() ?
                              modifiedDate.toString(Qt::ISODate) :
                              currentDateTime.toString(Qt::ISODate);

    return vnoteTemplate
            .arg(isoDateCreated)
            .arg(isoDateModified)
            .arg(QString::fromLatin1(noteText.toUtf8().toBase64()));
}

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QTranslator> engineeringEnglish(new QTranslator);
    engineeringEnglish->load("notes_eng_en", TRANSLATIONS_PATH);
    QScopedPointer<QTranslator> translator(new QTranslator);
    translator->load(QLocale(), "notes", "-", TRANSLATIONS_PATH);

    QScopedPointer<QGuiApplication> app(Sailfish::createApplication(argc, argv));
    app->setApplicationName("jolla-notes");
    app->installTranslator(engineeringEnglish.data());
    app->installTranslator(translator.data());

    QScopedPointer<QQuickView> view(Sailfish::createView());
    view->setTitle(qtTrId("notes-de-name"));
    // Set the offlineStoragePath explicitly in case we are boosted
    QString dataLocation = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    dataLocation += QDir::separator() + QLatin1String("QML")
                    + QDir::separator() + QLatin1String("OfflineStorage");
    view->engine()->setOfflineStoragePath(dataLocation);
    Sailfish::setSource(view.data(), "Notes.qml");
    view->engine()->rootContext()->setContextProperty("vnoteConverter", new VNoteConverter(view->engine()));
    Sailfish::showView(view.data());
    
    int result = app->exec();
    app->removeTranslator(translator.data());
    app->removeTranslator(engineeringEnglish.data());
    return result;
}


