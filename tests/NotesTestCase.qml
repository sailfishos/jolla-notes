// Helper functions to do feature tests with QtQuickTest
// Assumption: the application window has id 'main'

import QtQuickTest 1.0

TestCase {
    SignalSpy {
        id: clickspy
        signalName: "clicked"
    }

    function clear_db() {
        var db = openDatabaseSync('silicanotes', '', 'Notes', 10000)
        db.transaction(function (tx) {
            tx.executeSql('DELETE FROM notes');
        })
    }

    function dump_item(item, name) {
        var dump = ""
        for (var key in item) {
            if (!item.hasOwnProperty(key))
                continue
            if (dump != "")
                dump += ", "
            dump += key + ": " + item[key] + " "
        }
        dump = "{ " + dump + "}"
        if (name)
            dump = name + ": " + dump
        console.log(dump)
    }

    // Return true iff item has all the specified properties with
    // corresponding values.
    // Example: matches(button, { text: "button-text" })
    function matches(item, props) {
        for (var key in props) {
            if (!props.hasOwnProperty(key))
                continue
            if (!item.hasOwnProperty(key))
                return false
            if (("" + item[key]) !== ("" + props[key]))
                return false
        }
        return true
    }

    // Find an item in item's tree that has all the specified properties
    // with corresponding values.
    function find(item, props) {
        if (matches(item, props))
            return item

        if (item.children === undefined)
            return

        for (var i = 0; i < item.children.length; i++) {
            var child = find(item.children[i], props)
            if (child !== undefined)
                return child
        }
    }

    function click_center(item) {
        var cx = item.x + item.width/2
        var cy = item.x + item.height/2
        var pos = main.mapFromItem(item, cx, cy)
        mouseClick(main, pos.x, pos.y)
    }

    // True iff the item is fully in the screen bounds
    function onscreen(item) {
        var corners = [
          main.mapFromItem(item, 0, 0),
          main.mapFromItem(item, 0, item.height - 1),
          main.mapFromItem(item, item.width - 1, 0),
          main.mapFromItem(item, item.width - 1, item.height - 1)
        ]
        for (var i = 0; i < corners.length; i++) {
            var pos = corners[i]
            if (pos.x < 0 || pos.x >= main.width)
                return false
            if (pos.y < 0 || pos.y >= main.height)
                return false
        }
        return true
    }

    // Return true iff the item and all its parents have the
    // 'visible' property true
    function visible(item) {
        while (item) {
            if (!item.visible)
                return false
            item = item.parent
        }
        return true
    }

    // Return true iff the combined opacity of the item and its parents < 0.3
    function faded(item) {
        var opacity = 1.0
        while (item) {
            opacity = opacity * item.opacity
            item = item.parent
        }
        return opacity < 0.3
    }

    function verify_displayed(item, name) {
        verify(item, name + " found")
        verify(visible(item), name + " is visible")
        verify(!faded(item), name + " is opaque")
        verify(onscreen(item), name + " is in screen bounds")
    }

    function select_pull_down(option) {
        // Refer to page instead of main, because main might
        // be rotated due to screen orientation. The coordinate
        // transformation can then be handled by mapFromItem.
        var page = main.pageStack.currentPage

        var item = find(page, { "text": option })
        verify(item, "Menu item " + option + " found")

        var drag_x = page.width / 2
        var drag_y = page.height * 0.20
        var drag_end = page.height * 0.80
        var pos = main.mapFromItem(page, drag_x, drag_y)
        mousePress(main, pos.x, pos.y)
        while (drag_y < drag_end) {
            drag_y += 10
            pos = main.mapFromItem(page, drag_x, drag_y)
            mouseMove(main, pos.x, pos.y, undefined, Qt.LeftButton)
            wait(1)
            var highlight = find(main, { "highlightedItem": item })
            if (highlight !== undefined) {
                clickspy.target = item
                mouseRelease(main, pos.x, pos.y)
                clickspy.wait()
                clickspy.target = undefined
                return
            }
        }
        mouseRelease(main, pos.x, pos.y)
        fail("Could not activate pull-down option " + option)
    }

    // Create some notes to use for other tests.
    // Ends at the last created note's page.
    function make_notes_fixture(notes) {
        for (var i = 0; i < notes.length; i++) {
            select_pull_down('notes-me-new-note')
            while (pageStack.busy)
                wait(10)
            // Wait for an empty note page
            while (!find(main, { "text": "", "placeholderText":
                                 "notes-ph-empty-note" }))
                wait(50)
            compare(pageStack.currentPage.text, '')
            pageStack.currentPage.text = notes[i]
            // Without this wait, the virtual keyboard messes up the test.
            // @todo: find a signal or property to wait for instead
            wait(1000)
        }
    }
}
