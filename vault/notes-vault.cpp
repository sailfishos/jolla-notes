#include <qtaround/os.hpp>
#include <qtaround/debug.hpp>
#include <qtaround/subprocess.hpp>
#include <vault/unit.hpp>
#include <qtaround/debug.hpp>
#include <qtaround/util.hpp>
#include <QCoreApplication>
#include <QSqlDatabase>
#include <QSqlDriver>
#include <QSqlQuery>
#include <QSqlRecord>

namespace sys = qtaround::sys;
namespace os = qtaround::os;
namespace subprocess = qtaround::subprocess;
namespace error = qtaround::error;
namespace debug = qtaround::debug;

typedef QMap<QString, QString> str_map_type;
typedef std::unique_ptr<sys::GetOpt> options_ptr;
using subprocess::Process;

namespace {

QString get_export_fname(QString const &path)
{
    return os::path::join(path, "notes.sql");
}

str_map_type parse_export_line(QString const &line)
{
    
    QRegExp re("^-- @([^@]+)@(.*)$");
    if (!re.exactMatch(line))
        return str_map_type({{"data", line}});
    auto matches = re.capturedTexts();
    return str_map_type({{"tag", matches[1]}, {"data", matches[2]}});
}

QStringList find_files(QString const &dir, QString const &pattern)
{
    auto data = str(subprocess::check_output("find", {dir, "-name", pattern}));
    return filterEmpty(data.split("\n"));
}

QStringList data_to_inserts(QString const &data)
{
    // This looks insane, but I couldn't figure out a prettier way of
    // even somewhat reliably getting the newlines back in.  Earlier,
    // this was handled by the sqlite3 shell parser.  Optimally, the
    // dump would not have multi-line strings, but I don't think breaking
    // existing backups would be welcomed.
    auto rawlines = data.split("\n");
    QStringList lines;
    QString nextline;
    for (auto it = rawlines.begin(); it != rawlines.end(); ++it) {
        nextline.append(*it);
        if (nextline.count(QLatin1Char('\'')) % 2 == 0) {
            // Not in a multi-line string
            lines += nextline;
            nextline.clear();
        } else {
            // In a multi-line string, need to add a newline sqlite understands
            nextline.append("' || char(10) || '");
        }
    }
    if (nextline.size() != 0) {
        debug::error("Odd number of single quotes in DB dump.");
    }
    return lines;
}

// TODO generic function, create the-vault-unit-sql package from it
void process_sqlite_import(QString const &data, options_ptr options)
{
    std::list<std::function<void()> > on_ok, on_error;

    typedef std::function<void(QString const &)> process_type;
    process_type skip = [](QString const &){};
    process_type write = [](QString const &) {
        return error::raise({{"message", "Database is not opened yet"}});
    };

    auto mkdir = [](QString const &dir_name) {
        if (!os::path::isDir(dir_name))
            os::mkdir(dir_name, {{"parent", true}});
    };

    typedef std::function<process_type (str_map_type const &)> action_type;

    action_type on_version = [skip](str_map_type const &info) {
        bool ok = false;
        auto ver = info["data"].toInt(&ok);
        if (!(ok && ver == 1))
            error::raise({{"message", "Unsupported notes export version"}
                    , {"version", info["data"]}, {"expected", 1}});
        return skip;
    };

    action_type on_db = [skip, &on_error, &on_ok, mkdir, &write](str_map_type const &info) {
        auto db_name = info["data"];
        if (os::path::isFile(db_name)) {
            // backup existing db
            os::rename(db_name, db_name + ".back");
            on_error.push_back([db_name]() { os::rename(db_name + ".back", db_name); });
            on_ok.push_back([db_name]() { os::rm(db_name + ".back"); });
        } else {
            mkdir(os::path::dirName(db_name));
        }

        QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
        db.setDatabaseName(db_name);
        db.open();
        on_ok.push_back([db]() mutable {
                db.close();
            });
        write = [db](QString const &line) mutable {
            QSqlQuery q(db);
            bool res = q.exec(line);
            return res;
        };
        return skip;
    };

    action_type on_file = [skip, &on_error, &on_ok, mkdir, &options](str_map_type const &info) {
        auto dst_name = info["data"];
        auto src_name = os::path::join(options->value("dir"), os::path::fileName(dst_name));

        if (os::path::isFile(dst_name)) {
            // backup existing file
            os::rename(dst_name, dst_name + ".back");
            on_error.push_back([dst_name]() { os::rename(dst_name + ".back", dst_name); });
            on_ok.push_back([dst_name]() { os::rm(dst_name + ".back"); });
        } else {
            mkdir(os::path::dirName(dst_name));
        }
        os::cp(src_name, dst_name, {{"force", true}});
        return skip;
    };

    action_type skip_action = [skip](str_map_type const &) { return skip; };
    action_type write_action = [&write](str_map_type const &) { return write; };

    action_type on_delete = skip_action;
    action_type on_create = write_action;
    action_type on_data = write_action;

    QMap<QString, action_type> actions = {
        {"version", on_version}
        , {"db", on_db}
        , {"file", on_file}
        , { "delete", on_delete}
        , { "create", on_create}
        , {"data", on_data}
    };

    auto lines = data_to_inserts(data);
    try {
        size_t nr = 0;
        process_type process_data = skip;
        for (auto it = lines.begin(); it != lines.end(); ++it, ++nr) {
            action_type action;
            auto line = *it;
            auto info = parse_export_line(line);
            if (!info["tag"].isEmpty()) {
                action = actions.value(info["tag"], skip_action);
                process_data = action(info);
            } else {
                process_data(info["data"]);
            }
        }
        for (auto it = on_ok.begin(); it != on_ok.end(); ++it) (*it)();
    } catch(...) {
        for (auto it = on_error.begin(); it != on_error.end(); ++it) (*it)();
        throw;
    }
}

void export_notes(options_ptr options)
{
    os::system("pkill", {"jolla-notes"});

    auto notes_dir = os::path::join(os::home(), ".local/share/jolla-notes/QML/OfflineStorage/Databases");
    if (!os::path::exists(notes_dir)) {
        debug::warning("Nothing to backup, no Notes directory:"
                       , notes_dir);
        return;
    }
    auto files = find_files(notes_dir, "*.sqlite");
    if (!files.size()) {
        debug::info("No sqlite notes db, nothing to export");
        return;
    }
    auto db_name = files[0];

    files = find_files(notes_dir, "*.ini");
    if (!files.size()) {
        debug::error("No sqlite notes db ini found");
        return;
    }
    auto ini_name = files[0];

    QStringList data = {
        str("-- @version@1"),
        str("-- @file@") + ini_name,
        str("-- @db@") + db_name,
        str("-- @delete@"),
        str("DROP TABLE notes;"),
        str("-- @create@"),
        str("CREATE TABLE notes (pagenr INTEGER, color TEXT, body TEXT);"),
        str("-- @data@")
    };

    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(db_name);
    db.open();
    QSqlQuery q =
        db.exec("SELECT pagenr, color, body FROM notes ORDER BY pagenr;");
    while (q.next()) {
        data.push_back(db.driver()->sqlStatement(QSqlDriver::InsertStatement,
                                                 "notes", q.record(), false));
        data.push_back(";");
    }
    db.close();
    data.push_back("");
    auto out_dir = options->value("dir");
    auto sql_fname = get_export_fname(out_dir);
    debug::info("Writing data to", sql_fname);
    os::write_file(sql_fname, data.join("\n"));
    debug::info("Copying ini from", ini_name, "to", out_dir);
    os::cp(ini_name, out_dir, {{"force", true}});
}

void import_notes(options_ptr options)
{
    os::system("pkill", {"jolla-notes"});
    auto sql_fname = get_export_fname(options->value("dir"));
    debug::info("Reading data from", sql_fname);
    if (os::path::exists(sql_fname)) {
        auto data = os::read_file(sql_fname);
        process_sqlite_import(str(data), std::move(options));
    } else {
        debug::info("Nothing to import, no file", sql_fname);
    }
}

}

int main(int argc, char *argv[])
{
    try {
        QCoreApplication app(argc, argv);
        auto opt = vault::unit::getopt();
        auto action = opt->value("action");
        if (action == "export") {
            export_notes(std::move(opt));
        } else if (action == "import") {
            import_notes(std::move(opt));
        }
    } catch (error::Error const &e) {
        qDebug() << e;
        return 1;
    } catch (std::exception const &e) {
        qDebug() << e.what();
        return 2;
    }
    return 0;
}
