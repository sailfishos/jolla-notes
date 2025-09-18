// SPDX-FileCopyrightText: 2014 - 2022 Jolla Ltd.
// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

//Deleting a note will not delete a wrong note (JB#17311)
//Test that when deleting one note selecting another doesn't change the target of delete action
//FIXTURE: defaultnotes

import QtTest 1.0
import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../../usr/share/jolla-notes" as JollaNotes
import "."

JollaNotes.Notes {
    id: main

    NotesTestCase {
        name: "DeleteNoteDuringRemorse"
        when: windowShown

        function init() {
            activate()
            tryCompare(main, 'applicationActive', true)
        }

        function test_delete_during_remorse() {
            var prevCount = notesModel.count

            //Select items to click
            var item1 = find_text(currentPage, defaultNotes[0])
            var item2 = find_text(currentPage, defaultNotes[1])
            verify(item1, "Note " + defaultNotes[0] + " found")
            verify(item2, "Note " + defaultNotes[1] + " found")

            //Click note and delete from pulley
            click_center(item1)
            wait_pagestack("note page opened", 2)
            select_pull_down("notes-me-delete-note")
            wait_pagestack("note page closed", 1)

            //Before remorse timer runs out select second note
            click_center(item2)

            //Wait for remorse timer to run out
            wait_for_value("notesModel", notesModel, "count", prevCount-1)

            //Delete second item
            select_pull_down("notes-me-delete-note")

            //Wait for return to overview and remorse timer to run out
            wait_pagestack("back to overview", 1)
            check_deletion(prevCount-1, defaultNotes[1])

            //Check that other notes have not been deleted
            for (var i = 2; i < notesModel.count+2; i++) {
                compare(notesModel.get(i-2).text, defaultNotes[i])
            }
        }
    }
}
