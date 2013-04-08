import QtQuick 1.1
import Sailfish.Silica 1.0

Rectangle {
    anchors.fill: parent
    color: "black"

    Item {
        anchors { fill: parent; margins: theme.paddingLarge }

        NoteSummary {
            //: Coverpage text when no note is selected
            //% "Notes"
            property string baseText: qsTrId("notes-ap-cover")
            text: app.pageStack.depth > 1 && app.pageStack.currentPage.text
                      ? app.pageStack.currentPage.text : baseText
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
