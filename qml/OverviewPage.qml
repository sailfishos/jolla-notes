import QtQuick 1.1
import Sailfish.Silica 1.0

Page {
    id: overviewpage

    function openNewNote() {
        notesModel.newNote(1)
        pageStack.push(notePage, {currentIndex: 0, editMode: true})
    }

    // Capture clicks that don't hit any delegate
    MouseArea {
        id: viewbackground
        height: Math.max(parent.height, view.height)
        width: parent.width
        onClicked: openNewNote()
    }

    SilicaGridView {
        id: view

        anchors.fill: overviewpage
        model: notesModel
        cellHeight: Math.min(overviewpage.height, overviewpage.width) / 2
        cellWidth: cellHeight
        property Item contextMenu

        delegate: Item {
            // The NoteItem is wrapped in an Item in order to allow the
            // delegate to resize for the contextMenu without affecting
            // the layout inside the NoteItem.
            id: itemcontainer

            // Adjust the height to make space for the context menu if needed
            height: view.contextMenu != null && view.contextMenu.parent === itemcontainer ? view.cellHeight + view.contextMenu.height : view.cellHeight
            width: view.cellWidth

            // Fade out the item under the context menu.
            // underMenu is a separate property to avoid recalculating opacity
            // for non-affected items during the menu's opening animation
            property bool underMenu: view.contextMenu != null
                    && view.contextMenu.parent != null
                    && view.contextMenu.parent.index == index - 2
            opacity: underMenu ? 1.0 - view.contextMenu.height / view.cellHeight
                               : 1.0

            // make model.index accessible to other delegates
            property int index: model.index

            NoteItem {
                text: model.text
                color: model.color
                pageNumber: model.pagenr
                height: view.cellHeight
                width: view.cellWidth

                onClicked: pageStack.push(notePage, {currentIndex: model.index})
                onPressAndHold: view.showContextMenu(itemcontainer)
            }
        }

        function showContextMenu(item) {
            if (!contextMenu)
                contextMenu = contextmenucomponent.createObject(view,
                                     { width: item.width })
            contextMenu.show(item)
        }

        PullDownMenu {
            MenuItem {
                text: "New note"
                onClicked: openNewNote()
            }
        }

        Component.onCompleted: viewbackground.parent = view.contentItem
    }

    Label {
        anchors.centerIn: parent
        visible: view.count == 0
        text: "Tap to write a note"
    }

    NotesModel {
        id: notesModel
    }

    Component {
        id: notePage
        NotePage { }
    }

    Component {
        id: contextmenucomponent
        ContextMenu {
            MenuItem {
                text: "Move to top"
            }
            MenuItem {
                text: "Delete"
            }
        }
    }
}
