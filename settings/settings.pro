# SPDX-FileCopyrightText: 2015 Jolla Ltd.
# SPDX-FileCopyrightText: 2020 Open Mobile Platform LLC.
# SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
#
# SPDX-License-Identifier: BSD-3-Clause

TEMPLATE = lib
TARGET = notessettingsplugin

MODULENAME = com/jolla/notes/settings/translations
TARGETPATH = $$[QT_INSTALL_QML]/$$MODULENAME

QT += qml dbus
CONFIG += link_pkgconfig plugin

import.files = qmldir
import.path = $$TARGETPATH
target.path = $$TARGETPATH

settingsqml.path = /usr/share/jolla-settings/pages/jolla-notes
settingsqml.files = *.qml

plugin_entry.path = /usr/share/jolla-settings/entries
plugin_entry.files = *.json

OTHER_FILES += *.qml *.json qmldir

SOURCES += plugin.cpp

INSTALLS += target import settingsqml plugin_entry
