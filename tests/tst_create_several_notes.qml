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

//Testcase for manual testcase:
//Create several notes one by one (JB#11100)
//Testing that it is possible to create multiple notes one by one from pulley
//and text from previous note is not taken into new note
//FIXTURE: defaultnotes

import QtTest 1.0
import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../../usr/share/jolla-notes" as JollaNotes
import "."

JollaNotes.Notes {
    id: main

    NotesTestCase {
        name: "CreateSeveralNotes"
        when: windowShown

        function init() {
            activate()
            tryCompare(main, 'applicationActive', true)
        }

        function test_write_several_notes() {
            //Variable for taking into account the amount of previously existing notes
            var prevNotesCount = notesModel.count

            //Variable for changing amount of new notes created
            var numberOfNotes = 4;		

            for (var i = 0; i < numberOfNotes; i++) {
                select_pull_down("notes-me-new-note")

                //Waiting for current page to change to new page
                wait_for_value("pageStack", pageStack, "currentPage.text", "")

                //Each time check that correct amount of notes have been generated
                //Tries also to take into account the number of previously existing notes
                compare(notesModel.count, (i+prevNotesCount), "Incorrect number of notes found for current round: " + notesModel.count)

                wait_inputpanel_open()

                //Write 'test' on the note page and check it really has been written
                keyClick(Qt.Key_T)
                keyClick(Qt.Key_E)
                keyClick(Qt.Key_S)
                keyClick(Qt.Key_T)
                tryCompare(currentPage, 'text', "test")
            }

            //Going back after last note to save it
            go_back()

            //Checking in the end that current number of notes matches
            //Tries to take into account the number of previously existing notes
            compare(notesModel.count, numberOfNotes+prevNotesCount, "Generated " + numberOfNotes + " notes")
        }
    }
}
