import QtQuick 1.1
import Sailfish.Silica 1.0

Page {
    id: notepage

    // currentIndex is for allocated notes.
    // potentialPage is for empty notes that haven't been added to the db yet.
    property int currentIndex: -1
    property int potentialPage
    property alias editMode: textArea.focus
    property alias text: textArea.text

    backNavigation: false

    onCurrentIndexChanged: {
        if (currentIndex >= 0 && currentIndex < notesModel.count) {
            potentialPage = 0
            var item = notesModel.get(currentIndex)
            noteview.savedText = item.text
            noteview.text = item.text
            noteview.color = item.color
            noteview.pageNumber = item.pagenr
        }
    }

    onPotentialPageChanged: {
        if (potentialPage) {
            currentIndex = -1
            noteview.savedText = ''
            noteview.text = ''
            noteview.color = "white"
            noteview.pageNumber = 0
        }
    }

    SilicaFlickable {
        id: noteview

        property color color: "white"
        property alias text: textArea.text
        property int pageNumber
        property string savedText

        anchors.fill: parent
        // The PullDownMenu doesn't work if contentHeight is left implicit.
        // It also doesn't work if contentHeight ends up equal to the
        // page height, so add some padding.
        contentHeight: textArea.height + 2 * theme.paddingLarge

        PullDownMenu {
            MenuItem {
                //: Delete this note from note page
                //% "Delete note"
                text: qsTrId("notes-me-delete-note")
                onClicked: deleteNoteAnimation.restart()
                SequentialAnimation {
                    id: deleteNoteAnimation
                    NumberAnimation {
                        target: noteview
                        property: "opacity"
                        duration: 200
                        easing.type: Easing.InOutQuad
                        to: 0.0
                    }
                    ScriptAction {
                        script: {
                            if (notepage.currentIndex >= 0) {
                                var overview = pageStack.previousPage()
                                overview.showDeleteNote(notepage.currentIndex)
                            }
                            pageStack.pop(null, true)
                            noteview.opacity = 1.0
                        }
                    }
                }
            }
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
                            if (!potentialPage)
                                potentialPage = noteview.pageNumber + 1
                            else
                                text = ''
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
                onClicked: {
                    if (currentIndex >= 0 && noteview.text.trim() == '') {
                        notesModel.deleteNote(currentIndex)
                        currentIndex = -1
                    }
                    pageStack.pop()
                }
            }
        }

        TextArea {
            id: textArea
            y: theme.paddingLarge
            font { family: theme.fontFamily; pixelSize: theme.fontSizeMedium }
            width: noteview.width
            height: Math.max(noteview.height - theme.paddingLarge,
                             implicitHeight)
            //: Placeholder text for new notes. At this point there's
            //: nothing else on the screen.
            //% "Write a note..."
            placeholderText: qsTrId("notes-ph-empty-note")

            onTextChanged: {
                if (text != noteview.savedText) {
                    noteview.savedText = text
                    if (potentialPage) {
                        if (text.trim() != '') {
                            currentIndex = notesModel.newNote(potentialPage, text)
                        }
                    } else {
                        notesModel.updateNote(currentIndex, text)
                    }
                }
            }
        }
    }    
}
