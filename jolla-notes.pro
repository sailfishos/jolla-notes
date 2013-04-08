TARGET = jolla-notes

CONFIG += warn_on

SOURCES += notes.cpp

HEADERS +=

qml.files = notes.qml qml

desktop.files = jolla-notes.desktop

include(sailfishapplication/sailfishapplication.pri)
include(translations.pri)

OTHER_FILES = rpm/jolla-notes.spec
