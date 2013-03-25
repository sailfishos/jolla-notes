// Copyright (C) 2012-2013 Jolla Ltd.
// Contact: Richard Braakman <richard.braakman@jollamobile.com>

// The page numbers in the db must stay sequential (starting from 1),
// but the page numbers in the model may have gaps if the filter is active.
// The page numbers in the model must still be ascending, though.

// The details depend on Qt's openDatabaseSync implementation, but
// the data will probably be stored in an sqlite file under
//   $HOME/.local/share/data/QML/OfflineStorage/Databases/ somewhere

function upgradeSchema(db) {
    if (db.version == '') {
        db.changeVersion('', '1', function (tx) {
            tx.executeSql(
                'CREATE TABLE notes (pagenr INTEGER, color TEXT, body TEXT)');
        })
    }
}

function openDb() {
    var db = openDatabaseSync('silicanotes', '', 'Notes', 10000, upgradeSchema)
    if (db.version != '1')
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
    '#ff0000', '#ff8000', '#ffff00', '#73e600',
    '#00f050', '#00ffd4', '#00bfff', '#0080ff',
    '#0000ff', '#8000ff', '#aa00ff', '#ff00aa'
]

function randomColor() {
    return availableColors[Math.floor(Math.random() * availableColors.length)]
}

function newNote(model, pagenr) {
    var db = openDb()
    var color = randomColor()

    db.transaction(function (tx) {
        tx.executeSql('UPDATE notes SET pagenr = pagenr + 1 WHERE pagenr >= ?',
                      [pagenr])
        tx.executeSql('INSERT INTO notes (pagenr, color, body) VALUES (?, ?, ?)',
                      [pagenr, color, ''])
    })

    var i
    for (i = model.count - 1; i >= 0; i--) {
        var row = model.get(i)
        if (row.pagenr >= pagenr)
            model.setProperty(i, "pagenr", parseInt(row.pagenr, 10) + 1)
        else
            break;
    }
    model.insert(i + 1, { "pagenr": pagenr, "text": '', "color": color });
}

function deleteNote(model, seq) {
    var db = openDb();
    db.transaction(function (tx) {
        tx.executeSql('DELETE FROM notes WHERE seq = ?', [seq]);
        tx.executeSql('UPDATE notes SET seq = seq - 1 WHERE seq > ?', [seq])
    })
    model.remove(seq);
}
