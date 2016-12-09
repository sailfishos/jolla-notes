TARGET = jolla-notes
CONFIG += warn_on

HEADERS += vnote.h
SOURCES += notes.cpp

qml.files = notes.qml cover pages
desktop.files = jolla-notes.desktop jolla-notes-import.desktop

include(sailfishapplication/sailfishapplication.pri)
include(translations.pri)
