// Test that notes can be deleted from the overview or the note page

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

        property variant notes

        function init() {
            activate()
            tryCompare(main, 'applicationActive', true)
        }

        function initTestCase() {
            activate()
            tryCompare(main, 'applicationActive', true)

            notes = ["Fear", "Surprise", "Ruthless efficiency",
                         "Fanatical devotion", "Nice red uniforms"]
            compare(notesModel.count, 0)
            make_notes_fixture(notes)

            select_pull_down("notes-me-overview")
            wait_pagestack("note page closed", 1)
            wait_inputpanel_closed()
            // Leave app at overview
        }

        function check_deletion(old_count, notetext) {
            var remorse = wait_find("remorse item started", currentPage,
                                    function (it) {
                return it.text == "notes-la-deleting"
                       && it.visible && it.opacity == 1.0
            })
            fastforward_remorseitem(remorse)

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

            var item = find_text(currentPage, notes[2])
            verify(item, "Note '" + notes[2] + "' found")
            click_center(item)
            wait_pagestack("note page opened", 2)

            select_pull_down("notes-me-delete-note")
            wait_pagestack("note page closed", 1)

            check_deletion(old_count, notes[2])
        }

        function test_delete_from_overview() {
            var old_count = notesModel.count

            var item = find_text(currentPage, notes[3])
            verify(item, "Note '" + notes[3] + "' found")
            longclick_center(item)

            // Context menu should now be open

            var action = find_text(currentPage, "notes-la-delete")
            verify_displayed(action, "context menu delete note action")
            click_center(action)

            check_deletion(old_count, notes[3])
        }

        function test_delete_by_emptying() {
            var old_count = notesModel.count

            var item = find_text(currentPage, notes[1])
            verify(item, "Note '" + notes[1] + "' found")
            click_center(item)
            wait_pagestack("note page opened", 2)

            click_center(currentPage)
            wait_inputpanel_open()

            for (var i = notes[1].length; i > 0; i--)
                keyPress(Qt.Key_Backspace)
            compare(item.text, '', "message empty")

            select_pull_down("notes-me-overview")
            wait_pagestack("back to overview", 1)

            verify(!find_text(currentPage, notes[1]),
                   "note item gone from overview")
            compare(notesModel.count, old_count-1, "note has been deleted")
            for (var i = 0; i < notesModel.count; i++) {
                if (notesModel.get(i).text == notes[1])
                    fail("note deleted from model")
            }
        }

        function cleanupTestCase() {
            clear_db()
        }
    }
}
