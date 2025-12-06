// SPDX-FileCopyrightText: 2025 Damien Caliste
//
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick 2.6
import Sailfish.Silica 1.0

BackgroundItem {
    id: root

    property alias text: label.text
    property alias description: description.text
    property alias iconSource: icon.source

    height: Math.max(Theme.itemSizeLarge, content.height)

    Column {
        id: content

        anchors {
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        Item {
            width: parent.width
            height: Math.max(icon.height, label.height)
            Image {
                id: icon

                anchors.verticalCenter: parent.verticalCenter
                height: Theme.iconSizeSmall
                width: visible ? Theme.iconSizeSmall : 0
                visible: source != ""
            }
            Label {
                id: label

                anchors {
                    left: icon.right
                    leftMargin: icon.visible ? Theme.paddingMedium : 0
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                }
                truncationMode: TruncationMode.Fade
                font.pixelSize: Theme.fontSizeLarge
                maximumLineCount: 1
                highlighted: root.highlighted
            }
        }
        Label {
            id: description

            width: parent.width
            height: text.length > 0 ? implicitHeight : 0
            truncationMode: TruncationMode.Fade
            maximumLineCount: 3
            highlighted: root.highlighted
            color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
        }
    }
}
