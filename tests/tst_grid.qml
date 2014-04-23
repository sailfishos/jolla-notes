// Test that note items are visible in the overview,
// with tint, page number and color tag.
//FIXTURE: defaultnotes

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
            // Colors from silica colorpicker
            var colors = ["#cc0000", "#cc7700", "#ccbb00", "#88cc00", "#00b315"]
            colors.reverse() // makes_notes_fixture works backward

            for (var i = 0; i < defaultNotes.length; i++) {
                var pgnr = "" + (i+1)
                var item = find_text(currentPage, defaultNotes[i])
                verify_displayed(item, "noteitem " + pgnr)
                verify_displayed(find_text(item, pgnr), "page number " + pgnr)
                var colorbar = find_by_testname(item, "colortag")
                compare(colorbar.color, colors[i], "note " + pgnr + " color")
                verify_displayed(colorbar, "color bar " + pgnr)
                // @todo: verify tint
            }
        }
    }
}
