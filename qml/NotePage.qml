import QtQuick 1.1
import Sailfish.Silica 1.0

Page {
    id: notepage

    property int currentIndex: -1
    property alias editMode: textArea.focus
    property alias text: textArea.text

    backNavigation: false

    onCurrentIndexChanged: {
        if (currentIndex >= 0 && currentIndex < notesModel.count) {
            var item = notesModel.get(currentIndex)
            noteview.savedText = item.text
            noteview.text = item.text
            noteview.color = item.color
            noteview.pageNumber = item.pagenr
        } else {
            noteview.savedText = ''
            noteview.text = ''
            noteview.color = "white"
            noteview.pageNumber = 0
        }
    }

    SilicaFlickable {
        id: noteview

        property color color
        property alias text: textArea.text
        property int pageNumber
        property string savedText

        anchors.fill: parent
        contentHeight: childrenRect.height

        PullDownMenu {
            MenuItem {
                //: Create a new note ready for editing
                //% "New note"
                text: qsTrId("notes-me-new-note")
                onClicked: newNoteAnimation.restart()
                SequentialAnimation {
                    id: newNoteAnimation
                    NumberAnimation {
                        target: noteview
                        property: "opacity"
                        duration: 200
                        easing.type: Easing.InOutQuad
                        to: 0.0
                    }
                    ScriptAction {
                        script: {
                            notesModel.newNote(noteview.pageNumber + 1)
                            notepage.currentIndex = notepage.currentIndex + 1
                            notepage.editMode = true
                            noteview.opacity = 1.0
                        }
                    }
                }
            }
            MenuItem {
                //: Jump back to overview page
                //% "Overview"
                text: qsTrId("notes-me-overview")
                onClicked: pageStack.pop()
            }
        }

        TextArea {
            id: textArea
            font { family: theme.fontFamily; pixelSize: theme.fontSizeMedium }
            width: noteview.width
            height: Math.max(noteview.height, implicitHeight)
            //: Placeholder text for new notes. At this point there's
            //: nothing else on the screen.
            //% "Write a note..."
            placeholderText: qsTrId("notes-ph-empty-note")

            onTextChanged: {
                if (text != noteview.savedText)
                    notesModel.updateNote(currentIndex, text)
                noteview.savedText = text
            }
        }
    }    
}
