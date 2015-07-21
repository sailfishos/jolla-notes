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

// BackgroundItem is also a MouseArea
BackgroundItem {
    id: noteitem

    property int pageNumber
    property color color
    property alias text: summary.text

    // Create a tint with 10% of the primaryColor in the lower left,
    // down to 0% in the upper right.
    // Is there any way to use OpacityRampEffect instead of Gradient here?
    Item {
        // The rectangle inside is rotated to rotate the gradient,
        // but then it needs to be clipped back to an upright square.
        // This container item does the clipping so that the NoteItem itself
        // doesn't have to clip (which would interfere with context menus)
        anchors.fill: parent
        clip: true

        Rectangle {
            rotation: 45 // diagonal gradient
            // Use square root of 2, rounded up a little bit, to make the
            // rotated square cover all of the parent square
            width: parent.width * 1.412136
            height: parent.height * 1.412136
            x: parent.width - width

            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.rgba(Theme.primaryColor, 0) }
                GradientStop { position: 1.0; color: Theme.rgba(Theme.primaryColor, 0.1) }
            }
        }
    }

    Item {
        anchors { fill: parent; margins: Theme.paddingLarge }

        NoteSummary {
            id: summary
            color: highlighted ? Theme.highlightColor : Theme.primaryColor
        }

        OpacityRampEffect {
            sourceItem: summary
            slope: 0.6
            offset: 0
            direction: OpacityRamp.TopToBottom
        }

        Rectangle {
            id: colortag
            property string testName: "colortag"

            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: Theme.itemSizeExtraSmall
            height: width/8
            radius: Math.round(Theme.paddingSmall/3)
            color: noteitem.color
        }
    }

    Text {
        id: pagenumber

        anchors.baseline: parent.bottom
        anchors.baselineOffset: -Theme.paddingMedium
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingMedium
        opacity: 0.4
        color: highlighted ? Theme.highlightColor : Theme.primaryColor
        font { family: Theme.fontFamily; pixelSize: Theme.fontSizeLarge }
        horizontalAlignment: Text.AlignRight
        text: noteitem.pageNumber
    }
}
