/*
 * Copyright (C) 2012-2015 Jolla Ltd.
 *
 * The code in this file is distributed under multiple licenses, and as such,
 * may be used under any one of the following licenses:
 *
 *   - GNU General Public License as published by the Free Software Foundation;
 *     either version 2 of the License (see LICENSE.GPLv2 in the root directory
 *     for full terms), or (at your option) any later version.
 *   - GNU Lesser General Public License as published by the Free Software
 *     Foundation; either version 2.1 of the License (see LICENSE.LGPLv21 in the
 *     root directory for full terms), or (at your option) any later version.
 *   - Alternatively, if you have a commercial license agreement with Jolla Ltd,
 *     you may use the code under the terms of that license instead.
 *
 * You can visit <https://sailfishos.org/legal/> for more information
 */

// Test that app is empty on startup, has comforter text on the overview,
// and it's possible to write a note
//FIXTURE: empty

import QtTest 1.0
import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../../usr/share/jolla-notes" as JollaNotes
import "."

JollaNotes.Notes {
    id: main

    NotesTestCase {
        name: "FirstNote"
        when: windowShown

        function init() {
            activate()
            tryCompare(main, 'applicationActive', true)
        }

        function test_0_opens_on_notepage() {
            compare(notesModel.count, 0) // precondition for this test

            // When Notes starts with an empty db, it should open a new
            // note automatically so that the user can start typing right away
            wait_pagestack("new note page opened", 2)
            compare(currentPage.text, '', "first note page is empty")

            // The first note should be ready to write
            wait_inputpanel_open()

            // back to overview for the rest of the tests
            go_back()
            wait_pagestack("note page closed", 1)
        }

        function test_1_comforter() {
            compare(notesModel.count, 0) // precondition for this test
            var comforter = find_text(currentPage, "notes-la-overview-placeholder")
            verify_displayed(comforter, "Write-note text on empty overview")
        }

        function test_2_tap_to_write() {
            select_pull_down("notes-me-new-note")
            wait_pagestack("new note page opened", 2)
            compare(currentPage.text, '', "new note page is empty")

            wait_inputpanel_open()
        }

        function test_3_write_note() {
            keyClick(Qt.Key_H)
            keyClick(Qt.Key_E)
            keyClick(Qt.Key_L)
            keyClick(Qt.Key_L)
            keyClick(Qt.Key_O)

            tryCompare(currentPage, 'text', "hello")
            // The current implementation is to not save the note until
            // the user stops typing, for performance reasons.
            // Make sure it happens eventually.
            wait(6000) // give timer time to run out
            wait(100) // then a chance to run
            compare(notesModel.count, 1,
                    "note saved after text was typed")
        }

        function test_4_back() {
            go_back()
            wait_pagestack("note page closed", 1)
        }

        function test_5_no_comforter() {
            var comforter = find_text(currentPage, "notes-la-overview-placeholder")
            if (comforter) {
                wait_for("write-note text went away when note was written",
                         function() {
                    return !visible(comforter)
                })
            }
        }

        function test_6_no_tap_to_write() {
            // give it time to adjust to losing the keyboard
            // TODO: some way to wait on "currentPage.height" would be nice
            wait_animation_stop(currentPage)
            click_center(currentPage)
            // This is a bit arbitrary... how long should we wait
            // to check that something didn't happen?
            // (spying the "clicked" signal would work but that's
            // implementation-dependent.)
            wait(200)
            compare(pageStack.depth, 1, "tap-to-write was ignored")
        }

        // The note is left in the db for the tst_first_note_saved.qml test
    }
}
