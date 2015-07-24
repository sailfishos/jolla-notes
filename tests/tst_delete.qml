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

// Test that notes can be deleted from the overview or the note page
//FIXTURE: defaultnotes

import QtTest 1.0
import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../../usr/share/jolla-notes" as JollaNotes
import "."

JollaNotes.Notes {
    id: main

    NotesTestCase {
        name: "DeleteNote"
        when: windowShown

        function init() {
            activate()
            tryCompare(main, 'applicationActive', true)
        }

        function test_delete_from_notepage() {
            var old_count = notesModel.count
            var note = defaultNotes[2]

            var item = find_text(currentPage, note)
            verify(item, "Note '" + note + "' found")
            click_center(item)
            wait_pagestack("note page opened", 2)

            select_pull_down("notes-me-delete-note")
            wait_pagestack("note page closed", 1)

            check_remorse()
            check_deletion(old_count, note)
        }

        function test_delete_from_overview() {
            var old_count = notesModel.count
            var note = defaultNotes[3]

            var item = find_text(currentPage, note)
            verify(item, "Note '" + note + "' found")
            longclick_center(item)

            // Context menu should now be open

            var action = find_text(currentPage, "notes-la-delete")
            verify_displayed(action, "context menu delete note action")
            click_center(action)

            check_remorse()
            check_deletion(old_count, note)
        }

        function test_delete_by_emptying() {
            var old_count = notesModel.count
            var note = defaultNotes[1]

            var item = find_text(currentPage, note)
            verify(item, "Note '" + note + "' found")
            click_center(item)
            wait_pagestack("note page opened", 2)

            click_center(currentPage)
            wait_inputpanel_open()

            for (var i = note.length; i > 0; i--)
                keyPress(Qt.Key_Backspace)
            compare(currentPage.text, '', "message empty")

            go_back()
            wait_pagestack("back to overview", 1)

            check_deletion(old_count, note)
        }

        function test_delete_emptied_note() {
            // Emptying a note and then deleting it from the menu used
            // to crash the app. This is a regression test for that.
            var old_count = notesModel.count
            var note = defaultNotes[0]

            var item = find_text(currentPage, note)
            verify(item, "Note '" + note + "' found")
            click_center(item)
            wait_pagestack("note page opened", 2)

            click_center(currentPage)
            wait_inputpanel_open()

            for (var i = note.length; i > 0; i--)
                keyPress(Qt.Key_Backspace)
            compare(currentPage.text, '', "message empty")

            select_pull_down("notes-me-delete-note")
            wait_pagestack("note page closed", 1)

            check_deletion(old_count, note)
        }
    }
}
