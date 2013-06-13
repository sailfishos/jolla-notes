// Test the app cover
// The cover actions will be tested with the robot for now.

import QtTest 1.0
import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../../usr/share/jolla-notes" as JollaNotes
import "."

JollaNotes.Notes {
    id: main

    NotesTestCase {
        name: "AppCover"
        when: windowShown

        function initTestCase() {
            clear_db()

            activate()
            tryCompare(main, 'applicationActive', true)

            var notes = ["Alpha", "Beta"]

            compare(notesModel.count, 0)
            make_notes_fixture(notes)

            // leave the app at the Beta notepage
        }

        function test_cover_text() {
            main.deactivate()
            var cover = wait_for("cover page created", function() {
                return main._coverObject
            })
            wait_for("application cover visible", function() {
                return cover.visible
            })
            var text = find_text(cover, "Beta")
            verify(text, "cover shows current note text")
        }

        function cleanupTestCase() {
            clear_db()
        }
    }
}
