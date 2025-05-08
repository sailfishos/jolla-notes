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
#include <QTextCodec>
#include <QTextStream>
#include <QDebug>

#include <unicode/ucsdet.h>

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

    retn += "DCREATED:" + QLocale::c().toString(cdate, "yyyyMMddThhmmssZ").toUtf8() + "\r\n";
    retn += "LAST-MODIFIED:" + QLocale::c().toString(mdate, "yyyyMMddThhmmssZ").toUtf8() + "\r\n";

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
    QString copy(vnoteText);
    QTextStream stream(&copy, QIODevice::ReadOnly);
    return plainTextNotes(stream);
}

QStringList VNoteConverter::plainTextNotes(QTextStream &stream) const
{
    QStringList retn;
    while (!stream.atEnd()) {
        const QString line = stream.readLine().trimmed();
        if ((line.startsWith("BODY;", Qt::CaseInsensitive)
                || line.startsWith("BODY:", Qt::CaseInsensitive))
                && line.contains(':')) {
            retn << line.mid(line.indexOf(':') + 1);
        }
    }
    return retn;
}

static QTextCodec *detectCodec(const char *encodedCharacters, int length)
{
    QTextCodec *codec = QTextCodec::codecForLocale();

    UErrorCode error = U_ZERO_ERROR;
    if (UCharsetDetector * const detector = ucsdet_open(&error)) {
        ucsdet_setText(detector, encodedCharacters, length, &error);


        int32_t count = 0;
        if (U_FAILURE(error)) {
            qWarning() << "Unable to detect text encoding" << u_errorName(error);
        } else if (const UCharsetMatch ** const matches = ucsdet_detectAll(detector, &count, &error)) {
            QTextCodec *bestMatch = nullptr;
            int32_t bestConfidence = 0;

            for (int32_t i = 0; i < count; ++i) {
                if (QTextCodec *detectedCodec = QTextCodec::codecForName(ucsdet_getName(matches[i], &error))) {
                    const int32_t confidence = ucsdet_getConfidence(matches[i], &error);

                    // Pick the first match, unless the system locale has equal confidence
                    // in which case prefer that.
                    if (!bestMatch || (confidence == bestConfidence && detectedCodec == codec)) {
                        bestMatch = detectedCodec;
                        bestConfidence = confidence;
                    }
                }
            }

            if (bestMatch) {
                codec = bestMatch;
            }
        } else {
            qWarning() << "Unable to detect text encoding" << u_errorName(error);
        }
        ucsdet_close(detector);
    } else {
        qWarning() << "Unable to detect text encoding" << u_errorName(error);
    }

    return codec;
}

QStringList VNoteConverter::importFromFile(const QUrl &filePath) const
{
    if (!filePath.isLocalFile()) {
        return QStringList();
    }

    QStringList notes;

    const QString filename = filePath.toLocalFile();
    QFile textFile(filename);
    if (!textFile.exists() || textFile.size() < 0 || textFile.size() > INT_MAX) {
        // Basic sanity checks to guard against integer overflow.  Realistically the maximum
        // supported file size is much much smaller but we should never reach the point of opening
        // such files.
    } else if (textFile.open(QIODevice::ReadOnly)) {
        const bool isVnt = filename.endsWith(QLatin1String(".vnt"), Qt::CaseInsensitive);
        if (textFile.size() == 0) {
            if (!isVnt) {
                notes.append(QString());
            }
        } else if (uchar * const data = textFile.map(0, textFile.size())) {
            const char * const encodedCharacters = reinterpret_cast<char *>(data);

            QTextStream stream(
                        QByteArray::fromRawData(encodedCharacters, textFile.size()),
                        QIODevice::ReadOnly);
            stream.setCodec(detectCodec(encodedCharacters, textFile.size()));

            if (isVnt) {
                notes = plainTextNotes(stream);
            } else {
                notes.append(stream.readAll());
            }

            textFile.unmap(data);
        }
        textFile.close();
    }

    return notes;
}

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QTranslator> engineeringEnglish(new QTranslator);
    engineeringEnglish->load("notes_eng_en", TRANSLATIONS_PATH);
    QScopedPointer<QTranslator> translator(new QTranslator);
    translator->load(QLocale(), "notes", "-", TRANSLATIONS_PATH);

    QScopedPointer<QGuiApplication> app(Sailfish::createApplication(argc, argv));
    app->setOrganizationName(QStringLiteral("com.jolla"));
    app->setApplicationName(QStringLiteral("notes"));
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
    Sailfish::setSource(view.data(), "notes.qml");
    if (!app->arguments().contains("-prestart")) {
        Sailfish::showView(view.data());
    }
    
    int result = app->exec();
    app->removeTranslator(translator.data());
    app->removeTranslator(engineeringEnglish.data());
    return result;
}
