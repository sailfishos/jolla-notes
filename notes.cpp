#include <QGuiApplication>
#include <QQuickView>
#include <QQmlEngine>
#include <QQmlContext>
#include <QStandardPaths>
#include <QDir>
#include <QLocale>
#include <QTranslator>
#include <QStringList>
#include <QFile>

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
    QByteArray retn;
    retn += "BEGIN:VNOTE\r\n";
    retn += "VERSION:1.1\r\n";

    // ensure we have valid UTC timestamps
    QDateTime cdate(createdDate.isValid()
                    ? (createdDate.timeSpec() == Qt::UTC
                        ? createdDate
                        : createdDate.toUTC())
                    : QDateTime::currentDateTimeUtc());
    QDateTime mdate(modifiedDate.isValid()
                    ? (modifiedDate.timeSpec() == Qt::UTC
                        ? modifiedDate
                        : modifiedDate.toUTC())
                    : QDateTime::currentDateTimeUtc());

    retn += "DCREATED:" + cdate.toString("yyyyMMddThhmmssZ").toUtf8() + "\r\n";
    retn += "LAST-MODIFIED:" + mdate.toString("yyyyMMddThhmmssZ").toUtf8() + "\r\n";

    // check for non-ascii characters to determine encoding
    bool ascii = true;
    for (int i = 0; i < noteText.size(); ++i) {
        if (noteText.at(i).unicode() > 127) {
            ascii = false;
            break;
        }
    }

    // the spec says that the body can contain:
    // <default-char-not-lf>*
    QString bodyText(noteText);
    bodyText.replace(QChar(QChar::LineFeed), QChar(QChar::CarriageReturn));

    retn += "BODY";
    if (!ascii) {
        retn += ";CHARSET=UTF-8;ENCODING=8BIT";
    }
    retn += ":";
    retn += bodyText.toUtf8(); // ascii is a subset of UTF-8, so this will work for both.
    retn += "\r\n";

    retn += "END:VNOTE\r\n\r\n";

    return QString::fromUtf8(retn);
}

QStringList VNoteConverter::plainTextNotes(const QString &vnoteText) const
{
    QStringList retn;
    QStringList lines = vnoteText.split("\r\n", QString::SkipEmptyParts);
    Q_FOREACH (const QString &line, lines) {
        const QString trimmedLine = line.trimmed();
        if ((trimmedLine.startsWith("BODY;", Qt::CaseInsensitive)
                || trimmedLine.startsWith("BODY:", Qt::CaseInsensitive))
                && trimmedLine.contains(':')) {
            retn << trimmedLine.mid(line.indexOf(':') + 1);
        }
    }
    return retn;
}

QStringList VNoteConverter::importFromFile(const QUrl &filePath) const
{
    if (!filePath.isLocalFile()) {
        return QStringList();
    }
    QString filename = filePath.toLocalFile();
    if (QFile::exists(filename)) {
        QFile textFile(filename);
        if (textFile.open(QIODevice::ReadOnly)) {
            QString fileData = QString::fromUtf8(textFile.readAll());
            if (filename.endsWith(".vnt", Qt::CaseInsensitive)) {
                return plainTextNotes(fileData);
            }
            return QStringList() << fileData;
        }
    }
    return QStringList();
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
    //: Application name in desktop file
    //% "Notes"
    view->setTitle(qtTrId("notes-de-name"));
    // Set the offlineStoragePath explicitly in case we are boosted
    QString dataLocation = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    dataLocation += QDir::separator() + QLatin1String("QML")
                  + QDir::separator() + QLatin1String("OfflineStorage");
    view->engine()->setOfflineStoragePath(dataLocation);
    view->engine()->rootContext()->setContextProperty("vnoteConverter", new VNoteConverter(view->engine()));
    Sailfish::setSource(view.data(), "Notes.qml");
    Sailfish::showView(view.data());
    
    int result = app->exec();
    app->removeTranslator(translator.data());
    app->removeTranslator(engineeringEnglish.data());
    return result;
}


