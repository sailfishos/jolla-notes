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

// Test the app cover
// The cover actions will be tested with the robot for now.
//FIXTURE: defaultnotes

import QtTest 1.0
import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../../usr/share/jolla-notes" as JollaNotes
import "."

JollaNotes.Notes {
    id: main

    NotesTestCase {
        name: "AppCover"
        when: windowShown

        function init() {
            activate()
            tryCompare(main, 'applicationActive', true)
        }

        function test_cover_text() {
            // Click a note to open it
            var chosen = defaultNotes[2]
            var item = find_text(currentPage, chosen)
            verify(item, "Note '" + chosen + "' found")
            click_center(item)
            wait_pagestack("note page opened", 2)

            // Go to home screen
            main.deactivate()
            var cover = wait_for("cover page created", function() {
                return main._coverObject
            })
            wait_for("application cover visible", function() {
                return cover.visible
            })
            var text = find_text(cover, chosen)
            verify(text, "cover shows current note text")
        }
    }
}
