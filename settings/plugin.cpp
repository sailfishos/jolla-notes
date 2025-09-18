// SPDX-FileCopyrightText: 2015 Jolla Ltd.
// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

#include <QQmlExtensionPlugin>
#include <QQmlEngine>
#include <QtQml>
#include <QTranslator>

// using custom translator so it gets properly removed from qApp when engine is deleted
class AppTranslator: public QTranslator
{
    Q_OBJECT
public:
    AppTranslator(QObject *parent)
        : QTranslator(parent)
    {
        qApp->installTranslator(this);
    }

    virtual ~AppTranslator()
    {
        qApp->removeTranslator(this);
    }
};

class NotesSettingsPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "com.jolla.notes.settings.translations")

public:

    void initializeEngine(QQmlEngine *engine, const char *uri)
    {
        Q_UNUSED(uri)
        Q_UNUSED(engine)
        Q_ASSERT(QLatin1String(uri) == QLatin1String("com.jolla.notes.settings.translations"));

        AppTranslator *engineeringEnglish = new AppTranslator(engine);
        AppTranslator *translator = new AppTranslator(engine);
        engineeringEnglish->load("notes_eng_en", "/usr/share/translations");
        translator->load(QLocale(), "notes", "-", "/usr/share/translations");
    }

    void registerTypes(const char *uri)
    {
        Q_UNUSED(uri)
        qmlRegisterUncreatableType<AppTranslator>(uri, 1, 0, "NotesSettingsTranslations", "Notes settings translations loaded by import");
    }
};

#include "plugin.moc"
