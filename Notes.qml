import QtQuick 2.0
import Sailfish.Silica 1.0
import "qml"

ApplicationWindow
{
    id: app
    initialPage: Component { OverviewPage { id: overviewpage } }
    cover: Qt.resolvedUrl("qml/CoverPage.qml")
    _defaultPageOrientations: Orientation.Portrait | Orientation.Landscape

    property NotesModel notesModel: NotesModel { id: notesModel }

    function openNewNote(operationType) {
        pageStack.push(notePage, {potentialPage: 1, editMode: true}, operationType)
    }

    Component {
        id: notePage
        NotePage { }
    }
}
