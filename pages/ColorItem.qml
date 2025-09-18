// SPDX-FileCopyrightText: 2013 - 2019 Jolla Ltd.
// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    id: coloritem

    signal clicked
    property alias pageNumber: label.text

    height: Theme.itemSizeExtraSmall
    width: Math.max(Theme.itemSizeExtraSmall, label.width + 2*Theme.paddingMedium)
    radius: Theme.paddingSmall/2
    anchors {
        right: parent.right
        rightMargin: Theme.horizontalPageMargin
        verticalCenter: parent.verticalCenter
        topMargin: Theme.paddingLarge
    }

    Label {
        id: label

        font.pixelSize: Theme.fontSizeLarge
        anchors.centerIn: parent
    }
    MouseArea {
        anchors { fill: parent; margins: -Theme.paddingMedium }
        onClicked: parent.clicked()
    }
}
