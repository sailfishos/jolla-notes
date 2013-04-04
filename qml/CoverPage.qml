import QtQuick 1.1
import Sailfish.Silica 1.0

Rectangle {
    anchors.fill: parent
    color: "black"

    Item {
        anchors { fill: parent; margins: theme.paddingLarge }

        NoteSummary {
            text: app.pageStack.depth > 1 && app.pageStack.currentPage.text ?
                      app.pageStack.currentPage.text : "Notes"
        }
    }
    
    CoverActionList {
        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: {
                app.pageStack.pop(null, true)
                overviewpage.openNewNote()
                app.activate()
            }
        }
    }
}
