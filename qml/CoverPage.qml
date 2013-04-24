import QtQuick 1.1
import Sailfish.Silica 1.0

CoverBackground {
    objectName: "coverpage" // used by the tests

    Item {
        anchors { fill: parent; margins: theme.paddingLarge }

        NoteSummary {
            //: Coverpage text when no note is selected
            //% "Notes"
            property string baseText: qsTrId("notes-ap-cover")
            text: pageStack.depth > 1 && pageStack.currentPage.text
                      ? pageStack.currentPage.text : baseText
        }
    }

    CoverActionList {
        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: {
                pageStack.pop(null, true)
                openNewNote()
                activate()
            }
        }

        CoverAction {
            // There's a visual glitch: when the cover text changes,
            // the old text shows through. This only happens the first
            // time the app is minimized. Work around it by reloading
            // the cover the first time the text changes. Don't know
            // why the workaround works.
            property bool bugworkaround

            iconSource: "image://theme/icon-cover-next"
            onTriggered: {
                if (notesModel.count == 0)
                    return;

                if (pageStack.depth == 1) {
                    pageStack.push(notePage, { currentIndex: 0 }, true)
                } else {
                    var index = pageStack.currentPage.currentIndex + 1
                    if (index == notesModel.count)
                        index = 0
                    pageStack.currentPage.currentIndex = index
                }
                if (!bugworkaround) {
                    _loadCover()
                    bugworkaround = true
                }
            }
        }
    }
}
