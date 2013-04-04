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
}
