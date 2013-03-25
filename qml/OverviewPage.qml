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

        // Capture clicks that don't hit any delegate
        MouseArea {
            id: viewbackground
            anchors.fill: parent
            onClicked: {
                console.log("Click!")
                notesModel.newNote(1)
                pageStack.push(notePage, {currentIndex: 1})
            }
        }

        Component.onCompleted: viewbackground.parent = flickable.contentItem
    }

    NotesModel {
        id: notesModel
    }

    NotePage { id: notePage }
}
