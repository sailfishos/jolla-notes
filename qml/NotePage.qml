/*
 * Copyright (C) 2012-2015 Jolla Ltd.
 *
 * The code in this file is distributed under multiple licenses, and as such,
 * may be used under any one of the following licenses:
 *
 *   - GNU General Public License as published by the Free Software Foundation;
 *     either version 2 of the License (see LICENSE.GPLv2 in the root directory
 *     for full terms), or (at your option) any later version.
 *   - GNU Lesser General Public License as published by the Free Software
 *     Foundation; either version 2.1 of the License (see LICENSE.LGPLv21 in the
 *     root directory for full terms), or (at your option) any later version.
 *   - Alternatively, if you have a commercial license agreement with Jolla Ltd,
 *     you may use the code under the terms of that license instead.
 *
 * You can visit <https://sailfishos.org/legal/> for more information
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0

Page {
    id: page

    // currentIndex is for allocated notes.
    // potentialPage is for empty notes that haven't been added to the db yet.
    property int currentIndex: -1
    property int potentialPage
    property alias editMode: textArea.focus
    property alias text: textArea.text
    property alias color: noteview.color
    property alias pageNumber: noteview.pageNumber
    property bool loaded  // only load from notesModel[currentIndex] once

    property bool __jollanotes_notepage

    // TODO: should some kind of IndexConnection go into the silica components?
    Connections {
        target: notesModel

        onRowsRemoved: {
            console.log("Notes removed: " + first + ".." + last)
            if (currentIndex >= first) {
                if (currentIndex > last) {
                    currentIndex -= (last - first + 1)
                } else {
                    // current note was deleted; turn it into a potential note
                    potentialPage = pageNumber
                }
            }
        }

        onRowsInserted: { 
            console.log("Notes inserted: " + first + ".." + last)
            if (currentIndex >= first)
                currentIndex += (last - first + 1)
        }

        onRowsMoved: {
            console.log("Notes moved: " + start + ".." + end + " -> " + row)
            // start and end are indexes from before the move,
            // "row" is start's new index after the move
            var numMoved = end - start + 1
            if (currentIndex >= start && currentIndex <= end) {
                // current note was among those moved
                currentIndex += start - row
            } else if (currentIndex > end && currentIndex < row + numMoved) {
                // moved notes jumped over current note
                currentIndex -= numMoved
            } else if (currentIndex < start && currentIndex >= row) {
                // moved notes jumped before current note
                currentIndex += numMoved
            }
        }
    }

    onCurrentIndexChanged: {
        if (!loaded && currentIndex >= 0 && currentIndex < notesModel.count) {
            potentialPage = 0
            var item = notesModel.get(currentIndex)
            noteview.savedText = item.text
            noteview.text = item.text
            noteview.color = item.color
            noteview.pageNumber = item.pagenr
            loaded = true
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Deactivating) {
            if (currentIndex >= 0 && noteview.text.trim() == '') {
                notesModel.deleteNote(currentIndex)
                currentIndex = -1
            } else {
                saveNote()
            }
        }
    }

    function saveNote() {
        var text = textArea.text
        if (text != noteview.savedText) {
            noteview.savedText = text
            if (potentialPage) {
                if (text.trim() != '') {
                    currentIndex = notesModel.newNote(potentialPage, text, noteview.color)
                }
            } else {
                notesModel.updateNote(currentIndex, text)
            }
        }
    }

    onPotentialPageChanged: {
        if (potentialPage) {
            currentIndex = -1
            noteview.savedText = ''
            noteview.text = ''
            noteview.color = notesModel.nextColor()
            noteview.pageNumber = potentialPage
        }
    }

    function openColorPicker() {
        var page = pageStack.push("Sailfish.Silica.ColorPickerPage",
            {"colors": notesModel.availableColors()})
        page.colorClicked.connect(function(color) {
            noteview.color = color
            notesModel.updateColor(currentIndex, color)
            pageStack.pop()
        })
    }

    function noteFileName(noteText) {
        // Return a name for this vnote that can be used as a filename

        // Remove any whitespace
        var noWhitespace = noteText.replace(/\s/g, '')

        // shorten
        var shortened = noWhitespace.slice(0, Math.min(8, noWhitespace.length))

        // Convert to 7-bit ASCII
        var sevenBit = Format.formatText(shortened, Formatter.Ascii7Bit)
        if (sevenBit.length < shortened.length) {
            // This note's name is not representable in ASCII
            //: Placeholder name for note filename
            //% "note"
            sevenBit = qsTrId("notes-ph-default-note-name")
        }

        // Remove any characters that are not part of the portable filename character set
        return Format.formatText(sevenBit, Formatter.PortableFilename)
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
        contentHeight: column.y + column.height

        PullDownMenu {
            id: pulley

            MenuItem {
                //% "Note color"
                text: qsTrId("notes-me-note-color")
                onClicked: openColorPicker()
            }
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
                            // If the note text is empty then the note
                            // will be deleted by onStatusChanged, and
                            // there should not be a remorse timer etc.
                            if (page.currentIndex >= 0
                                && noteview.text.trim() != '') {
                                var overview = pageStack.previousPage()
                                overview.showDeleteNote(page.currentIndex)
                            }
                            pageStack.pop(null, true)
                            noteview.opacity = 1.0
                        }
                    }
                }
            }
            MenuItem {
                //: This menu option can be used to share the note via Bluetooth
                //% "Share Note"
                text: qsTrId("notes-me-share-note")
                enabled: noteview.text.trim() != ''
                onClicked: {
                    var fileName = page.noteFileName(noteview.text) + (transferAsVNoteConfig.value == true ? ".vnt" : ".txt")
                    var mimeType = transferAsVNoteConfig.value == true ? "text/x-vnote" : "text/plain"
                    // vnoteConverter is a global installed by notes.cpp
                    var noteText = transferAsVNoteConfig.value == true ? vnoteConverter.vNote(textArea.text) : textArea.text
                    pageStack.push(Qt.resolvedUrl("NoteSharePage.qml"), {
                        "name": fileName,
                        "text": noteText,
                        "type": mimeType,
                    })
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
                            saveNote()
                            pageStack.replace(notePage, {
                                potentialPage: 1,
                                editMode: true
                            }, PageStackAction.Immediate)
                        }
                    }
                }
            }
        }

        Column {
            id: column
            width: page.width

            Item {
                id: headerItem
                width: parent.width
                height: Theme.itemSizeLarge

                ColorItem {
                    id: colorItem
                    color: noteview.color
                    pageNumber: noteview.pageNumber
                    onClicked: openColorPicker()
                }
            }
            TextArea {
                id: textArea
                font { family: Theme.fontFamily; pixelSize: Theme.fontSizeMedium }
                width: parent.width
                height: Math.max(noteview.height - headerItem.height, implicitHeight)
                //: Placeholder text for new notes. At this point there's
                //: nothing else on the screen.
                //% "Write a note..."
                placeholderText: qsTrId("notes-ph-empty-note")
                background: null // full-screen text fields don't need bottom border background

                onTextChanged: saveTimer.restart()
                Timer {
                    id: saveTimer
                    interval: 5000
                    onTriggered: page.saveNote()
                }
                Connections {
                    target: Qt.application
                    onActiveChanged: if (!Qt.application.active) page.saveNote()
                }
            }
        }
        VerticalScrollDecorator {}
    }

    ConfigurationValue {
       id: transferAsVNoteConfig
       key: "/apps/jolla-notes/settings/transferAsVNote"
       defaultValue: false
    }
}
