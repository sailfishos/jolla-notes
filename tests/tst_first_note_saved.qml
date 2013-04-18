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
            var item = find(main, { "text": "hello" })
            verify_displayed(item, "saved note")
        }

        function cleanupTestCase() {
            clear_db()
        }
    }
}
