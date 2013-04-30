// Test that the note written in tst_first_note was saved and is still there

import QtQuickTest 1.0
import QtQuick 1.1
import Sailfish.Silica 1.0
import "/usr/share/jolla-notes"
import "."

Notes {
    id: main

    NotesTestCase {
        name: "FirstNoteSaved"
        when: windowShown

        function test_note_saved() {
            var item = find_text(main, "hello")
            verify_displayed(item, "saved note")
        }

        function test_text_placement() {
            // Test for regression of a bug where newly created notes
            // had their text displayed too far down in the note items.
            make_notes_fixture(["bye"])

            select_pull_down("notes-me-overview")
            wait_pagestack("note page closed", 1)

            var old_item = find_text(main, "hello")
            var new_item = find_text(main, "bye")
            verify(old_item, "saved item found")
            verify(new_item, "newly written item found")

            var old_text = find_real_text(old_item, "hello")
            var new_text = find_real_text(new_item, "bye")
            verify(old_text, "saved item text found")
            verify(new_text, "newly written item text found")

            compare(old_text.y, new_text.y)
        }

        function cleanupTestCase() {
            clear_db()
        }
    }
}
