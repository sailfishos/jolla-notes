import QtQuick 1.1
import Sailfish.Silica 1.0

Page {
    id: notePage

    property int currentIndex: -1
    property alias editMode: textArea.focus

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
                text: "New note"
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
                            notePage.currentIndex = notePage.currentIndex + 1
                            notePage.editMode = true
                            noteview.opacity = 1.0
                        }
                    }
                }
            }
            MenuItem {
                text: "Overview"
                onClicked: pageStack.pop()
            }
        }

        TextArea {
            id: textArea
            font { family: theme.fontFamily; pixelSize: theme.fontSizeMedium }
            width: noteview.width
            height: Math.max(noteview.height, implicitHeight)

            onTextChanged: {
                if (text != noteview.savedText)
                    notesModel.updateNote(currentIndex, text)
                noteview.savedText = text
            }
        }
    }    
}
