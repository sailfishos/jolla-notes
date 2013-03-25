import QtQuick 1.1
import Sailfish.Silica 1.0

import "notes.js" as NoteScript

ListModel {
    id: listmodel

    property string filter

    Component.onCompleted: {
        NoteScript.populateNotes(listmodel)
    }

    function newNote(pagenr) { NoteScript.newNote(listmodel, pagenr) }

    function debugdump() {
        console.log("Model!")
        for (var i = 0; i < count; i++) {
            var item = get(i)
            console.log( "Note " + i + " page " + item.pagenr + " " + item.color + " " + item.text)
        }
    }
}
