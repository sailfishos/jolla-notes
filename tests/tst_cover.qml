// Test the app cover
// The cover actions will be tested with the robot for now.

import QtQuickTest 1.0
import QtQuick 1.1
import Sailfish.Silica 1.0
import "/usr/share/jolla-notes"
import "."

Notes {
    id: main

    NotesTestCase {
        name: "AppCover"
        when: windowShown

        function initTestCase() {
            var notes = ["Alpha", "Beta"]

            compare(notesModel.count, 0)
            make_notes_fixture(notes)
            compare(notesModel.count, notes.length)

            // leave the app at the Beta notepage
        }

        function test_cover_text() {
            main.deactivate()
            var cover = wait_find(main, { "objectName": "coverpage" })
            wait_for(function() { cover.visible }, "application cover visible")
            var text = find(cover, { "text": "Beta" })
            verify(text, "cover shows current note text")
        }

        function cleanupTestCase() {
            clear_db()
        }
    }
}
