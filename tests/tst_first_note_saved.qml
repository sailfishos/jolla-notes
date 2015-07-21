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

// Test that the note written in tst_first_note was saved and is still there

import QtTest 1.0
import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../../usr/share/jolla-notes" as JollaNotes
import "."

JollaNotes.Notes {
    id: main

    NotesTestCase {
        name: "FirstNoteSaved"
        when: windowShown

        function init() {
            activate()
            tryCompare(main, 'applicationActive', true)
        }

        function test_note_saved() {
            var item = find_text(currentPage, "hello")
            verify_displayed(item, "saved note")
        }

        function test_text_placement() {
            // Test for regression of a bug where newly created notes
            // had their text displayed too far down in the note items.
            make_notes_fixture(["bye"])

            go_back()
            wait_pagestack("note page closed", 1)

            var old_item = find_text(currentPage, "hello")
            var new_item = find_text(currentPage, "bye")
            verify(old_item, "saved item found")
            verify(new_item, "newly written item found")

            var old_text = find_real_text(old_item, "hello")
            var new_text = find_real_text(new_item, "bye")
            verify(old_text, "saved item text found")
            verify(new_text, "newly written item text found")

            compare(old_text.y, new_text.y)
        }
    }
}
