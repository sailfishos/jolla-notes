import QtQuick 1.1
import Sailfish.Silica 1.0

Page {
    id: page

    SilicaGridView {
        anchors.fill: page
        delegate: NoteItem {
            text: model.text
            color: model.color
            onClicked: pageStack.push(notePage, {currentIndex: model.index})
        }
        model: notesModel
        cellHeight: Math.min(page.height, page.width) / 2
        cellWidth: cellHeight
    }
    NotesModel {
        id: notesModel
    }
    NotePage { id: notePage }
}
