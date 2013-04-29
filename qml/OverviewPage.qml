import QtQuick 1.1
import Sailfish.Silica 1.0

Page {
    id: overviewpage

    SilicaGridView {
        id: view

        anchors.fill: overviewpage
        model: notesModel
        cellHeight: Math.min(overviewpage.height, overviewpage.width) / 2
        cellWidth: cellHeight
        property int columnCount: Math.floor(overviewpage.width / cellWidth)

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
            text: qsTrId("notes-la-write-note")
            enabled: view.count == 0
        }
        delegate: Item {
            // The NoteItem is wrapped in an Item in order to allow the
            // delegate to resize for the contextMenu without affecting
            // the layout inside the NoteItem.
            id: itemcontainer

            // Adjust the height to make space for the context menu if needed
            height: view.contextMenuOn === itemcontainer
                    ? view.cellHeight + view.contextMenu.height
                    : view.cellHeight
            width: view.cellWidth

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
                y: index >= view.minOffsetIndex ? view.yOffset : 0
                // When the context menu is open, disable all other delegates
                enabled: !(view.contextMenu && view.contextMenu.visible &&
                           view.contextMenuOn !== itemcontainer)
                highlighted: down || view.contextMenuOn === itemcontainer

                onClicked: pageStack.push(notePage, {currentIndex: model.index})
                onPressAndHold: view.showContextMenu(itemcontainer)


                RemorseItem { id: remorse }
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
                onClicked: app.openNewNote()
            }
        }
    }

    Component {
        id: contextmenucomponent
        ContextMenu {
            id: contextmenu

            // The menu extends across the whole gridview horizontally
            width: view.width
            x: parent ? -parent.x : 0

            MenuItem {
                //: Move this note to be first in the list
                //% "Move to top"
                text: qsTrId("notes-la-move-to-top")
                onClicked: {
                    // If the item will move, then close the menu instantly.
                    // The closing animation looks bad after such a jump.
                    var index = contextmenu.parent.index
                    if (index > 0) {
                        // There were several options for closing it
                        // immediately, but most of them caused the
                        // menu to open in the wrong place when reopened.
                        // The current approach avoids that problem
                        // at the cost of reconstructing the menu later.
                        contextmenu.hide()
                        contextmenu.height = 0
                        contextmenu.parent = null
                        view.contextMenu = null
                        contextmenu.destroy()
                    }
                    notesModel.moveToTop(index)
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
