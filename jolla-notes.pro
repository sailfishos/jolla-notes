TARGET = jolla-notes

CONFIG += warn_on

HEADERS += vnote.h
SOURCES += notes.cpp

HEADERS +=

qml.files = Notes.qml notes-vault.js qml

desktop.files = jolla-notes.desktop

include(sailfishapplication/sailfishapplication.pri)
include(translations.pri)
include(tests.pri)

OTHER_FILES = rpm/jolla-notes.spec
