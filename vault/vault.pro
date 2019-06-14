TARGET = notes-vault

CONFIG += warn_on c++11

SOURCES += notes-vault.cpp

unix {
    CONFIG += link_pkgconfig
    PKGCONFIG += qtaround vault-unit
}

target.path = $$PREFIX/libexec/jolla-notes
INSTALLS += target

QT += sql
