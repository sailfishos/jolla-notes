import QtQuick 2.0
import Sailfish.Silica 1.0

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
        }
        ListView {
            id: listView

            property real itemHeight: 2*lineHeight
            property real lineHeight: dummyLabel.implicitHeight

            clip: true
            model: notesModel
            interactive: false
            width: parent.width
            header: Item { height: Theme.paddingMedium; width: listView.width }
            visible: pageStack.depth === 1
                  || pageStack.currentPage && pageStack.currentPage.potentialPage != undefined
                                           && pageStack.currentPage.potentialPage
            height: Math.min(count, 3) * (itemHeight + spacing)
            spacing: Theme.paddingLarge

            delegate: CoverLabel {
                text: model.text.trim()
                color: model.color
                maximumLineCount: 2
                width: listView.width
                pageNumber: model.pagenr
                lineHeight: listView.lineHeight
                Component.onCompleted: listView.itemHeight = height
            }
            // we need text dimensions before label delegates get created
            Label {
                id: dummyLabel
                lineHeight: 0.8
                font.pixelSize: Theme.fontSizeSmall
            }
        }
        CoverLabel {
            id: noteLabel

            visible: notesModel.count > 0 && pageStack.depth > 1
                      && pageStack.currentPage.currentIndex >= 0
            maximumLineCount: 8
            width: parent.width
            y: Theme.paddingMedium
            lineHeight: listView.lineHeight
            text: visible ? pageStack.currentPage.text.trim() : ""
            color: visible ? pageStack.currentPage.color :  Theme.primaryColor
            pageNumber: visible ? pageStack.currentPage.pageNumber : 0
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
