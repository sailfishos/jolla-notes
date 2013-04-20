// Test that note items are visible in the overview,
// with tint, page number and color tag.

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
        name: "NoteGrid"
        when: windowShown

        function test_noteitems() {
            var notes = ["Foo", "Bar", "Gnu", "Xyzzy"]
            compare(notesModel.count, 0)
            make_notes_fixture(notes)
            compare(notesModel.count, notes.length)

            pagestackspy.clear()
            select_pull_down("notes-me-overview")
            pagestackspy.wait()
            wait_inputpanel_closed()

            for (var i = 0; i < notes.length; i++) {
                var pgnr = "" + (i+1)
                var item = find(main, { "text": notes[i] })
                verify_displayed(item, "noteitem " + pgnr)
                verify_displayed(find(item, { "text": pgnr }),
                                 "page number " + pgnr)
                verify_displayed(find(item,
                                   { "width": 64 , "color": item.color }),
                                "color bar " + pgnr)
                // @todo: verify tint
            }
        }

        function cleanupTestCase() {
            clear_db()
        }
    }
}
