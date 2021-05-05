TARGET = jolla-notes
CONFIG += warn_on link_pkgconfig

PKGCONFIG += icu-i18n

HEADERS += vnote.h
SOURCES += notes.cpp

qml.files = notes.qml cover pages qmldir
desktop.files = jolla-notes.desktop jolla-notes-import.desktop

include(sailfishapplication/sailfishapplication.pri)
include(translations/translations.pri)
