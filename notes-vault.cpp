#include <qtaround/os.hpp>
#include <qtaround/debug.hpp>
#include <qtaround/subprocess.hpp>
#include <vault/unit.hpp>
#include <qtaround/debug.hpp>
#include <qtaround/util.hpp>
#include <QCoreApplication>

typedef QMap<QString, QString> str_map_type;
typedef std::unique_ptr<sys::GetOpt> options_ptr;
using subprocess::Process;

namespace {

QStringList get_export_commands()
{
    return QStringList({".mode insert notes\n"
                ,"SELECT pagenr, color, body FROM notes ORDER BY pagenr;"
                });
}

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

// TODO generic function, create the-vault-unit-sql package from it
void process_sqlite_import(QString const &data, options_ptr options)
{
    auto lines = data.split("\n");
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
                
        auto ps = std::make_shared<Process>();
        ps->popen_sync("sqlite3", {db_name});
        on_ok.push_back([ps]() mutable {
                ps->stdinClose();
                ps->wait(-1);
                ps->check_error();
            });
        write = [ps](QString const &line) mutable {
            return ps->write(line + "\n");
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

    Process ps;
    ps.popen_sync("sqlite3", {db_name});
    auto commands = get_export_commands();
    for (auto it = commands.begin(); it != commands.end(); ++it)
        ps.write(*it + "\n");

    ps.stdinClose();
    ps.wait(-1);
    ps.check_error();

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
    data.push_back(str(ps.stdout()));
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
    auto data = os::read_file(sql_fname);
    process_sqlite_import(str(data), std::move(options));
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
