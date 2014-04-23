// Test opening and closing of the context menu
//FIXTURE: defaultnotes

import QtTest 1.0
import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../../usr/share/jolla-notes" as JollaNotes
import "."

JollaNotes.Notes {
    id: main

    NotesTestCase {
        name: "ContextMenu"
        when: windowShown

        property variant notes
        property variant itemlocs

        function init() {
            activate()
            tryCompare(main, 'applicationActive', true)
        }

        function initTestCase() {
            // Remember the starting positions of the items
            var items = verify_find_text_items(currentPage, defaultNotes)
            var locs = []
            for (var i = 0; i < items.length; i++) {
                locs.push(main.mapFromItem(items[i], 0, 0))
            }
            // first build the array and then assign to the property.
            // pushing elements to the property directly doesn't work.
            itemlocs = locs
        }

        function test_menu() {
            var items = verify_find_text_items(currentPage, defaultNotes)

            var old_height = items[1].height
            verify_displayed(items[1], "note '" + defaultNotes[1] + "'")
            longclick_center(items[1])
            // Context menu should now have opened. Check that:
            // 1. all other delegates are faded and disabled
            for (var i = 0; i < items.length; i++) {
                if (i == 1) {
                    verify(items[i].enabled, "selected item still enabled")
                    verify(items[i].highlighted, "selected item is highlighted")
                    verify_displayed(items[i], "selected item")
                } else {
                    verify(!items[i].highlighted,
                            " non-selected item not highlighted")
                }
            }

            // 2. the context menu spans the width of the grid view
            var menu = find_context_menu(currentPage)
            verify(menu, "context menu found")
            var grid = find_flickable_parent(menu)
            var menux = grid.mapFromItem(menu, 0, 0).x
            compare(menux, 0, "contextmenu spans grid view")
            compare(menu.width, grid.width, "contextmenu spans grid view")

            // 3. delegates under the first row have moved down to make
            //    room for the context menu
            // Try not to get too involved in implementation details.
            // Pick out the actual text elements and make sure none of
            // them overlap the context menu or each other.
            var checkitems = []
            verify_displayed(menu, "context menu")
            checkitems.push(menu)
            for (var i = 0; i < defaultNotes.length; i++) {
                var checkitem = find_real_text(items[i], defaultNotes[i])
                verify_displayed(checkitem, "note '" + defaultNotes[i] + "'")
                checkitems.push(checkitem)
            }
            var ov = overlap(grid.contentItem, checkitems)
            if (ov.length > 0) {
                if (ov[0] == 0)
                    fail("overlap between note " + ov[1] + " and menu")
                else
                    fail("overlap between notes " + ov[0] + " and " + ov[1])
            }

            var action = find_text(menu, "notes-la-move-to-top")
            verify(action, "move-to-top action found")

            click_center(action)

            var old_pos = main.mapFromItem(items[1], 0, 0)
            wait_for("note moved", function() {
                var new_pos = main.mapFromItem(items[1], 0, 0)
                return old_pos.x != new_pos.x || old_pos.y != new_pos.y
            })

            // Check that notes 0 and 1 changed places
            var notemap = {}
            notemap[0] = 1
            notemap[1] = 0
            for (var i = 2; i < defaultNotes.length; i++) {
                notemap[i] = i
            }

            for (var i = 0; i < defaultNotes.length; i++) {
                var pos = main.mapFromItem(items[i], 0, 0)
                compare(pos, itemlocs[notemap[i]],
                        "note '" + defaultNotes[i] + "' moved to index " + notemap[i])
                compare(notesModel.get(notemap[i]).text, defaultNotes[i],
                        "note '" + defaultNotes[i] + "' at index " + notemap[i] + " in database")
            }
        }

        function test_menu_try_again() {
            // Regression test for a bug where the context menu would open on
            // an incorrect item when reopened after "move to top"
            var item = find_text(currentPage, defaultNotes[3])
            verify_displayed(item, "note '" + defaultNotes[3] + "'")

            longclick_center(item)

            var menu = find_context_menu(currentPage)
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
