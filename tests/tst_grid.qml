// Test that note items are visible in the overview,
// with tint, page number and color tag.

import QtQuickTest 1.0
import QtQuick 1.1
import Sailfish.Silica 1.0
import "/usr/share/jolla-notes"
import "."

Notes {
    id: main

    NotesTestCase {
        name: "NoteGrid"
        when: windowShown

        function test_noteitems() {
            var notes = ["Foo", "Bar", "Gnu", "Xyzzy"]
            compare(notesModel.count, 0)
            make_notes_fixture(notes)

            select_pull_down("notes-me-overview")
            wait_pagestack("note page closed", 1)
            wait_inputpanel_closed()

            for (var i = 0; i < notes.length; i++) {
                var pgnr = "" + (i+1)
                var item = find_text(main, notes[i])
                verify_displayed(item, "noteitem " + pgnr)
                verify_displayed(find_text(item, pgnr), "page number " + pgnr)
                var colorbar = find(item, function(it) {
                    return it.width == 64 && it.color == item.color
                })
                verify_displayed(colorbar, "color bar " + pgnr)
                // @todo: verify tint
            }
        }

        function cleanupTestCase() {
            clear_db()
        }
    }
}
