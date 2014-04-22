// Test that notes can be deleted from the overview or the note page
//FIXTURE: defaultnotes

import QtTest 1.0
import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../../usr/share/jolla-notes" as JollaNotes
import "."

JollaNotes.Notes {
    id: main

    NotesTestCase {
        name: "DeleteNote"
        when: windowShown

        function init() {
            activate()
            tryCompare(main, 'applicationActive', true)
        }

        function check_remorse() {
            var remorse = wait_find("remorse item started", currentPage,
                                    function (it) {
                return it.text == "notes-la-deleting"
                       && it.visible && it.opacity == 1.0
            })
            fastforward_remorseitem(remorse)
        }

        function check_deletion(old_count, notetext) {
            // Check that the note has been deleted
            wait_for("note item gone from overview", function () {
                return !find_text(currentPage, notetext)
            })
            compare(notesModel.count, old_count-1, "a note has been deleted")
            for (var i = 0; i < notesModel.count; i++) {
                if (notesModel.get(i).text == notetext)
                    fail("note deleted from model")
            }
        }

        function test_delete_from_notepage() {
            var old_count = notesModel.count
            var note = defaultNotes[2]

            var item = find_text(currentPage, note)
            verify(item, "Note '" + note + "' found")
            click_center(item)
            wait_pagestack("note page opened", 2)

            select_pull_down("notes-me-delete-note")
            wait_pagestack("note page closed", 1)

            check_remorse()
            check_deletion(old_count, note)
        }

        function test_delete_from_overview() {
            var old_count = notesModel.count
            var note = defaultNotes[3]

            var item = find_text(currentPage, note)
            verify(item, "Note '" + note + "' found")
            longclick_center(item)

            // Context menu should now be open

            var action = find_text(currentPage, "notes-la-delete")
            verify_displayed(action, "context menu delete note action")
            click_center(action)

            check_remorse()
            check_deletion(old_count, note)
        }

        function test_delete_by_emptying() {
            var old_count = notesModel.count
            var note = defaultNotes[1]

            var item = find_text(currentPage, note)
            verify(item, "Note '" + note + "' found")
            click_center(item)
            wait_pagestack("note page opened", 2)

            click_center(currentPage)
            wait_inputpanel_open()

            for (var i = note.length; i > 0; i--)
                keyPress(Qt.Key_Backspace)
            compare(currentPage.text, '', "message empty")

            go_back()
            wait_pagestack("back to overview", 1)

            check_deletion(old_count, note)
        }

        function test_delete_emptied_note() {
            // Emptying a note and then deleting it from the menu used
            // to crash the app. This is a regression test for that.
            var old_count = notesModel.count
            var note = defaultNotes[0]

            var item = find_text(currentPage, note)
            verify(item, "Note '" + note + "' found")
            click_center(item)
            wait_pagestack("note page opened", 2)

            click_center(currentPage)
            wait_inputpanel_open()

            for (var i = note.length; i > 0; i--)
                keyPress(Qt.Key_Backspace)
            compare(currentPage.text, '', "message empty")

            select_pull_down("notes-me-delete-note")
            wait_pagestack("note page closed", 1)

            check_deletion(old_count, note)
        }
    }
}
