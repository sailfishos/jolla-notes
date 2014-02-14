#!/usr/bin/env cutes

var debug = require('debug');
var os = require('os');
var string = require('string');
var error = require('error');
var subprocess = require('subprocess');
var _ = require('functional');
var vault = require('vault/unit');

var get_export_commands = function() {
    return [".mode insert notes\n"
            ,"SELECT pagenr, color, body FROM notes ORDER BY pagenr;"
           ];
};

var get_export_fname = function(path) {
    return os.path(path, "notes.sql");
};

var parse_export_line = function(line) {
    var re = /^-- @([^@]+)@(.*)$/.exec(line);
    if (!re)
        return {data: line};
    return {tag: re[1], data: re[2]};
};

var find_files = function(dir, pattern) {
    var res = subprocess.check_output('find', [dir, '-name', pattern]);
    return string.removeEmpty(res.toString().split('\n'));
};

// TODO generic function, create the-vault-unit-sql package from it
var process_sqlite_import = function(data, vault_options) {
    var lines, process_data, check_tag, sqlite, write, skip;
    var on_ok, on_error;

    lines = data.split('\n');
    on_ok = _.functionStack();
    on_error = _.functionStack();

    skip = function() {};
    write = function(line) {
        return error.raise({message: "Database is not opened yet"});
    };

    var actions = {
        version: function(info) {
            if (parseInt(info.data) !== 1)
                error.raise({message: "Unsupported notes export version"
                             , version: info.data, expected: 1});
            return skip;
        },
        db: function(info) {
            var db_name = info.data;
            if (os.path.isFile(db_name)) {
                // backup existing db
                os.rename(db_name, db_name + ".back");
                on_error.push(os.rename.curry(db_name + ".back", db_name));
                on_ok.push(os.rm.curry(db_name + ".back"));
            }

            var ps = subprocess.process();
            sqlite = ps.popen_sync('sqlite3', [db_name]);
            on_ok.push(function() {
                sqlite.stdin.close();
                sqlite.wait(-1);
                sqlite.check_error();
            });
            write = function(line) {
                return sqlite.write(line + "\n");
            };
            return skip;
        },
        file: function(info) {
            var dst_name, src_name;
            dst_name = info.data;
            src_name = os.path(vault_options.data_dir, os.path.fileName(dst_name));

            if (os.path.isFile(dst_name)) {
                // backup existing file
                os.rename(dst_name, dst_name + ".back");
                on_error.push(os.rename.curry(dst_name + ".back", dst_name));
                on_ok.push(os.rm.curry(dst_name + ".back"));
            }

            os.cp(src_name, dst_name, {force: true});
        },
        delete: function() {
            return skip;
        },
        create: function() {
            return write;
        },
        data: function() {
            return write;
        }
    };

    try {
        _.each(function(line, nr) {
            var action, info;
            info = parse_export_line(line);
            if (info.tag) {
                action = actions[info.tag] || skip;
                process_data = action(info);
            } else {
                process_data(info.data, info.tag);
            }
        }, lines);
        on_ok.execute();
    } catch(e) {
        on_error.execute();
        throw e;
    }
};

var export_notes = function(options) {
    var notes_dir, files, db_name, ini_name, ps, sqlite, data;

    os.system("pkill", ["jolla-notes"]);

    notes_dir = os.path(os.home(), ".local/share/jolla-notes/QML/OfflineStorage/Databases");
    files = find_files(notes_dir, "*.sqlite");
    if (!files.length) {
        debug.info("No sqlite notes db, nothing to export");
        return null;
    }
    db_name = files[0];

    files = find_files(notes_dir, "*.ini");
    if (!files.length) {
        debug.error("No sqlite notes db ini found");
        return null;
    }
    ini_name = files[0];

    ps = subprocess.process();
    sqlite = ps.popen_sync('sqlite3', [db_name]);
    _.each(function(line) { return sqlite.write(line + "\n"); }
           , get_export_commands());
    sqlite.stdin.close();
    sqlite.wait(-1);
    sqlite.check_error();

    data = [
        "-- @version@1",
        "-- @file@" + ini_name,
        "-- @db@" + db_name,
        "-- @delete@",
        "DROP TABLE notes;",
        "-- @create@",
        "CREATE TABLE notes (pagenr INTEGER, color TEXT, body TEXT);",
        "-- @data@"
    ];
    data.push(ps.stdout().toString());
    data.push();
    os.write_file(get_export_fname(options.data_dir), data.join('\n'));
    os.cp(ini_name, options.data_dir, {force: true});
};

var import_notes = function(options) {
    os.system("pkill", ["jolla-notes"]);
    var data = os.read_file(get_export_fname(options.data_dir)).toString();
    return process_sqlite_import(data, options);
};


var opt = vault.getopt();
switch (opt.action) {
case "export":
    export_notes(opt);
    break;
case "import":
    import_notes(opt);
    break;
}
