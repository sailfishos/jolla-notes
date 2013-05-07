import QtQuick 1.1
import Sailfish.Silica 1.0

CoverBackground {
    objectName: "coverpage" // used by the tests

    CoverPlaceholder {
        //: Coverpage text when there are no notes
        //% "Write a note"
        text: qsTrId("notes-la-write-note")
        icon.source: "image://theme/icon-launcher-notes"
        visible: !notesModel.count
    }
    Item {
        visible: notesModel.count > 0
        anchors { fill: parent; margins: theme.paddingLarge }
        ListView {
            id: listView

            property real itemHeight: 74/327 * theme.coverSizeLarge.height

            clip: true
            model: notesModel
            interactive: false
            width: parent.width
            visible: pageStack.depth === 1 || pageStack.currentPage.potentialPage
            height: 3 *itemHeight

            delegate: CoverLabel {
                text: model.text
                color: model.color
                maximumLineCount: 2
                width: listView.width
                pageNumber: model.pagenr
                height: listView.itemHeight
            }
        }
        CoverLabel {
            id: noteLabel

            property variant model

            visible: false
            maximumLineCount: 7
            width: parent.width
            height: listView.height + theme.paddingSmall
            text: model ? model.text : ""
            color: model ? model.color :  theme.primaryColor
            pageNumber: model ? model.pagenr : 0
            states: State {
                when: notesModel.count > 0 && pageStack.depth > 1
                      && pageStack.currentPage.currentIndex >= 0
                PropertyChanges {
                    target: noteLabel
                    visible: true
                    model: notesModel.get(pageStack.currentPage.currentIndex)
                }
            }
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
    }
}
