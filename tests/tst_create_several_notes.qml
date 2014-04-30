//Testcase for manual testcase:
//Create several notes one by one (JB#11100)
//Testing that it is possible to create multiple notes one by one from pulley
//and text from previous note is not taken into new note

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

        function test_0_write_several_notes() {
		//Variable for taking into account the amount of previously existing notes
		var prevNotesCount = notesModel.count
		
		//Variable for changing amount of new notes created
		var numberOfNotes = 4;		

		select_pull_down("notes-me-new-note")

		for(var i = 0; i < numberOfNotes; i++){
			wait_pagestack("new note page opened", 2)

			//Each time check that correct amount of notes have been generated
			//Tries also to take into account the number of previously existing notes
			compare(notesModel.count, (i+prevNotesCount), "Incorrect number of notes found for round " + (i))

			wait(500)
			//New note page should be empty and not have the text from previous note page
			compare(currentPage.text, '', "new note page is empty")

			wait(500)

			//Wait for inputpanel to open then type some text and check it has been written
			wait_inputpanel_open()

			//Write 'test' on the note page and check it really has been ritten
			keyClick(Qt.Key_T)
			keyClick(Qt.Key_E)
			keyClick(Qt.Key_S)
			keyClick(Qt.Key_T)
			tryCompare(currentPage, 'text', "test")

	                wait(500) // give timer time to run out
		
			//Select create new note from pulley
			select_pull_down("notes-me-new-note")
		}

		//Checking in the end that current number of notes matches
		//Tries to take into account the number of previously existing notes
		compare(notesModel.count, numberOfNotes+prevNotesCount, "Incorrect number of notes have been generated")
        }

        function cleanupTestCase() {
            clear_db()
        }

    }
}
