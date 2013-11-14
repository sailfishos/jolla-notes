// Copyright (C) 2012-2013 Jolla Ltd.
// Contact: Richard Braakman <richard.braakman@jollamobile.com>

// The page numbers in the db must stay sequential (starting from 1),
// but the page numbers in the model may have gaps if the filter is active.
// The page numbers in the model must still be ascending, though.

// The details depend on Qt's openDatabaseSync implementation, but
// the data will probably be stored in an sqlite file under
//   $HOME/.local/share/jolla-notes/QML/OfflineStorage/Databases/

.import QtQuick.LocalStorage 2.0 as Sql

function upgradeSchema(db) {
    if (db.version == '') {
        db.changeVersion('', '1', function (tx) {
            tx.executeSql(
                'CREATE TABLE notes (pagenr INTEGER, color TEXT, body TEXT)')
        })
    }
    if (db.version == '1') {
        db.changeVersion('1', '2', function (tx) {
            tx.executeSql('CREATE TABLE next_color_index (value INTEGER)')
            tx.executeSql('INSERT INTO next_color_index VALUES (0)')
        })
    }
}

function openDb() {
    var db = Sql.LocalStorage.openDatabaseSync('silicanotes', '', 'Notes', 10000, upgradeSchema)
    if (db.version != '2')
        upgradeSchema(db);
    return db;
}
 
function populateNotes(model) {
    var db = openDb()
    db.readTransaction(function (tx) {
        model.clear()
        var results = tx.executeSql('SELECT pagenr, color, body FROM notes ORDER BY pagenr');
        for (var i = 0; results.rows.item(i) != null; i++) {
            var item = results.rows.item(i)
            model.append({
                "pagenr": item.pagenr,
                "text": item.body,
                "color": item.color
            })
        }
    })
}

var availableColors = [
    "#cc0000", "#cc7700", "#ccbb00",
    "#88cc00", "#00b315", "#00bf9f",
    "#005fcc", "#0016de", "#bb00cc"]

function nextColor() {
    var index
    var db = openDb()
    db.transaction(function (tx) {
        var r = tx.executeSql('SELECT value FROM next_color_index LIMIT 1')
        index = parseInt(r.rows.item(0).value, 10)
        if (index >= availableColors.length)
            index = 0
        tx.executeSql('UPDATE next_color_index SET value = ?', [index + 1])
    })
    return availableColors[index]
}

function newNote(pagenr, color, initialtext) {
    var db = openDb()
    db.transaction(function (tx) {
        tx.executeSql('UPDATE notes SET pagenr = pagenr + 1 WHERE pagenr >= ?',
                      [pagenr])
        tx.executeSql('INSERT INTO notes (pagenr, color, body) VALUES (?, ?, ?)',
                      [pagenr, color, initialtext])
    })
}

function updateNote(pagenr, text) {
    var db = openDb()
    db.transaction(function (tx) {
        tx.executeSql('UPDATE notes SET body = ? WHERE pagenr = ?',
                      [text, pagenr])
    })
}

function updateColor(pagenr, color) {
    var db = openDb()
    db.transaction(function (tx) {
        tx.executeSql('UPDATE notes SET color = ? WHERE pagenr = ?',
                      [color, pagenr])
    })
}

function moveToTop(pagenr) {
    var db = openDb()
    db.transaction(function (tx) {
        // Use modulo-pagenr arithmetic to rotate the page numbers: add 1 to
        // all of them except pagenr itself, which goes to 1.
        tx.executeSql('UPDATE notes SET pagenr = (pagenr % ?) + 1 WHERE pagenr <= ?',
                      [pagenr, pagenr])
    })
}

function deleteNote(pagenr) {
    var db = openDb();
    db.transaction(function (tx) {
        tx.executeSql('DELETE FROM notes WHERE pagenr = ?', [pagenr])
        tx.executeSql('UPDATE notes SET pagenr = pagenr - 1 WHERE pagenr > ?',
                      [pagenr])
    })
}
