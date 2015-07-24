/*
 * Copyright (C) 2012-2015 Jolla Ltd.
 *
 * The code in this file is distributed under multiple licenses, and as such,
 * may be used under any one of the following licenses:
 *
 *   - GNU General Public License as published by the Free Software Foundation;
 *     either version 2 of the License (see LICENSE.GPLv2 in the root directory
 *     for full terms), or (at your option) any later version.
 *   - GNU Lesser General Public License as published by the Free Software
 *     Foundation; either version 2.1 of the License (see LICENSE.LGPLv21 in the
 *     root directory for full terms), or (at your option) any later version.
 *   - Alternatively, if you have a commercial license agreement with Jolla Ltd,
 *     you may use the code under the terms of that license instead.
 *
 * You can visit <https://sailfishos.org/legal/> for more information
 */

/****************************************************************************
**
** Copyright (C) 2015 Jolla Ltd.
** Contact: Chris Adams <chris.adams@jollamobile.com>
**
****************************************************************************/

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
