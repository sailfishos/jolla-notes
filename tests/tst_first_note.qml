// Test that app is empty on startup, has comforter text on the overview,
// and allows tapping to write a new note.

import QtQuickTest 1.0
import QtQuick 1.1
import Sailfish.Silica 1.0
import "/usr/share/jolla-notes"
import "driver.js" as T

Notes {
    id: main

    TestCase {
        name: "FirstNote"
        when: windowShown

        function test_comforter() {
            var comforter = T.find(main, { "text": "notes-la-tap-to-write" })
            verify(T.displayed(comforter),
                   "Tap-to-write text is displayed on empty overview")
        }
    }
}
