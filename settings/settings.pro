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
plugin_entry.files = jolla-notes.json

OTHER_FILES += *.qml *.json qmldir

SOURCES += plugin.cpp

INSTALLS += target import settingsqml plugin_entry
