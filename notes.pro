# SPDX-FileCopyrightText: 2014 - 2021 Jolla Ltd.
# SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
#
# SPDX-License-Identifier: BSD-3-Clause

TARGET = jolla-notes
CONFIG += warn_on link_pkgconfig

PKGCONFIG += icu-i18n

HEADERS += src/vnote.h
SOURCES += src/notes.cpp

qml.files = notes.qml cover pages qmldir
desktop.files = jolla-notes.desktop jolla-notes-import.desktop

include(sailfishapplication/sailfishapplication.pri)
include(translations/translations.pri)
