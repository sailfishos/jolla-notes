TARGET = jolla-notes

CONFIG += warn_on

HEADERS += vnote.h
SOURCES += notes.cpp

HEADERS +=

qml.files = Notes.qml qml

desktop.files = jolla-notes.desktop

vault.files = notes-vault.js

include(sailfishapplication/sailfishapplication.pri)
include(translations.pri)
include(tests.pri)

OTHER_FILES = rpm/jolla-notes.spec

vault.path = $$DEPLOYMENT_PATH
INSTALLS += vault
