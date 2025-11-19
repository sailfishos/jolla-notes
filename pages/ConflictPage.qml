// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: page

    property string savedText
    property string text
    property string resolution: "newFromCurrent"

    Column {
        width: parent.width

        PageHeader {
            //% "Conflict resolution"
            title: qsTrId("notes-he-conflict")
            //% "The note has been externally modified."
            description: qsTrId("notes-he-conflict-description")
        }

        ComboBox {
            id: conflictCombo

            //% "Policy for the current version"
            label: qsTrId("notes-cb-solve-conflict")
            currentIndex: 0
            menu: ContextMenu {
                MenuItem {
                    //% "Create a new note"
                    text: qsTrId("notes-cb-current-as-new")
                    onClicked: page.resolution = "newFromCurrent"
                }
                MenuItem {
                    //% "Replace the stored version"
                    text: qsTrId("notes-cb-store-current")
                    onClicked: page.resolution = "storeCurrent"
                }
                MenuItem {
                    //% "Discard and use the stored version"
                    text: qsTrId("notes-cb-discard-current")
                    onClicked: page.resolution = "discardCurrent"
                }
                onActivated: pageStack.pop()
            }
        }
    }
}
