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
