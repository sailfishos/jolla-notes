# The name of your app
TARGET = jolla-notes

# C++ sources
SOURCES += notes.cpp

# C++ headers
HEADERS +=

# QML files and folders
qml.files = notes.qml qml

# The .desktop file
desktop.files = jolla-notes.desktop

# Please do not modify the following line.
include(sailfishapplication/sailfishapplication.pri)

OTHER_FILES = rpm/jolla-notes.yaml

