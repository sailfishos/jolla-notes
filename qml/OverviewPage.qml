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
    }

    // Capture clicks that don't hit any delegate
    // Do this by capturing all clicks on the gridview and forwarding
    // those that do hit a delegate.
    // @todo is there a better way?
    MouseArea {
        id: viewbackground
        anchors.fill: view
        onClicked: {
            var mapped = mapToItem(view.contentItem, mouse.x, mouse.y)
            var delegate = view.contentItem.childAt(mapped.x, mapped.y)
            if (delegate)
                delegate.clicked(mouse)
            else {
                notesModel.newNote(1)
                pageStack.push(notePage, {currentIndex: 1})
            }
        }
    }

    NotesModel {
        id: notesModel
    }

    NotePage { id: notePage }
}
