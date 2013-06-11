#include <QGuiApplication>
#include <QQuickView>
#include <QQmlEngine>
#include <QStandardPaths>
#include <QDir>
#include <QLocale>
#include <QTranslator>

#include "sailfishapplication.h"

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
    // Set the offlineStoragePath explicitly in case we are boosted
    QString dataLocation = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    dataLocation += QDir::separator() + QLatin1String("QML")
                    + QDir::separator() + QLatin1String("OfflineStorage");
    view->engine()->setOfflineStoragePath(dataLocation);
    Sailfish::setSource(view.data(), "Notes.qml");
    Sailfish::showView(view.data());
    
    int result = app->exec();
    app->removeTranslator(translator.data());
    app->removeTranslator(engineeringEnglish.data());
    return result;
}


