// Helper functions to do feature tests with QtQuickTest
// Assumption: the application window has id 'main'

import QtQuickTest 1.0

TestCase {
    SignalSpy {
        id: spy
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
            if (item[key] !== props[key])
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
          main.mapFromItem(item, 0, item.height),
          main.mapFromItem(item, item.width, 0),
          main.mapFromItem(item, item.width, item.height)
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

    // Return true iff the combined opacity of the item and its parents < 0.5
    function faded(item) {
        var opacity = 1.0
        while (item) {
            opacity = opacity * item.opacity
            item = item.parent
        }
        return opacity < 0.5
    }

    function verify_displayed(item, name) {
        verify(visible(item), name + " is visible")
        verify(!faded(item), name + " is opaque")
        verify(onscreen(item), name + " is in screen bounds")
    }

    function select_pull_down(option) {
        var item = find(main, { "text": option })
        verify(item, "Menu item " + option + " found")
        var drag_x = main.width / 2
        var drag_y = main.height * 0.20
        var drag_end = main.height * 0.80
        mousePress(main, drag_x, drag_y)
        while (drag_y < drag_end) {
            drag_y += 10
            mouseMove(main, drag_x, drag_y, undefined, Qt.LeftButton)
            wait(1)
            var highlight = find(main, { "highlightedItem": item })
            if (highlight !== undefined) {
                spy.signalName = "clicked"
                spy.target = item
                mouseRelease(main, drag_x, drag_y)
                spy.wait()
                return
            }
        }
        mouseRelease(main, drag_x, drag_y)
        fail("Could not activate pull-down option " + option)
    }
}
