#include <QApplication>
#include <QDeclarativeView>
#include <QLocale>
#include <QTranslator>

#include "sailfishapplication.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QTranslator> engineeringEnglish(new QTranslator);
    engineeringEnglish->load("notes_eng_en", TRANSLATIONS_PATH);
    QScopedPointer<QTranslator> translator(new QTranslator);
    translator->load(QLocale(), "notes", "-", TRANSLATIONS_PATH);

    QScopedPointer<QApplication> app(Sailfish::createApplication(argc, argv));
    app->installTranslator(engineeringEnglish.data());
    app->installTranslator(translator.data());

    QScopedPointer<QDeclarativeView> view(Sailfish::createView("Notes.qml"));
    Sailfish::showView(view.data());
    
    int result = app->exec();
    app->removeTranslator(translator.data());
    app->removeTranslator(engineeringEnglish.data());
    return result;
}


