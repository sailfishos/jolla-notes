// SPDX-FileCopyrightText: 2025 Damien Caliste
//
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import Jolla.Notes 1.0

CalendarJournals {
    id: journals

    property AccountModel model: AccountModel {
        filterType: AccountModel.ServiceFilter
        filter: "nextcloud-notes"
        filterByEnabled: true
    }

    function updateNotes(filter, callback) {
        if (journals.ready) {
            var array = []
            var ids = journals.listJournalUids(filter)
            for (var i = 0; i < ids.length; i++) {
                var journal = journals.journal(ids[i])
                array[i] = {
                    "uid": journal.uid,
                    "title": journal.title,
                    "text": journal.body,
                    "color": journal.color
                }
            }
            callback(array)
        }
    }

    function newNote(position, color, initialtext, callback) {
        if (position == 0) {
            callback(journals.add(initialtext, color))
        } else {
            console.warn("Can only prepend new journals.")
        }
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
