// Test that note items are visible in the overview,
// with tint, page number and color tag.

import QtTest 1.0
import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../../usr/share/jolla-notes" as JollaNotes
import "."

JollaNotes.Notes {
    id: main

    NotesTestCase {
        name: "NoteGrid"
        when: windowShown

        function init() {
            activate()
            tryCompare(main, 'applicationActive', true)
        }

        function test_noteitems() {
            var notes = ["Foo", "Bar", "Gnu", "Xyzzy"]

            compare(notesModel.count, 0)
            make_notes_fixture(notes)

            select_pull_down("notes-me-overview")
            wait_pagestack("note page closed", 1)
            wait_inputpanel_closed()

            // from availableColors in notes.js
            var colors = ['#ff0000', '#ff8000', '#ffff00', '#73e600']

            for (var i = 0; i < notes.length; i++) {
                var pgnr = "" + (i+1)
                var item = find_text(currentPage, notes[i])
                verify_displayed(item, "noteitem " + pgnr)
                verify_displayed(find_text(item, pgnr), "page number " + pgnr)
                var colorbar = find_by_testname(item, "colortag")
                compare(colorbar.color, colors[i], "note " + pgnr + " color")
                verify_displayed(colorbar, "color bar " + pgnr)
                // @todo: verify tint
            }
        }

        function cleanupTestCase() {
            clear_db()
        }
    }
}
