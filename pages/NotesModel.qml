// SPDX-FileCopyrightText: 2013 - 2023 Jolla Ltd.
// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import "notesdatabase.js" as Database

ListModel {
    id: model

    property string filter
    property bool populated
    property int moveCount: 1
    readonly property var availableColors: [
        "#cc0000", "#cc7700", "#ccbb00",
        "#88cc00", "#00b315", "#00bf9f",
        "#005fcc", "#0016de", "#bb00cc"]
    property var colorIndexConf: ConfigurationValue {
        key: "/apps/jolla-notes/next_color_index"
        defaultValue: 0
    }
    property var provider: Database
    property var worker: WorkerScript {
        source: "notesmodel.js"
        onMessage: {
            if (messageObject.reply === "insert") {
                model.newNoteInserted()
            } else if (messageObject.reply == "update") {
                populated = true
                updated()
            }
        }
    }
    signal newNoteInserted
    signal updated

    Component.onCompleted: {
        refresh()

        if (Database.migrated_color_index !== -1) {
            colorIndexConf.value = Database.migrated_color_index
        }
    }
    onFilterChanged: refresh()
    onProviderChanged: refresh()

    function setLocalProvider() {
        provider = Database
    }

    function refresh() {
        provider.updateNotes(filter, function (results) {
            var msg = {'action': 'update', 'model': model, 'results': results}
            worker.sendMessage(msg)
        })
    }

    function nextColor() {
        var index = colorIndexConf.value
        if (index >= availableColors.length)
            index = 0
        colorIndexConf.value = index + 1
        return availableColors[index]
    }

    function newNote(position, initialtext, color) {
        var _color = color + "" // convert to string
        provider.newNote(position, _color, initialtext, function (note) {
            var msg = {'action': 'insert', 'model': model, "uid": note.uid, 'title': note.title, "text": note.text, "color": note.color }
            worker.sendMessage(msg)
        })
    }

    function updateNote(uid, text) {
        provider.updateNote(uid, text)
        var msg = {'action': 'textupdate', 'model': model, 'uid': uid, 'text': text}
        worker.sendMessage(msg)
    }

    function updateColor(uid, color) {
        var _color = color + "" // convert to string
        provider.updateColor(uid, _color)
        var msg = {'action': 'colorupdate', 'model': model, 'uid': uid, 'color': _color}
        worker.sendMessage(msg)
    }

    function moveToTop(uid) {
        provider.moveToTop(uid)
        var msg = {'action': 'movetotop', 'model': model, 'uid': uid}
        worker.sendMessage(msg)
        moveCount++
    }

    function deleteNote(uid) {
        provider.deleteNote(uid)
        var msg = {'action': 'remove', 'model': model, "uid": uid}
        worker.sendMessage(msg)
    }

    function getByUid(uid) {
        for (var idx = 0; idx < model.count; idx++) {
            var item = get(idx)
            if (item.uid == uid)
                return item
        }
        return undefined
    }

    function indexOf(uid) {
        for (var idx = 0; idx < model.count; idx++) {
            if (get(idx).uid == uid)
                return idx
        }
        return undefined
    }
}
