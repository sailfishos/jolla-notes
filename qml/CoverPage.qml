import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0

CoverBackground {
    property string testName: "coverpage"

    CoverPlaceholder {
        //: Coverpage text when there are no notes
        //% "Write a note"
        text: qsTrId("notes-la-write-note")
        icon.source: "image://theme/icon-launcher-notes"
        visible: !notesModel.count
    }
    Item {
        visible: notesModel.count > 0
        anchors {
            fill: parent
            margins: Theme.paddingLarge
            topMargin: Theme.paddingMedium
        }
        ListView {
            id: listView

            // we need text dimensions before label delegates get created
            Label { id: dummyLabel; lineHeight: 0.8 }

            property real lineHeight: dummyLabel.implicitHeight

            clip: true
            model: notesModel
            interactive: false
            width: parent.width
            header: Item { height: Theme.paddingMedium; width: listView.width }
            visible: pageStack.depth === 1
                  || pageStack.currentPage && pageStack.currentPage.potentialPage != undefined
                                           && pageStack.currentPage.potentialPage
            height: Math.min(count, 3) * (2*lineHeight + Theme.paddingMedium)
            spacing: Theme.paddingMedium

            delegate: CoverLabel {
                text: model.text.trim()
                color: model.color
                maximumLineCount: 2
                width: listView.width
                pageNumber: model.pagenr
                lineHeight: listView.lineHeight
            }
        }
        CoverLabel {
            id: noteLabel

            property variant model

            visible: false
            maximumLineCount: 7
            width: parent.width
            y: Theme.paddingMedium
            lineHeight: listView.lineHeight
            text: model ? model.text.trim() : ""
            color: model ? model.color :  Theme.primaryColor
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
                openNewNote(PageStackAction.Immediate)
                activate()
            }
        }
    }
}
