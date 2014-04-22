// Helper file to create a default set of notes for use by the tests.
// The runtest script will only run this once and store the resulting
// database, so that it can re-use it for all tests that need the fixture.

import QtTest 1.0
import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../../usr/share/jolla-notes" as JollaNotes
import "."

JollaNotes.Notes {
    id: main

    NotesTestCase {
        name: "MakeFixture"
        when: windowShown

        function init() {
            activate()
            tryCompare(main, 'applicationActive', true)
        }

        function initTestCase() {
            compare(notesModel.count, 0)
            make_notes_fixture(defaultNotes)
        }
    }
}
