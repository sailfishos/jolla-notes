import QtQuick 1.1
import Sailfish.Silica 1.0
import "qml"

ApplicationWindow
{
    id: app
    initialPage: Component { OverviewPage { id: overviewpage } }
    cover: Qt.resolvedUrl("qml/CoverPage.qml")

    property NotesModel notesModel: NotesModel { id: notesModel }

    function openNewNote() {
        notesModel.newNote(1)
        pageStack.push(notePage, {currentIndex: 0, editMode: true})
    }

    Component {
        id: notePage
        NotePage { }
    }
}
