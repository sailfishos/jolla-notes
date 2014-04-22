// Test that app is empty on startup, has comforter text on the overview,
// and it's possible to write a note
//FIXTURE: empty

import QtTest 1.0
import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../../usr/share/jolla-notes" as JollaNotes
import "."

JollaNotes.Notes {
    id: main

    NotesTestCase {
        name: "FirstNote"
        when: windowShown

        function init() {
            activate()
            tryCompare(main, 'applicationActive', true)
        }

        function test_1_comforter() {
            compare(notesModel.count, 0) // precondition for this test
            var comforter = find_text(currentPage, "notes-la-write-note")
            verify_displayed(comforter, "Write-note text on empty overview")
        }

        function test_2_tap_to_write() {
            select_pull_down("notes-me-new-note")
            wait_pagestack("new note page opened", 2)
            compare(currentPage.text, '', "new note page is empty")

            wait_inputpanel_open()
        }

        function test_3_write_note() {
            keyClick(Qt.Key_H)
            keyClick(Qt.Key_E)
            keyClick(Qt.Key_L)
            keyClick(Qt.Key_L)
            keyClick(Qt.Key_O)

            tryCompare(currentPage, 'text', "hello")
            // The current implementation is to not save the note until
            // the user stops typing, for performance reasons.
            // Make sure it happens eventually.
            wait(6000) // give timer time to run out
            wait(100) // then a chance to run
            compare(notesModel.count, 1,
                    "note saved after text was typed")
        }

        function test_4_back() {
            go_back()
            wait_pagestack("note page closed", 1)
        }

        function test_5_no_comforter() {
            var comforter = find_text(currentPage, "notes-la-write-note")
            if (comforter) {
                wait_for("write-note text went away when note was written",
                         function() {
                    return !visible(comforter)
                })
            }
        }

        function test_6_no_tap_to_write() {
            // give it time to adjust to losing the keyboard
            // TODO: some way to wait on "currentPage.height" would be nice
            wait_animation_stop(currentPage)
            click_center(currentPage)
            // This is a bit arbitrary... how long should we wait
            // to check that something didn't happen?
            // (spying the "clicked" signal would work but that's
            // implementation-dependent.)
            wait(200)
            compare(pageStack.depth, 1, "tap-to-write was ignored")
        }

        // The note is left for the tst_note_saved.qml test
    }
}
