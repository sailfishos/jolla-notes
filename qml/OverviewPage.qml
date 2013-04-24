import QtQuick 1.1
import Sailfish.Silica 1.0

Page {
    id: overviewpage

    // Capture clicks that don't hit any delegate
    MouseArea {
        id: viewbackground
        height: Math.max(parent.height, view.height)
        width: parent.width
        onClicked: app.openNewNote()
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
            height: view.contextMenu != null
                      && view.contextMenu.parent === itemcontainer
                    ? view.cellHeight + view.contextMenu.height
                    : view.cellHeight
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

            function deleteNote() {
                //: Remorse item text, will delete note when timer expires
                //% "Deleting"
                remorse.execute(noteitem, qsTrId("notes-la-deleting"),
                    function() { notesModel.deleteNote(index) })
            }

            NoteItem {
                id: noteitem

                text: model.text
                color: model.color
                pageNumber: model.pagenr
                height: view.cellHeight
                width: view.cellWidth

                onClicked: pageStack.push(notePage, {currentIndex: model.index})
                onPressAndHold: view.showContextMenu(itemcontainer)


                RemorseItem { id: remorse }
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
                //: Create a new note ready for editing
                //% "New note"
                text: qsTrId("notes-me-new-note")
                onClicked: app.openNewNote()
            }
        }

        Component.onCompleted: viewbackground.parent = view.contentItem
    }

    Label {
        anchors.centerIn: parent
        visible: view.count == 0
        //: Comforting text when overview is empty
        //% "Tap to write a note"
        text: "notes-la-tap-to-write"
    }

    Component {
        id: contextmenucomponent
        ContextMenu {
            id: contextmenu
            MenuItem {
                //: Move this note to be first in the list
                //% "Move to top"
                text: qsTrId("notes-la-move-to-top")
                onClicked: {
                    // If the item will move, then close the menu instantly.
                    // The closing animation looks bad after such a jump.
                    if (contextmenu.parent.index > 0)
                        contextmenu.height = 0
                    notesModel.moveToTop(contextmenu.parent.index)
                }
            }
            MenuItem {
                //: Delete this note from overview
                //% "Delete"
                text: qsTrId("notes-la-delete")
                onClicked: contextmenu.parent.deleteNote()
            }
        }
    }
}
