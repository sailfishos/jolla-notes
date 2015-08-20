TARGET = jolla-notes
CONFIG += warn_on

HEADERS += vnote.h
SOURCES += notes.cpp

qml.files = Notes.qml qml
desktop.files = jolla-notes.desktop jolla-notes-import.desktop

include(sailfishapplication/sailfishapplication.pri)
include(translations.pri)
include(tests.pri)

OTHER_FILES += oneshot/add-jolla-notes-import-default-handler
oneshot.files = oneshot/add-jolla-notes-import-default-handler
oneshot.path  = /usr/lib/oneshot.d

INSTALLS += oneshot
