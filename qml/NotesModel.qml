import QtQuick 1.1
import Sailfish.Silica 1.0

import "notes.js" as NoteScript

ListModel {
    id: listmodel

    property string filter

    Component.onCompleted: {
        NoteScript.populateNotes(listmodel)
    }

    function newNote(pagenr) {
        var color = NoteScript.randomColor()
        NoteScript.newNote(pagenr, color)

        var i
        for (i = count - 1; i >= 0; i--) {
            var row = get(i)
            if (row.pagenr >= pagenr)
                setProperty(i, "pagenr", parseInt(row.pagenr, 10) + 1)
            else
                break;
        }
        insert(i + 1, { "pagenr": pagenr, "text": '', "color": color })
    }

    function updateNote(idx, text) {
        var row = get(idx)
        NoteScript.updateNote(row.pagenr, text)
        setProperty(idx, "text", text)
    }

    function moveToTop(idx) {
        var row = get(idx)
        NoteScript.moveToTop(row.pagenr)

        setProperty(idx, "pagenr", 1)
        for (var i = idx - 1; i >= 0; i--) {
            var row = get(i)
            setProperty(i, "pagenr", parseInt(row.pagenr, 10) + 1)
        }
        move(idx, 0, 1) // move 1 item to position 0
    }
}
