// SPDX-FileCopyrightText: 2025 Damien Caliste
//
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick 2.6
import Sailfish.Silica 1.0
import Jolla.Notes 1.0
import Nemo.Configuration 1.0

DirectoryFiles {
    id: files

    property alias directories: directoryList.value
    property ConfigurationValue directoryList: ConfigurationValue {
        id: directoryList

        key: "/sailfish/notes/directory_list"
        defaultValue: []
    }

    function updateNotes(filter, callback) {
        if (files.ready) {
            var array = []
            var ids = files.listFilenames(filter)
            for (var i = 0; i < ids.length; i++) {
                var file = files.file(ids[i])
                array[i] = {
                    "uid": file.name,
                    "title": file.name,
                    "text": file.body,
                    "color": file.color
                }
            }
            callback(array)
        }
    }

    function newNote(position, color, initialtext) {
        //% "note"
        var file = files.add(position - 1, qsTrId("notes-la-filename"), initialtext, color)
        return {"uid": file.name,
            "title": file.name,
            "text": file.body,
            "color": file.color}
    }

    function updateNote(filename, text) {
        files.updateBody(filename, text)
    }

    function updateColor(filename, color) {
        files.updateColorString(filename, color)
    }

    function moveToTop(filename) {
        files.updateTimeStamp(filename)
    }

    function deleteNote(filename) {
        files.remove(filename)
    }
}
