/*
 * Copyright (C) 2012-2015 Jolla Ltd.
 *
 * The code in this file is distributed under multiple licenses, and as such,
 * may be used under any one of the following licenses:
 *
 *   - GNU General Public License as published by the Free Software Foundation;
 *     either version 2 of the License (see LICENSE.GPLv2 in the root directory
 *     for full terms), or (at your option) any later version.
 *   - GNU Lesser General Public License as published by the Free Software
 *     Foundation; either version 2.1 of the License (see LICENSE.LGPLv21 in the
 *     root directory for full terms), or (at your option) any later version.
 *   - Alternatively, if you have a commercial license agreement with Jolla Ltd,
 *     you may use the code under the terms of that license instead.
 *
 * You can visit <https://sailfishos.org/legal/> for more information
 */

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
            var row = get(i)
            setProperty(i, "pagenr", parseInt(row.pagenr, 10) + 1)
        }
        move(idx, 0, 1) // move 1 item to position 0
        moveCount++
    }

    function deleteNote(idx) {
        var row = get(idx)
        NoteScript.deleteNote(row.pagenr)
        for (var i = count - 1; i > idx; i--) {
            var row = get(i)
            setProperty(i, "pagenr", parseInt(row.pagenr, 10) - 1)
        }
        remove(idx)
    }
}
