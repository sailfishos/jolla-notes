/*
 * Copyright (C) 2012-2015 Jolla Ltd.
 *
 * The code in this file is distributed under multiple licenses, and as such,
 * may be used under any one of the following licenses:
 *
 *   - GNU General Public License as published by the Free Software Foundation;
 *     either version 2 of the License (see LICENSE.GPLv2 in the root directory
 *     for full terms), or (at your option) any later version.
 *   - GNU Lesser General Public License as published by the Free Software
 *     Foundation; either version 2.1 of the License (see LICENSE.LGPLv21 in the
 *     root directory for full terms), or (at your option) any later version.
 *   - Alternatively, if you have a commercial license agreement with Jolla Ltd,
 *     you may use the code under the terms of that license instead.
 *
 * You can visit <https://sailfishos.org/legal/> for more information
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    id: coloritem

    signal clicked
    property bool isPortrait
    property alias pageNumber: label.text

    height: Theme.itemSizeExtraSmall
    width: Theme.itemSizeExtraSmall
    radius: Theme.paddingSmall/2
    anchors {
        // The anchors that depend on isPortrait are managed with states
        // (see below) to avoid ordering problems: setting anchors to
        // 'undefined' has to be done before related anchors are assigned.
        // See http://qt-project.org/doc/qt-5/qtquick-positioning-anchors.html
        // The default state is portrait mode.
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

    states: State {
        name: "landscape"
        when: !isPortrait
        AnchorChanges {
            target: coloritem
            anchors {
                verticalCenter: undefined
                top: parent.top
            }
        }
    }
}
