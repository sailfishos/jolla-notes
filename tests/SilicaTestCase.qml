// Helper functions to do feature tests with QtQuickTest
// Assumption: the application window has id 'main'
// Most apps will also want an app-specific testcase component
// that inherits this one.

// Design guidelines
// This test frmaework balances several needs:
//  - Tests are expressed in terms of observable behavior and are independent
//    of app implementation. (Depending on Silica component implementation is
//    more acceptable.)
//  - Tests simulate user actions such as taps and keypresses, rather than
//    manipulating app state directly.
//  - Code for individual tests is short and easy to change.
//  - Tests run fast, preferably in milliseconds.
//  - Tests run both in virtual machines and on the device.
// Of course not all of these are fully achievable. It's a balance.

import QtQuick 2.0
import QtTest 1.0

TestCase {
    property int timeout: 5000
    // convenience binding for test cases
    property Item currentPage: main.pageStack.currentPage

    SignalSpy {
        id: clickspy
        signalName: "clicked"
    }

    TestEvent { id: testEvent }

    function dump_tree(item, indent) {
        if (indent === undefined)
            indent = ""
        var desc = indent
        if (item.hasOwnProperty("x") && item.hasOwnProperty("y")) {
            desc += "* " + item + " " + item.x + "," + item.y
        } else {
            desc += "- " + item
        }
        if (item.hasOwnProperty("testName") && item.testName.length > 0) {
            desc += " '" + item.testName + "'"
        } else if (item.hasOwnProperty("objectName") && item.objectName.length > 0) {
            desc += " '" + item.objectName + "'"
        }
        if (item.hasOwnProperty("text")) {
            if (item.text.length > 10) {
                desc += " text: '" + item.text.substr(0, 7) + "...'"
            } else {
                desc += " text: '" + item.text + "'"
            }
        }
        console.log(desc)
        indent = indent + " "
        if (item.children) {
            for (var i = 0; i < item.children.length; i++) {
                dump_tree(item.children[i], indent)
            }
        }
    }

    function debug_item(item) {
        var attrs = []
        for (var key in item) {
            if (!item.hasOwnProperty(key))
                continue
            attrs.push(key + ": " + item[key])
        }
        return "{ " + attrs.join(", ") + " }"
    }

    // Print an item's attributes to the console
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

    function _list_item_tree(item, result) {
        result.push(item)
        if (item.children === undefined)
            return

        for (var i = 0; i < item.children.length; i++) {
            _list_item_tree(item.children[i], result)
        }
    }

    function list_item_tree(item) {
        var result = []
        _list_item_tree(item, result)
        return result
    }

    // Find a visual item in item's tree that matches the predicate func
    function find(item, func) {
        if (func(item))
            return item

        if (item.children === undefined)
            return

        for (var i = 0; i < item.children.length; i++) {
            var child = find(item.children[i], func)
            if (child !== undefined)
                return child
        }
    }

    // Shorthand for the most common find() operation
    function find_text(item, text) {
        return find(item, function(it) { return it.text == text })
    }

    // Find an item with text that is also a Text item
    function find_real_text(item, text) {
        return find(item, function(it) {
            return it.text == text && match_type(it, "Text")
        })
    }

    function find_by_testname(item, name) {
        return find(item, function(it) {
            return it.hasOwnProperty("testName") && it.testName == name
        })
    }

    // Helper functions for find() funcs

    // True iff the item's component type matches typename.
    // Unfortunately the function has to rely on heuristics; it's not reliable.
    // (It does give consistent answers as long as the app doesn't change)
    function match_type(item, typename) {
        var itype = "" + item
        itype = itype.replace(/^QQuick/, '')
        itype = itype.replace(/_QMLTYPE_.*/, '')
        itype = itype.replace(/_QML_.*/, '')
        itype = itype.replace(/\(0x[a-z0-9]*\)/, '')
        return itype == typename
    }

    // Find items for all texts in the texts array, and verify that
    // they were all found.
    function verify_find_text_items(item, texts) {
        var items = []
        for (var i = 0; i < texts.length; i++) {
            var found = find_text(item, texts[i])
            verify(found, "found '" + texts[i] + "'")
            items.push(found)
        }
        return items
    }

    // A couple of dedicated find functions that encapsulate knowledge
    // about the silica components.

    function find_flickable_parent(item) {
        var parentItem = item.parent
        while (parentItem) {
            if (parentItem.hasOwnProperty("maximumFlickVelocity"))
                return parentItem
            parentItem = parentItem.parent
        }
    }

    function find_context_menu(item) {
        return find(item, function (it) {
            return it.hasOwnProperty("closeOnActivation")
                && it.hasOwnProperty("_parentMouseArea")
        })
    }

    // Wait until func is true or there's a timeout.
    // Return the final value from func.
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

    // Shorthand to combine wait() and find() so that the caller
    // does not have to write nested anonymous functions.
    function wait_find(description, item, func) {
        return wait_for(description, function() {
            return find(item, func)
        })
    }

    function wait_for_value(description, item, attr, value) {
        var attr_path = attr.split(".")
        var notfound
        var it
        verify(item, description + ": item not valid")

        // wait_for is effectively reimplemented here to give
        // better error messages when attr lookup fails
        for (var delay = 0; delay < timeout; delay += 50) {
            if (delay > 0)
                wait(50)
            it = item
            notfound = ""
            for (var i = 0; i < attr_path.length; i++) {
                if (!(attr_path[i] in it)) {
                    notfound = attr_path.slice(0, i+1).join(".")
                    break
                }
                it = it[attr_path[i]]
            }
            if (notfound == "" && it === value)
                return value
        }

        if (notfound)
            fail(description + ": " + notfound + " not found")
        // this should fail now, and produce a helpful message
        compare(it, value, description)
        // if it doesn't fail, something went wrong with the test
        fail(description + ": internal error")
    }

    // Monitor an item and its tree of children and wait for their
    // properties to stop changing.
    //
    // Since the animation objects themselves are usually not children
    // (they are under "resources"), this function is not suitable for
    // animations that are just timers. If there's no gradual change to
    // some visual item then the animation will not be detected.
    function wait_animation_stop(item) {
        var prevstate = ""
        var itemstate = ""

        wait_for("wait_animation_stop", function() {
            prevstate = itemstate
            itemstate = item_tree_state(item)
            return prevstate == itemstate
        })
    }

    // Return a summary of the state of the properties of
    // an item and its tree of children.
    function item_tree_state(item) {
        var items = list_item_tree(item)
        for (var i = 0; i < items.length; i++) {
            items[i] = debug_item(items[i])
        }
        return items.join("\n\n")
    }

    function click_center(item) {
        var pos = main.mapFromItem(item, item.width/2, item.height/2)
        testEvent.mouseClick(main, pos.x, pos.y, Qt.LeftButton, 0, 0)
    }

    function longclick_center(item) {
        var pos = main.mapFromItem(item, item.width/2, item.height/2)
        testEvent.mousePress(main, pos.x, pos.y, Qt.LeftButton, 0, 0)
        wait(2100)  // a lot longer than 1 second
        testEvent.mouseRelease(main, pos.x, pos.y, Qt.LeftButton, 0, 0)
        wait(1)
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

    // True iff the item and all its parents have the 'visible'
    // property true and opacity > 0
    function visible(item) {
        while (item) {
            if (!item.visible || item.opacity == 0.0)
                return false
            item = item.parent
        }
        return true
    }

    // True iff the combined opacity of the item and its parents under limit
    function faded(item, limit) {
        var opacity = 1.0
        while (item) {
            opacity = opacity * item.opacity
            item = item.parent
        }
        return opacity < limit
    }

    function verify_displayed(item, name) {
        verify(item, name + " found")
        verify(visible(item), name + " is visible")
        verify(!faded(item, 0.3), name + " is opaque")
        verify(onscreen(item), name + " is in screen bounds")
    }

    function select_pull_down(option) {
        // Refer to page instead of main, because main might
        // be rotated due to screen orientation. The coordinate
        // transformation can then be handled by mapFromItem.
        var page = currentPage
        wait_animation_stop(page)

        var item = find_text(page, option)
        verify(item, "Menu item " + option + " found")

        var real_height = page.height + main.pageStack.panelSize
        var drag_x = page.width / 2
        var drag_y = real_height * 0.20
        var drag_end = real_height * 0.80
        var pos = main.mapFromItem(page, drag_x, drag_y)
        testEvent.mousePress(main, pos.x, pos.y, Qt.LeftButton, 0, 0)
        while (drag_y < drag_end) {
            drag_y += 10
            pos = main.mapFromItem(page, drag_x, drag_y)
            testEvent.mouseMove(main, pos.x, pos.y, Qt.LeftButton, 0, 0)
            wait(1)
            var highlight = find(main, function(it) {
                return it.highlightedItem == item
            })
            if (highlight !== undefined) {
                clickspy.target = item
                testEvent.mouseRelease(main, pos.x, pos.y, Qt.LeftButton, 0, 100)
                clickspy.wait()
                clickspy.target = undefined
                return
            }
        }
        testEvent.mouseRelease(main, pos.x, pos.y, Qt.LeftButton, 0, 0)
        fail("Could not activate pull-down option " + option)
    }

    function click_indicator(item) {
        var pos = main.mapFromItem(item, 2, item.height/2)
        testEvent.mouseClick(main, pos.x, pos.y, Qt.LeftButton, 0, 0)
    }

    function go_back() {
        // Refer to page instead of main, because main might
        // be rotated due to screen orientation. The coordinate
        // transformation can then be handled by mapFromItem.

        click_indicator(main.pageStack._pageStackIndicator)
    }
    function wait_inputpanel_open() {
        wait_for("input panel opened", function() {
            return main.pageStack.imSize > 0
        })
        wait_for("input panel animation completed", function() {
            return main.pageStack.panelSize == main.pageStack.imSize
        })
    }

    function wait_inputpanel_closed() {
        wait_for("input panel closed", function() {
            return main.pageStack.imSize == 0
        })
        wait_for("input panel animation completed", function() {
            return main.pageStack.panelSize == main.pageStack.imSize
        })
    }

    function wait_pagestack(desc, depth) {
        if (depth !== undefined) {
            wait_for(desc, function() {
                return main.pageStack.depth == depth
            })
        }
        wait_for("page animation completed", function() {
            return !main.pageStack.busy
        })
    }

    // Check if any of the items in the items array overlap each other
    // when mapped to the 'canvas' item's coordinates.
    // Comparisons are made using bounding boxes, so there may be false
    // positives with items rotated at non-right angles.
    function overlap(canvas, items) {
        var rects = []
        var overlaps = []
        for (var i = 0; i < items.length; i++) {
            // Figure out the item's bounding box
            var corn = [
                canvas.mapFromItem(items[i], 0, 0),
                canvas.mapFromItem(items[i], 0, items[i].height - 1),
                canvas.mapFromItem(items[i], items[i].width - 1, 0),
                canvas.mapFromItem(items[i], items[i].width - 1,
                                             items[i].height - 1)
            ]
            var rect = {}
            rect.top = Math.min(corn[0].y, corn[1].y, corn[2].y, corn[3].y)
            rect.bot = Math.max(corn[0].y, corn[1].y, corn[2].y, corn[3].y)
            rect.lft = Math.min(corn[0].x, corn[1].x, corn[2].x, corn[3].x)
            rect.rht = Math.max(corn[0].x, corn[1].x, corn[2].x, corn[3].x)
            for (var j = 0; j < rects.length; j++) {
                // This expression enumerates all the ways two rectangles
                // can be non-overlapping, and then takes the negation.
                if (!(rect.lft > rects[j].rht || rect.rht < rects[j].lft
                    || rect.top > rects[j].bot || rect.bot < rects[j].top)) {
                    overlaps.push(j)
                    overlaps.push(i)
                }
            }
            rects.push(rect)
        }
        return overlaps
    }

    // To speed up testing, skip the 5-second delay of a remorse item
    // and trigger its action immediately.
    function fastforward_remorseitem(remorseitem) {
        verify(remorseitem.hasOwnProperty("_msRemaining"),
               "item really is a RemorseItem")
        if (remorseitem._msRemaining > 0) {
            var old_timeout = remorseitem._timeout
            remorseitem._timeout = 1
            wait(2)
            remorseitem._timeout = old_timeout
            wait(1)
        }
    }

    // To speed up testing, speed up the pagestack transition animations
    // from now on. It's not the default because some apps may rely on
    // the transitions taking longer than their own animations.
    function fastforward_page_transitions() {
        main.pageStack._transitionDuration = 10
    }
}
