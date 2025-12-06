// SPDX-FileCopyrightText: 2013 - 2022 Jolla Ltd.
// SPDX-FileCopyrightText: 2024 - 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: overviewpage

    function showDeleteNote(uid) {
        var index = notesModel.indexOf(uid)
        if (index !== undefined) {
            // This is needed both for UI (the user should see the remorse item)
            // and to make sure the delegate exists.
            view.positionViewAtIndex(index, GridView.Contain)
            // Set currentIndex in order to find the corresponding currentItem.
            // Is this really the only way to look up a delegate by index?
            view.currentIndex = index
            view.currentItem.deleteNote()
        }
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

    readonly property bool populated: notesModel.populated
    onPopulatedChanged: {
        if (notesModel.count === 0) {
            openNewNote(PageStackAction.Immediate)
        }
    }

    property int _cornerRounding: Math.max(Screen.topLeftCorner.radius,
                                           Screen.topRightCorner.radius,
                                           Screen.bottomLeftCorner.radius,
                                           Screen.bottomRightCorner.radius)
    property bool _searchActive

    onStatusChanged: {
        if (status === PageStatus.Active) {
            if (populated && _flashDelegateIndexes.length) {
                // Flash grid delegates of imported notes
                for (var i in _flashDelegateIndexes) {
                    flashGridDelegate(_flashDelegateIndexes[i])
                }
                _flashDelegateIndexes = []
            }
            if (notesModel.filter.length > 0) {
                notesModel.refresh() // refresh search
            }
        } else if (status === PageStatus.Inactive) {
            if (notesModel.filter.length == 0) {
                overviewpage._searchActive = false
            }
        }
    }

    SilicaGridView {
        id: view

        // reference column width: 960 / 4
        property int columnCount: Math.floor((isLandscape ? Screen.height : Screen.width) / (Theme.pixelRatio * 240))

        currentIndex: -1
        anchors.fill: overviewpage
        model: notesModel
        cellHeight: overviewpage.width / columnCount
        cellWidth: cellHeight

        onMovementStarted: {
            focus = false   // close the vkb
        }

        ViewPlaceholder {
            id: placeholder

            // Avoid flickering empty state placeholder when updating search results
            function placeholderText() {
                return notesModel.filter.length > 0 ? //% "Sorry, we couldn't find anything"
                                                      qsTrId("notes-la-could_not_find_anything")
                                                    : //: Comforting text when overview is empty
                                                      //% "Write a note"
                                                      qsTrId("notes-la-overview-placeholder")
            }
            Component.onCompleted: text = placeholderText()

            Binding {
                when: placeholder.opacity == 0.0
                target: placeholder
                property: "text"
                value: placeholder.placeholderText()
            }

            enabled: notesModel.populated && notesModel.count === 0
        }

        header: Column {
            width: view.width

            Item {
                width: 1
                height: Math.max(overviewpage._cornerRounding,
                                 overviewpage.orientation == Orientation.Portrait ? Screen.topCutout.height : 0)
            }

            SearchField {
                width: parent.width
                canHide: text.length === 0
                active: overviewpage._searchActive
                inputMethodHints: Qt.ImhNone // Enable predictive text

                onActiveChanged: {
                    if (active) {
                        forceActiveFocus()
                    }
                }

                onHideClicked: overviewpage._searchActive = false
                onTextChanged: notesModel.filter = text

                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
            }
        }

        footer: Item {
            width: 1
            height: overviewpage._cornerRounding
        }

        delegate: NoteItem {
            id: noteItem

            // make model.uid accessible to other delegates
            property string uid: model.uid

            function deleteNote() {
                remorseDelete(function() {
                    notesModel.deleteNote(model.uid)
                })
            }

            function flash() {
                flashAnim.running = true
            }

            text: model.text ? Theme.highlightText(model.text.substr(0, Math.min(model.text.length, 300)),
                                                   notesModel.filter, Theme.highlightColor)
                             : ""
            color: model.color
            title: model.title && model.title == "" ? (index + 1) : model.title
            menu: contextMenuComponent

            onClicked: pageStack.animatorPush(notePage, { uid: model.uid, pageNumber: index + 1 } )

            Rectangle {
                id: flashRect

                anchors.fill: parent
                color: noteItem.color
                opacity: 0.0

                SequentialAnimation {
                    id: flashAnim

                    running: false
                    PropertyAnimation { target: flashRect
                        property: "opacity"
                        to: Theme.opacityLow
                        duration: 600
                        easing.type: Easing.InOutQuad
                    }
                    PropertyAnimation {
                        target: flashRect
                        property: "opacity"
                        to: 0.01
                        duration: 600
                        easing.type: Easing.InOutQuad
                    }
                    PropertyAnimation {
                        target: flashRect
                        property: "opacity"
                        to: Theme.opacityLow
                        duration: 600
                        easing.type: Easing.InOutQuad
                    }
                    PropertyAnimation {
                        target: flashRect
                        property: "opacity"
                        to: 0.00
                        duration: 600
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

        PullDownMenu {
            MenuItem {
                visible: journalProvider.model.count > 0
                //% "Change provider"
                text: qsTrId("notes-me-provider")
                onClicked: {
                    pageStack.animatorPush(providerPage)
                }
            }

            MenuItem {
                visible: notesModel.filter.length > 0 || notesModel.count > 0
                //% "Search"
                text: qsTrId("notes-me-search")
                onClicked: {
                    overviewpage._searchActive = true
                }
            }

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
        id: contextMenuComponent

        ContextMenu {
            id: contextMenu

            MenuItem {
                //: Delete this note from overview
                //% "Delete"
                text: qsTrId("notes-la-delete")
                onClicked: contextMenu.parent.deleteNote()
            }

            MenuItem {
                //: Move this note to be first in the list
                //% "Move to top"
                text: qsTrId("notes-la-move-to-top")
                visible: contextMenu.parent && contextMenu.parent.uid != ''
                property string uid
                onClicked: uid = contextMenu.parent.uid // parent is null by the time delayedClick() is called
                onDelayedClick: notesModel.moveToTop(uid)
            }
        }
    }

    Component {
        id: providerPage
        ProviderPage {
            onSelected: {
                if (providerId == "local") {
                    notesModel.setLocalProvider()
                } else if (providerId == "journals") {
                    notesModel.provider = journalProvider
                    journalProvider.databasePath = sourceId
                }
            }
        }
    }
}
