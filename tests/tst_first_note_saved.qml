// Test that the note written in tst_first_note was saved and is still there

import QtQuickTest 1.0
import QtQuick 1.1
import Sailfish.Silica 1.0
import "/usr/share/jolla-notes"
import "."

Notes {
    id: main

    SignalSpy {
        id: pagestackspy

        target: main.pageStack
        signalName: "depthChanged"
    }


    NotesTestCase {
        name: "FirstNoteSaved"
        when: windowShown

        function test_note_saved() {
            var item = find(main, { "text": "hello" })
            verify_displayed(item, "saved note")
        }

        function test_text_placement() {
            // Test for regression of a bug where newly created notes
            // had their text displayed too far down in the note items.
            make_notes_fixture(["bye"])

            pagestackspy.clear()
            select_pull_down("notes-me-overview")
            pagestackspy.wait()
            while (pageStack.busy)
                wait(50)
            compare(pageStack.depth, 1, "note page closed")

            var old_item = find(main, { "text": "hello" })
            var new_item = find(main, { "text": "bye" })
            verify(old_item, "saved item found")
            verify(new_item, "newly written item found")

            var old_text = find(old_item, { "text": "hello" }, "Text")
            var new_text = find(new_item, { "text": "bye" }, "Text")
            verify(old_text, "saved item text found")
            verify(new_text, "newly written item text found")

            compare(old_text.y, new_text.y)
        }

        function cleanupTestCase() {
            clear_db()
        }
    }
}
