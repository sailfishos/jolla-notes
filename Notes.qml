import QtQuick 2.0
import Sailfish.Silica 1.0
import "qml"

ApplicationWindow
{
    id: app
    initialPage: Component { OverviewPage { id: overviewpage } }
    cover: Qt.resolvedUrl("qml/CoverPage.qml")

    property NotesModel notesModel: NotesModel { id: notesModel }

    function openNewNote() {
        pageStack.push(notePage, {potentialPage: 1, editMode: true})
    }

    Component {
        id: notePage
        NotePage { }
    }
}
