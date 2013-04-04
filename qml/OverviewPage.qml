import QtQuick 1.1
import Sailfish.Silica 1.0

Page {
    id: overviewpage

    function openNewNote() {
        notesModel.newNote(1)
        pageStack.push(notePage, {currentIndex: 0, editMode: true})
    }

    SilicaGridView {
        id: view

        anchors.fill: overviewpage
        delegate: NoteItem {
            text: model.text
            color: model.color
            pageNumber: model.pagenr
            height: view.cellHeight
            width: view.cellWidth
            onClicked: pageStack.push(notePage, {currentIndex: model.index})
        }
        model: notesModel
        cellHeight: Math.min(overviewpage.height, overviewpage.width) / 2
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
            anchors.fill: view
            onClicked: openNewNote()
        }

        PullDownMenu {
            MenuItem {
                text: "New note"
                onClicked: openNewNote()
            }
        }
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
}
