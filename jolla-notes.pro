TEMPLATE = subdirs
SUBDIRS = notes.pro settings vault
OTHER_FILES += rpm/jolla-notes.spec

include(tests.pri)

OTHER_FILES += oneshot/add-jolla-notes-import-default-handler translations.js
oneshot.files = oneshot/add-jolla-notes-import-default-handler
oneshot.path  = /usr/lib/oneshot.d

INSTALLS += oneshot
