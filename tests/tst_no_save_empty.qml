// SPDX-FileCopyrightText: 2013 - 2015 Jolla Ltd.
// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

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
