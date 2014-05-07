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

		for(var i = 0; i < numberOfNotes; i++){
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
