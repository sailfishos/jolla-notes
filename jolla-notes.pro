TARGET = jolla-notes

SOURCES += notes.cpp

HEADERS +=

qml.files = notes.qml qml

desktop.files = jolla-notes.desktop

include(sailfishapplication/sailfishapplication.pri)

OTHER_FILES = rpm/jolla-notes.spec
