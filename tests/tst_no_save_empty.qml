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

// Test that empty notes are not saved
//FIXTURE: empty

import QtTest 1.0
import QtQuick 2.0
import Sailfish.Silica 1.0

import "../../../usr/share/jolla-notes" as JollaNotes
import "."

JollaNotes.Notes {
    id: main

    NotesTestCase {
        name: "NoSaveEmpty"
        when: windowShown

        function init() {
            activate()
            tryCompare(main, 'applicationActive', true)

            // With an empty db, Notes will start with a new note page open
            // Most of these tests need to start from the overview so make
            // that the initial state.
            go_back()
            wait_pagestack("back to overview", 1)
        }

        function test_empty_not_saved() {
            select_pull_down("notes-me-new-note")
            wait_pagestack("new note page", 2)
            wait_inputpanel_open()

            go_back()
            wait_pagestack("back to overview", 1)

            compare(notesModel.count, 0,
                    "empty note was not saved")
        }

        function test_new_from_empty() {
            select_pull_down("notes-me-new-note")
            wait_pagestack("new note page", 2)
            wait_inputpanel_open()

            select_pull_down("notes-me-new-note")
            wait_animation_stop(pageStack)

            go_back()
            wait_pagestack("back to overview", 1)

            compare(notesModel.count, 0,
                    "empty note was not saved")
        }

        function test_new_from_empty_2() {
            select_pull_down("notes-me-new-note")
            wait_pagestack("new note page", 2)
            wait_inputpanel_open()

            select_pull_down("notes-me-new-note")
            wait_animation_stop(pageStack)

            keyClick(Qt.Key_N)
            keyClick(Qt.Key_E)
            keyClick(Qt.Key_W)

            go_back()
            wait_pagestack("back to overview", 1)
            wait_inputpanel_closed()

            var item = find_text(currentPage, "new")
            verify_displayed(item, "new note item")
        }

        function test_space_is_empty() {
            var oldcount = notesModel.count

            select_pull_down("notes-me-new-note")
            wait_pagestack("new note page", 2)
            wait_inputpanel_open()

            keyPress(Qt.Key_Space)
            verify(find_text(currentPage, " "),
                   "space char went into note")

            go_back()
            wait_pagestack("back to overview", 1)

            compare(notesModel.count, oldcount,
                    "whitespace note was not saved")
        }
    }
}
