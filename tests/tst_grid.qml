// SPDX-FileCopyrightText: 2013 - 2017 Jolla Ltd.
// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

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
            for (var i = 0; i < defaultNotes.length; i++) {
                var pgnr = "" + (i+1)
                var item = find_text(currentPage, defaultNotes[i])
                verify_displayed(item, "noteitem " + pgnr)
                verify_displayed(find_text(item, pgnr), "page number " + pgnr)
            }
        }
    }
}
