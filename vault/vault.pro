TARGET = notes-vault

CONFIG += warn_on c++11

SOURCES += notes-vault.cpp

CONFIG += link_pkgconfig
PKGCONFIG += qtaround vault

target.path = $$PREFIX/libexec/jolla-notes

vault_config.files = Notes.json
vault_config.path = /usr/share/jolla-vault/units

INSTALLS += target vault_config

QT += sql
