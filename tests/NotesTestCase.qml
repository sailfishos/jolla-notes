// Helper functions to do feature tests with QtQuickTest
// Assumption: the application window has id 'main'

import QtQuickTest 1.0

TestCase {
    property int timeout: 5000

    SignalSpy {
        id: clickspy
        signalName: "clicked"
    }

    SignalSpy {
        id: imsizespy
        signalName: "imSizeChanged"
        target: pageStack

        onCountChanged: {
            console.log("imSize " + pageStack.imSize + " count " + count)
        }
    }

    SignalSpy {
        id: panelsizespy
        signalName: "panelSizeChanged"
        target: pageStack

        onCountChanged: {
            console.log("panelSize " + pageStack.panelSize + " count " + count)
        }
    }

    function clear_db() {
        var db = openDatabaseSync('silicanotes', '', 'Notes', 10000)
        db.transaction(function (tx) {
            tx.executeSql('DELETE FROM notes');
        })
    }

    function debug_item(item) {
        var dump = ""
        for (var key in item) {
            if (!item.hasOwnProperty(key))
                continue
            if (dump != "")
                dump += ", "
            var value = item[key]
            dump += key + ": " + value
        }
        return "{ " + dump + " }"
    }

    function dump_item(item, name, recurse) {
        var dump = "" + item + " " + debug_item(item)
        if (name)
            dump = name + ": " + dump
        if (recurse)
            dump = "" + recurse + ". " + dump
        console.log(dump)

        if (recurse && item.children)
            for (var i = 0; i < item.children.length; i++)
                dump_item(item.children[i], name, recurse + 1)
    }

    // Return true iff item has all the specified properties with
    // corresponding values.
    // Example: matches(button, { text: "button-text" })
    function matches(item, props, itemtype) {
        if (itemtype) {
            var itype = "" + item
            itype = itype.replace(/^QDeclarative/, '')
            itype = itype.replace(/_QMLTYPE_.*/, '')
            itype = itype.replace(/\(0x[a-z0-9]*\)/, '')
            if (itype != itemtype)
                return false
        }
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
    function find(item, props, itemtype) {
        if (matches(item, props, itemtype))
            return item

        if (item.children === undefined)
            return

        for (var i = 0; i < item.children.length; i++) {
            var child = find(item.children[i], props, itemtype)
            if (child !== undefined)
                return child
        }
    }

    function wait_for(description, func) {
        var result = func()
        if (result)
            return result

        for (var delay = 0; delay < timeout; delay += 50) {
            wait(50)
            result = func()
            if (result)
                return result
        }

        fail(description)
    }

    function wait_find(description, item, props, itemtype) {
        return wait_for(description, function() {
            return find(item, props, itemtype)
        })
    }

    function click_center(item) {
        var cx = item.x + item.width/2
        var cy = item.x + item.height/2
        var pos = main.mapFromItem(item, cx, cy)
        mouseClick(main, pos.x, pos.y)
    }

    // True iff the item is fully in the screen bounds
    function onscreen(item) {
        // Some of these corners should have -1, since (width, height)
        // is one *past* the edge. However, it's hard to tell which corners
        // should be affected after the points are rotated to the
        // main window's coordinate system. So just use ">" in the checks
        // instead of ">=".
        var corners = [
          main.mapFromItem(item, 0, 0),
          main.mapFromItem(item, 0, item.height),
          main.mapFromItem(item, item.width, 0),
          main.mapFromItem(item, item.width, item.height)
        ]
        for (var i = 0; i < corners.length; i++) {
            var pos = corners[i]
            if (pos.x < 0 || pos.x > main.width)
                return false
            if (pos.y < 0 || pos.y > main.height)
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
            wait_for("page animation completed", function() {
                return !pageStack.busy
            })
            // Wait for an empty note page
            wait_find("empty note page", main,
                  { "text": "", "placeholderText": "notes-ph-empty-note" })
            compare(pageStack.currentPage.text, '')
            pageStack.currentPage.text = notes[i]
            wait_inputpanel_open()
            // Without this wait, the next select_pull_down sometimes
            // fails in VM testing.
            // @todo: find out what we're waiting for
            wait(1000)
        }
    }

    function wait_inputpanel_open() {
        wait_for("input panel opened", function() {
            return pageStack.imSize > 0
        })
        wait_for("input panel animation completed", function() {
            return pageStack.panelSize == pageStack.imSize
        })
    }

    function wait_inputpanel_closed() {
        wait_for("input panel closed", function() {
            return pageStack.imSize == 0
        })
        wait_for("input panel animation completed", function() {
            return pageStack.panelSize == pageStack.imSize
        })
    }
}
