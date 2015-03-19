import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.dbus 1.0
import "qml"

ApplicationWindow
{
    id: app
    initialPage: Component { OverviewPage { id: overviewpage } }
    cover: Qt.resolvedUrl("qml/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations
    _defaultPageOrientations: Orientation.All
    _defaultLabelFormat: Text.PlainText

    // exposed as a property so that the tests can access it
    property NotesModel notesModel: NotesModel { id: notesModel }

    function openNewNote(operationType) {
        pageStack.push(notePage, {potentialPage: 1, editMode: true}, operationType)
    }

    Component {
        id: notePage
        NotePage { }
    }

    DBusAdaptor {
        service: "com.jolla.notes"
        path: "/"
        iface: "com.jolla.notes"

        signal newNote

        onNewNote: {
            if (pageStack.currentPage.__jollanotes_notepage === undefined || pageStack.currentPage.currentIndex >= 0) {
                // don't open a new note if already showing a new unedited note
                openNewNote(PageStackAction.Immediate)
            }
            app.activate()
        }
    }
}
