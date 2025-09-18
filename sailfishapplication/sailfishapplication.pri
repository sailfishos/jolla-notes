# SPDX-FileCopyrightText: 2013 - 2015 Jolla Ltd.
# SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
#
# SPDX-License-Identifier: BSD-3-Clause

QT += qml quick

SOURCES += $$PWD/sailfishapplication.cpp
HEADERS += $$PWD/sailfishapplication.h
INCLUDEPATH += $$PWD

isEmpty(PREFIX):PREFIX=/opt/sdk

TARGETPATH = $$PREFIX/bin
target.path = $$TARGETPATH

DEPLOYMENT_PATH = $$PREFIX/share/$$TARGET
qml.path = $$DEPLOYMENT_PATH
desktop.path = $$PREFIX/share/applications

dbus_service_entry.files = com.jolla.notes.service
dbus_service_entry.path = /usr/share/dbus-1/services

INSTALLS += target qml desktop dbus_service_entry

DEFINES += DEPLOYMENT_PATH=\"\\\"\"$${DEPLOYMENT_PATH}/\"\\\"\"

CONFIG += link_pkgconfig
packagesExist(qdeclarative5-boostable) {
    message("Building with qdeclarative-boostable support")
    DEFINES += HAS_BOOSTER
    PKGCONFIG += qdeclarative5-boostable
} else {
    warning("qdeclarative-boostable not available; startup times will be slower")
}




