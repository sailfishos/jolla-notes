import QtQuick 1.1
import Sailfish.Silica 1.0

Page {
    id: page

    SilicaGridView {
        id: view

        anchors.fill: page
        delegate: NoteItem {
            text: model.text
            color: model.color
            pageNumber: model.pagenr
            height: view.cellHeight
            width: view.cellWidth
            onClicked: pageStack.push(notePage, {currentIndex: model.index})
        }
        model: notesModel
        cellHeight: Math.min(page.height, page.width) / 2
        cellWidth: cellHeight

        function debugdump() {
            console.log("Debug dump")
            for (var i = 0; i < contentItem.children.length; i++) {
                var item = contentItem.children[i]
                console.log("Note " + i + " page " + item.pageNumber + " color " + item.color + " text " + item.text)
            }
        }

        // Capture clicks that don't hit any delegate
        flickableChildren: MouseArea {
            id: viewbackground
            anchors.fill: parent
            onClicked: {
                notesModel.newNote(1)
                pageStack.push(notePage, {currentIndex: 0, editMode: true})
            }
        }

        PullDownMenu {
            MenuItem {
                text: "New note"
                onClicked: {
                    notesModel.newNote(1)
                    pageStack.push(notePage, {currentIndex: 0, editMode: true})
                }
            }
        }
    }

    NotesModel {
        id: notesModel
    }

    Component {
        id: notePage
        NotePage { }
    }
}
