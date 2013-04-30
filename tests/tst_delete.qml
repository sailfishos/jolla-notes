// Test that notes can be deleted from the overview or the note page

import QtQuickTest 1.0
import QtQuick 1.1
import Sailfish.Silica 1.0
import "/usr/share/jolla-notes"
import "."

Notes {
    id: main

    NotesTestCase {
        name: "DeleteNote"
        when: windowShown

        property variant notes

        function initTestCase() {
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
            var remorse = wait_find("remorse item started", main,
                                    function (it) {
                return it.text == "notes-la-deleting"
                       && it.visible && it.opacity == 1.0
            })
            fastforward_remorseitem(remorse)

            // Check that the note has been deleted
            wait_for("note item gone from overview", function () {
                return !find_text(main, notetext)
            })
            compare(notesModel.count, old_count-1, "a note has been deleted")
            for (var i = 0; i < notesModel.count; i++) {
                if (notesModel.get(i).text == notetext)
                    fail("note deleted from model")
            }
        }

        function test_delete_from_notepage() {
            var old_count = notesModel.count

            var item = find_text(main, notes[2])
            click_center(item)
            wait_pagestack("note page opened", 2)

            select_pull_down("notes-me-delete-note")
            wait_pagestack("note page closed", 1)

            check_deletion(old_count, notes[2])
            // @todo: without this delay the next testcase deletes the wrong note
            // Figure out what we really need to wait for
            wait(1000)
        }

        function test_delete_from_overview() {
            var old_count = notesModel.count

            var item = find_text(main, notes[3])
            longclick_center(item)

            // Context menu should now be open

            var action = find_text(main, "notes-la-delete")
            verify_displayed(action, "context menu delete note action")
            click_center(action)

            check_deletion(old_count, notes[3])
        }

        function cleanupTestCase() {
            clear_db()
        }
    }
}
