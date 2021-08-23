TEMPLATE = subdirs
SUBDIRS = notes.pro settings vault
OTHER_FILES += rpm/jolla-notes.spec

include(tests.pri)
