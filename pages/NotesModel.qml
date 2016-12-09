import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0
import "notes.js" as NoteScript

ListModel {
    id: listmodel

    property string filter
    property int moveCount: 1
    readonly property var availableColors: [
        "#cc0000", "#cc7700", "#ccbb00",
        "#88cc00", "#00b315", "#00bf9f",
        "#005fcc", "#0016de", "#bb00cc"]
    property var colorIndexConf: ConfigurationValue {
        key: "/apps/jolla-notes/next_color_index"
        defaultValue: 0
    }

    Component.onCompleted: {
        NoteScript.populateNotes(listmodel)
        if (NoteScript.migrated_color_index !== -1) {
            colorIndexConf.value = NoteScript.migrated_color_index
        }
    }

    function nextColor() {
        var index = colorIndexConf.value
        if (index >= availableColors.length)
            index = 0
        colorIndexConf.value = index + 1
        return availableColors[index]
    }

    function newNote(pagenr, initialtext, color) {

        // convert to string
        var _color = color + ""
        NoteScript.newNote(pagenr, _color, initialtext)

        var i
        for (i = count - 1; i >= 0; i--) {
            var row = get(i)
            if (row.pagenr >= pagenr)
                setProperty(i, "pagenr", parseInt(row.pagenr, 10) + 1)
            else
                break;
        }
        insert(i + 1, { "pagenr": pagenr, "text": initialtext, "color": _color })
        return i + 1
    }

    function updateNote(idx, text) {
        var row = get(idx)
        NoteScript.updateNote(row.pagenr, text)
        setProperty(idx, "text", text)
    }

    function updateColor(idx, color) {
        var row = get(idx)
        // convert to string
        var _color = color + ""

        NoteScript.updateColor(row.pagenr, _color)
        setProperty(idx, "color", _color)
    }

    function moveToTop(idx) {
        var row = get(idx)
        NoteScript.moveToTop(row.pagenr)

        setProperty(idx, "pagenr", 1)
        for (var i = idx - 1; i >= 0; i--) {
            row = get(i)
            setProperty(i, "pagenr", parseInt(row.pagenr, 10) + 1)
        }
        move(idx, 0, 1) // move 1 item to position 0
        moveCount++
    }

    function deleteNote(idx) {
        var row = get(idx)
        NoteScript.deleteNote(row.pagenr)
        for (var i = count - 1; i > idx; i--) {
            row = get(i)
            setProperty(i, "pagenr", parseInt(row.pagenr, 10) - 1)
        }
        remove(idx)
    }
}
