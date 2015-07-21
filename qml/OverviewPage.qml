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

Page {
    id: overviewpage

    property bool startupCheck
    function showDeleteNote(index) {
        // This is needed both for UI (the user should see the remorse item)
        // and to make sure the delegate exists.
        view.positionViewAtIndex(index, GridView.Contain)
        // Set currentIndex in order to find the corresponding currentItem.
        // Is this really the only way to look up a delegate by index?
        view.currentIndex = index
        view.currentItem.deleteNote()
    }
    function flashGridDelegate(index) {
        // This is needed both for UI (the user should see the remorse item)
        // and to make sure the delegate exists.
        view.positionViewAtIndex(index, GridView.Contain)
        // Set currentIndex in order to find the corresponding currentItem.
        // Is this really the only way to look up a delegate by index?
        view.currentIndex = index
        view.currentItem.flash()
    }
    property var _flashDelegateIndexes: []

    onStatusChanged: {
        if (status === PageStatus.Active) {
            if (!startupCheck) {
                // Open new note page directly if no notes have yet been saved
                startupCheck = true
                if (notesModel.count === 0) {
                    openNewNote(PageStackAction.Immediate)
                }
            } else if (_flashDelegateIndexes.length) {
                // Flash grid delegates of imported notes
                for (var i in _flashDelegateIndexes) {
                    flashGridDelegate(_flashDelegateIndexes[i])
                }
                _flashDelegateIndexes = []
            }
        }
    }

    SilicaGridView {
        id: view

        anchors.fill: overviewpage
        model: notesModel
        cellHeight: overviewpage.width / columnCount
        cellWidth: cellHeight
        // reference column width: 960 / 4
        property int columnCount: Math.floor(width / (Theme.pixelRatio * 240))

        property Item contextMenu
        property Item contextMenuOn: contextMenu ? contextMenu.parent : null
        // Figure out which delegates need to be moved down to make room
        // for the context menu when it's open.
        property int minOffsetIndex:
            contextMenuOn ? contextMenuOn.index
                            - (contextMenuOn.index % columnCount) + columnCount
                          : 0
        property int yOffset: contextMenu ? contextMenu.height : 0

        ViewPlaceholder {
            //: Comforting text when overview is empty
            //% "Write a note"
            text: qsTrId("notes-la-overview-placeholder")
            enabled: view.count == 0
        }
        delegate: Item {
            // The NoteItem is wrapped in an Item in order to allow the
            // delegate to resize for the contextMenu without affecting
            // the layout inside the NoteItem.
            id: itemcontainer

            // Adjust the height to make space for the context menu if needed
            height: menuOpen ? view.cellHeight + view.contextMenu.height
                             : view.cellHeight
            width: view.cellWidth

            // make model.index accessible to other delegates
            property int index: model.index
            property bool menuOpen: view.contextMenuOn === itemcontainer

            function deleteNote() {
                var remorse = remorsecomponent.createObject(itemcontainer)
                //: Remorse item text, will delete note when timer expires
                //% "Deleting"
                remorse.execute(noteitem, qsTrId("notes-la-deleting"),
                                function() {
                    notesModel.deleteNote(index)
                })
            }

            function flash() {
                flashAnim.running = true
            }

            NoteItem {
                id: noteitem

                text: model.text
                color: model.color
                pageNumber: model.pagenr
                height: view.cellHeight
                width: view.cellWidth
                y: index >= view.minOffsetIndex ? view.yOffset : 0
                highlighted: down || menuOpen
                _backgroundColor: down && !menuOpen ? highlightedColor : "transparent"

                onClicked: pageStack.push(notePage, {currentIndex: model.index})
                onPressAndHold: view.showContextMenu(itemcontainer)

                Rectangle {
                    id: flashRect
                    anchors.fill: parent
                    color: noteitem.color
                    opacity: 0.0
                    SequentialAnimation {
                        id: flashAnim
                        running: false
                        PropertyAnimation { target: flashRect; property: "opacity"; to: 0.40; duration: 600; easing.type: Easing.InOutQuad }
                        PropertyAnimation { target: flashRect; property: "opacity"; to: 0.01; duration: 600; easing.type: Easing.InOutQuad }
                        PropertyAnimation { target: flashRect; property: "opacity"; to: 0.40; duration: 600; easing.type: Easing.InOutQuad }
                        PropertyAnimation { target: flashRect; property: "opacity"; to: 0.00; duration: 600; easing.type: Easing.InOutQuad }
                    }
                }
            }
        }

        function showContextMenu(item) {
            if (!contextMenu)
                contextMenu = contextmenucomponent.createObject(view)
            contextMenu.show(item)
        }

        PullDownMenu {
            MenuItem {
                //: Create a new note ready for editing
                //% "New note"
                text: qsTrId("notes-me-new-note")
                onClicked: app.openNewNote(PageStackAction.Animated)
            }
        }
        VerticalScrollDecorator {}
    }

    Component {
        id: contextmenucomponent
        ContextMenu {
            id: contextmenu

            // The menu extends across the whole gridview horizontally
            width: view.width
            x: parent ? -parent.x : 0

            property Item moveToTopItem

            onClosed: {
                if (moveToTopItem) {
                    moveToTopAnim.start()
                }
            }

            SequentialAnimation {
                id: moveToTopAnim

                NumberAnimation {
                    target: moveToTopItem
                    properties: "opacity"
                    duration: 200
                    to: 0.5
                }
                ScriptAction {
                    script: {
                        moveToTopItem.opacity = 1.0
                        notesModel.moveToTop(moveToTopItem.index)
                        moveToTopItem = null
                    }
                }
            }

            MenuItem {
                //: Delete this note from overview
                //% "Delete"
                text: qsTrId("notes-la-delete")
                onClicked: contextmenu.parent.deleteNote()
            }

            MenuItem {
                //: Move this note to be first in the list
                //% "Move to top"
                text: qsTrId("notes-la-move-to-top")
                visible: contextmenu.parent && contextmenu.parent.index > 0
                onClicked: moveToTopItem = contextmenu.parent
            }
        }
    }

    Component {
        id: remorsecomponent
        RemorseItem {
            wrapMode: Text.Wrap
        }
    }
}
