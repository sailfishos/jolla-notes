// Test that app is empty on startup, has comforter text on the overview,
// and allows tapping to write a new note.

import QtQuickTest 1.0
import QtQuick 1.1
import Sailfish.Silica 1.0
import "/usr/share/jolla-notes"
import "."

Notes {
    id: main

    NotesTestCase {
        name: "FirstNote"
        when: windowShown

        function test_1_comforter() {
            compare(notesModel.count, 0) // precondition for this test
            var comforter = find(main, { "text": "notes-la-tap-to-write" })
            verify_displayed(comforter, "Tap-to-write text on empty overview")
        }

        function test_2_tap_to_write() {
            // use page height as a proxy to detect if the keyboard is open
            var old_height = pageStack.currentPage.height

            click_center(pageStack.currentPage)
            wait_pagestack("new note page opened", 2)
            compare(pageStack.currentPage.text, '', "new note page is empty")

            wait_inputpanel_open()
        }

        function test_3_write_note() {
            keyClick(Qt.Key_H)
            keyClick(Qt.Key_E)
            keyClick(Qt.Key_L)
            keyClick(Qt.Key_L)
            keyClick(Qt.Key_O)
            compare(pageStack.currentPage.text, "hello",
                    "typed text went into note")
        }

        function test_4_back() {
            select_pull_down("notes-me-overview")
            wait_pagestack("note page closed", 1)
        }

        function test_5_no_comforter() {
            var comforter = find(main,
                      { "text": "notes-la-tap-to-write", "visible": true })
            compare(comforter, undefined,
                   "No tap-to-write text when note has been written")
        }

        // The note is left for the tst_note_saved.qml test
    }
}
