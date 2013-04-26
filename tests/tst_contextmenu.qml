// Test opening and closing of the context menu

import QtQuickTest 1.0
import QtQuick 1.1
import Sailfish.Silica 1.0
import "/usr/share/jolla-notes"
import "."

Notes {
    id: main

    NotesTestCase {
        name: "ContextMenu"
        when: windowShown

        property variant notes

        function initTestCase() {
            notes = ["Frame", "Note1", "Note2", "Sentinel"]
            compare(notesModel.count, 0)
            make_notes_fixture(notes)

            select_pull_down("notes-me-overview")
            wait_pagestack("note page closed", 1)
            wait_inputpanel_closed()
        }

        function test_menu() {
            var items = []
            for (var i = 0; i < notes.length; i++) {
                var item = verify_find(main, { "text": notes[i] })
                items.push(item)
            }

            var old_height = items[1].height
            verify_displayed(items[1])
            longclick_center(items[1])
            // Context menu should now have opened. Check that:
            // 1. all other delegates are faded and disabled
            for (var i = 0; i < items.length; i++) {
                if (i == 1) {
                    verify(items[i].enabled, "selected item still enabled")
                    verify(items[i].highlighted, "selected item is highlighted")
                    verify_displayed(items[i], "selected item")
                } else {
                    verify(!item.enabled, " non-selected item disabled")
                    verify(!item.highlighted, " non-selected item not highlighted")
                }
            }

            // 2. the context menu spans the width of the grid view
            var grid = verify_find(main, {}, "SilicaGridView")
            var menu = verify_find(main, {}, "ContextMenu")
            var menux = grid.mapFromItem(menu.parent, menu.x, menu.y).x
            compare(menux, 0, "contextmenu spans grid view")
            compare(menu.width, grid.width, "contextmenu spans grid view")

            // 3. delegates under the first row have moved down to make
            //    room for the context menu
            verify_displayed(menu)
            // Try not to get too involved in implementation details.
            // Pick out the actual text elements and make sure none of
            // them overlap the context menu or each other.
            var checkitems = []
            checkitems.push(menu)
            for (var i = 0; i < notes.length; i++) {
                var checkitem = find(items[i], { "text": notes[i] }, "Text")
                verify_displayed(checkitem)
                checkitems.push(checkitem)
            }
            var ov = overlap(grid.contentItem, checkitems)
            if (ov.length > 0) {
                if (ov[0] == 0)
                    fail("overlap between note " + ov[1] + " and menu")
                else
                    fail("overlap between notes " + ov[0] + " and " + ov[1])
            }

            // Leave context menu open for next test
        }

        function test_menu_click() {
            var menu = verify_find(main, {}, "ContextMenu")
            var action = verify_find(menu, { "text": "notes-la-move-to-top" })
            click_center(action)

            wait(1)
            verify(!menu || !menu.visible, "menu closed immediately")

            // Check that notes 0 and 1 changed places
            var notemap = {}
            notemap[0] = 1
            notemap[1] = 0
            for (var i = 2; i < notes.length; i++) {
                notemap[i] = i
            }
            for (var i = 0; i < notes.length; i++) {
                var item = find(main, { "text": notes[i] })
                compare(item.index, notemap[i],
                        "note '" + notes[i] + "' moved to index " + i)
                compare(notesModel.get(notemap[i]).text, notes[i],
                        "note '" + notes[i] + "' at index " + i + " in database")
            }
        }

        function test_menu_try_again() {
            // Regression test for a bug where the context menu would open on
            // an incorrect item when reopened after "move to top"
            var item = find(main, { "text": notes[3] })
            verify_displayed(item)

            longclick_center(item)

            var menu = find(main, {}, "ContextMenu")
            if (!menu)
                fail("context menu did not open on second use")
            if (!item.highlighted)
                fail("Context menu opened on wrong item")
        }

        function cleanupTestCase() {
            clear_db()
        }
    }
}
