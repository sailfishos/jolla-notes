// SPDX-FileCopyrightText: 2025 Damien Caliste
//
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick 2.6
import Sailfish.Silica 1.0
import Jolla.Notes 1.0

CalendarJournals {
    id: journals

    function updateNotes(filter, callback) {
        if (journals.ready) {
            var array = []
            var ids = journals.listJournalUids(filter)
            for (var i = 0; i < ids.length; i++) {
                var journal = journals.journal(ids[i])
                array[i] = {
                    "uid": journal.uid,
                    "title": Format.formatDate(journal.dateTime, Formatter.DateMedium),
                    "text": journal.body,
                    "color": journal.color
                }
            }
            callback(array)
        }
    }

    function newNote(position, color, initialtext) {
        var journal = journals.add(position, initialtext, color)
        return {"uid": journal.uid,
            "title": Format.formatDate(journal.dateTime, Formatter.DateMedium),
            "text": journal.body,
            "color": journal.color}
    }

    function updateNote(uid, text) {
        journals.updateBody(uid, text)
    }

    function updateColor(uid, color) {
        journals.updateColorString(uid, color)
    }

    function moveToTop(uid) {
        journals.updateTimeStamp(uid)
    }

    function deleteNote(uid) {
        journals.remove(uid)
    }
}
