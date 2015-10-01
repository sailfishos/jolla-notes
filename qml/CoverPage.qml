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

CoverBackground {
    property string testName: "coverpage"

    Repeater {
        model: 4
        delegate: Rectangle {
            y: Theme.itemSizeSmall + index * label.lineHeight
            width: parent.width
            // gives 1.5 on phone, which looks OK on the phone small cover.
            height: Theme.paddingSmall/4
            color: Theme.primaryColor
            opacity: 0.4
        }
    }

    Label {
        id: label
        property var noteText: {
            if (pageStack.depth > 1 && currentNotePage) {
                return currentNotePage.text.trim()
            } else if (notesModel.count > 0 && notesModel.moveCount) {
                return notesModel.get(0).text.trim()
            }

            return undefined
        }
        text: noteText !== undefined
              ? noteText.replace(/\n/g, " ")
              // From notes.cpp
              : qsTrId("notes-de-name")
        x: Theme.paddingSmall/2
        y: Theme.itemSizeSmall - baselineOffset - Theme.paddingSmall + (noteText !== undefined ? 0 : lineHeight)
        opacity: 0.6
        font.pixelSize: Theme.fontSizeExtraLarge
        font.italic: true
        width: noteText !== undefined ? parent.width + Theme.itemSizeLarge : parent.width - Theme.paddingSmall
        horizontalAlignment: noteText !== undefined || implicitWidth > width - Theme.paddingSmall ? Text.AlignLeft : Text.AlignHCenter
        lineHeightMode: Text.FixedHeight
        lineHeight: Math.floor(Theme.fontSizeExtraLarge * 1.35)
        wrapMode: noteText !== undefined ? Text.Wrap : Text.NoWrap
        maximumLineCount: 4
    }

    CoverActionList {
        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: {
                openNewNote(PageStackAction.Immediate)
                activate()
            }
        }
    }
}
