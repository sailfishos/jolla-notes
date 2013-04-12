// Helper functions to do feature tests with QtQuickTest
// Assumption: the application window has id 'main'

// unique object, used by matches() and find()
var DEFINED = {}

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

// Return true iff item has all the specified properties with corresponding
// values. Use the special value EXISTS to only check that the property exists
// Example: matches(button, { text: "button-text", onClick: DEFINED })
function matches(item, props) {
    for (var key in props) {
        if (!props.hasOwnProperty(key))
            continue
        if (!item.hasOwnProperty(key))
            return false
        if (!(props[key] === DEFINED || item[key] == props[key]))
            return false
    }
    return true
}

// Find an item in item's tree that has all the specified properties
// with corresponding values.
function find(item, props) {
    if (matches(item, props))
        return item

    for (var i = 0; i < item.children.length; i++) {
        var child = find(item.children[i], props)
        if (child !== undefined)
            return child
    }
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

// Return true iff the item and all its parents have the 'visible' property true
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

// Return true iff the item is clearly visible on screen
function displayed(item) {
    return onscreen(item) && visible(item) && !faded(item)
}
