// SPDX-FileCopyrightText: 2017 Jolla Ltd.
// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

// The page numbers in the db must stay sequential (starting from 1),
// but the page numbers in the model may have gaps if the filter is active.
// The page numbers in the model must still be ascending, though.

// The details depend on Qt's openDatabaseSync implementation, but
// the data will probably be stored in an sqlite file under
//   $HOME/.local/share/jolla-notes/QML/OfflineStorage/Databases/

.import QtQuick.LocalStorage 2.0 as Sql

var migrated_color_index = -1

function _rawOpenDb() {
    return Sql.LocalStorage.openDatabaseSync('silicanotes', '', 'Notes', 10000)
}

function upgradeSchema(db) {
    // Awkward. db.changeVersion does NOT update db.version, but DOES
    // check that db.version is equal to the first parameter.
    // So reopen the database after every changeVersion to get the
    // updated db.version.
    if (db.version == '') {
        // Change the version directly to '3', no point creating the
        // now obsolete next_color_index table and drop it immediately
        // after that.
        db.changeVersion('', '3', function (tx) {
            tx.executeSql(
                'CREATE TABLE notes (pagenr INTEGER, color TEXT, body TEXT)')
        })
        db = _rawOpenDb()
    }
    if (db.version == '1') {
        // Version '1' equals to version '3'. Just change the version number.
        // Old migration code to version '2' left in comments for reference.
        db.changeVersion('1', '3')
        /*
        db.changeVersion('1', '2', function (tx) {
            tx.executeSql('CREATE TABLE next_color_index (value INTEGER)')
            tx.executeSql('INSERT INTO next_color_index VALUES (0)')
        })
        */
        db = _rawOpenDb()
    }
    if (db.version == '2') {
        db.changeVersion('2', '3', function (tx) {
            // "next_color_index" table may be missing because it was never backed up.
            var results = tx.executeSql('SELECT name FROM sqlite_master WHERE type="table" AND name="next_color_index"');
            if (results.rows.length) {
                var r = tx.executeSql('SELECT value FROM next_color_index LIMIT 1')
                migrated_color_index = parseInt(r.rows.item(0).value, 10)
                // next_color_index is stored in dconf from now on. Drop the table.
                tx.executeSql('DROP TABLE next_color_index')
            }
        })
        db = _rawOpenDb()
    }
}

function openDb() {
    var db = _rawOpenDb()
    if (db.version != '3')
        upgradeSchema(db)
    return db
}

var regex = new RegExp(/['\%\\\_]/g)
var escaper = function escaper(char){
    var m = ["'", "%", "_", "\\"]
    var r = ["''", "\\%", "\\_", "\\\\"]
    return r[m.indexOf(char)]
}

// In the following functions, the special column ROWID is being used
// as a unique identifier for the notes. The NotesModel.qml requires
// to be able to uniquely identify notes with a string. The ROWID
// can play this role. Indeed, the NotesModel is not storing these
// ids elsewhere, just using them for identification purpose only
// during the run time. In case, we ever run VACUUM on the database,
// we can simply emit a refresh() on the model, to reload all notes
// and get the new ROWIDs.
function updateNotes(filter, callback) {
    var db = openDb()
    db.readTransaction(function (tx) {
        var results
        // Stringify the rowid to avoid NotesModel.qml to
        // create a 'uid' field of int type and create
        // issues with potential other note backends using
        // strings.
        if (filter.length > 0) {
            results = tx.executeSql("SELECT CAST(rowid as TEXT) AS rowid, pagenr, color, body FROM notes WHERE body LIKE '%"
                                    + filter.replace(regex, escaper) + "%' ESCAPE '\\' ORDER BY pagenr")
        } else {
            results = tx.executeSql("SELECT CAST(rowid as TEXT) AS rowid, pagenr, color, body FROM notes ORDER BY pagenr")
        }

        var array = []
        for (var i = 0; i < results.rows.length; i++) {
            var item = results.rows.item(i)
            array[i] = {
                "uid": item.rowid,
                "text": item.body,
                "color": item.color
            }
        }

        callback(array)
    })
}

function newNote(pagenr, color, initialtext, callback) {
    var db = openDb()
    db.transaction(function (tx) {
        tx.executeSql('UPDATE notes SET pagenr = pagenr + 1 WHERE pagenr >= ?',
                      [pagenr])
        var result = tx.executeSql('INSERT INTO notes (pagenr, color, body) VALUES (?, ?, ?)',
                                   [pagenr, color, initialtext])
        // Return the newly created note.
        callback({"uid": result.insertId,
                  "text": initialtext,
                  "color": color})
    })
}

function updateNote(uid, text) {
    var db = openDb()
    db.transaction(function (tx) {
        tx.executeSql('UPDATE notes SET body = ? WHERE rowid = ?',
                      [text, uid])
    })
}

function updateColor(uid, color) {
    var db = openDb()
    db.transaction(function (tx) {
        tx.executeSql('UPDATE notes SET color = ? WHERE rowid = ?',
                      [color, uid])
    })
}

function moveToTop(uid) {
    var db = openDb()
    db.transaction(function (tx) {
        tx.executeSql('UPDATE notes SET pagenr = pagenr + 1 WHERE pagenr < (SELECT pagenr FROM notes WHERE rowid = ?)',
                      [uid])
        tx.executeSql('UPDATE notes SET pagenr = 1 WHERE rowid = ?', [uid])
    })
}

function deleteNote(uid) {
    var db = openDb();
    db.transaction(function (tx) {
        tx.executeSql('UPDATE notes SET pagenr = pagenr - 1 WHERE pagenr > (SELECT pagenr FROM notes WHERE rowid = ?)',
                      [uid])
        tx.executeSql('DELETE FROM notes WHERE rowid = ?', [uid])
    })
}
