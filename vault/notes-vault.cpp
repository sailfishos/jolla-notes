// SPDX-FileCopyrightText: 2016 - 2020 Jolla Ltd.
// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

#include <vault/unit.h>
#include <functional>
#include <QCoreApplication>
#include <QSqlDatabase>
#include <QSqlDriver>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QStringList>
#include <QRegExp>
#include <QProcess>
#include <QDir>
#include <QFileInfo>
#include <QLoggingCategory>

Q_LOGGING_CATEGORY(lcBackup, "org.sailfishos.backup", QtWarningMsg);
typedef QMap<QString, QString> str_map_type;

namespace {

const auto NotesDirectory = QStringLiteral("%1/.local/share/com.jolla/notes/QML/OfflineStorage/Databases/");

QString get_export_fname(QString const &path)
{
    return path + "/notes.sql";
}

str_map_type parse_export_line(QString const &line)
{
    QRegExp re("^-- @([^@]+)@(.*)$");
    if (!re.exactMatch(line))
        return str_map_type({{"data", line}});
    auto matches = re.capturedTexts();
    return str_map_type({{"tag", matches[1]}, {"data", matches[2]}});
}


void find_files(QString const &path, QString const &pattern, QStringList &found, bool clear = true)
{
    if (clear)
        found.clear();
    QDir pwd(path);
    for (const QString &match : pwd.entryList(QStringList(pattern), QDir::Files))
        found.append(path + "/" + match);
    for (const QString &dir : pwd.entryList(QDir::Dirs | QDir::NoDotAndDotDot))
        find_files(path + "/" + dir, pattern, found, false);
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
    for (auto const &line : rawlines) {
        nextline.append(line);
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
        qCDebug(lcBackup) << "Odd number of single quotes in DB dump.";
    }
    return lines;
}

void mv(QString const &src, QString const &dest)
{
    if (QFile::exists(dest))
        QFile::remove(dest);
    if (!QFile::rename(src, dest))
        throw std::runtime_error("Rename: " + src.toStdString() + " " + dest.toStdString());
}

void rm(QString const &path)
{
    if (!QFile::remove(path))
        throw std::runtime_error("Remove: " + path.toStdString());
}

void cp(QString const &src, QString dest)
{
    if (QFileInfo(dest).isDir())
       dest += "/" + src.split('/').last();
    if (QFile::exists(dest))
        QFile::remove(dest);
    if (!QFile::copy(src, dest))
        throw std::runtime_error("Fail: cp " + src.toStdString() + " " + dest.toStdString());
}

QString dirName(QString const &path)
{
    return QFileInfo(path).dir().path();
}

void mkpath(QString const &path)
{
    if (!QDir().mkpath(path))
        throw std::runtime_error("mkpath: " + path.toStdString());
}

QString fixPath(const QString &path)
{
    // Check that the path is as expected and replace dynamic parts
    QRegExp re("^[\\w/-]+/.local/share/[\\w/-]+/QML/OfflineStorage/Databases/(.+)$");
    if (!re.exactMatch(path)) {
        qCWarning(lcBackup) << "Path did not match regexp" << path;
        return path;
    }
    auto newPath = NotesDirectory.arg(QDir::homePath()) + re.cap(1);
    qCDebug(lcBackup) << "Fixed path" << path << "to" << newPath;
    return newPath;
}

// TODO generic function, create the-vault-unit-sql package from it
void process_sqlite_import(QString const &data, QString const &opt_dir)
{
    std::list<std::function<void()> > on_ok, on_error;

    typedef std::function<void(QString const &)> process_type;
    process_type skip = [](QString const &){};
    process_type write = [](QString const &) {
        throw std::runtime_error("Database is not opened yet");
    };

    typedef std::function<process_type (str_map_type const &)> action_type;

    action_type on_version = [skip](str_map_type const &info) {
        bool ok = false;
        auto ver = info["data"].toInt(&ok);
        if (!(ok && ver == 1)) {
            throw std::runtime_error("Unsupported notes export version. Got "
                                     + info["data"].toStdString() + "expected 1");
        }
        return skip;
    };

    action_type on_db = [skip, &on_error, &on_ok, &write](str_map_type const &info) {
        auto const db_name = fixPath(info["data"]);
        if (QFileInfo(db_name).isFile()) {
            // backup existing db
            mv(db_name, db_name + ".back");
            on_error.push_back([db_name]() { mv(db_name + ".back", db_name); });
            on_ok.push_back([db_name]() { rm(db_name + ".back"); });
        } else {
            mkpath(dirName(db_name));
        }

        QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
        db.setDatabaseName(db_name);
        db.open();
        on_ok.push_back([db]() mutable { db.close(); });
        write = [db](QString const &line) mutable {
            QSqlQuery q(db);
            bool res = q.exec(line);
            return res;
        };
        return skip;
    };

    action_type on_file = [skip, &on_error, &on_ok, opt_dir](str_map_type const &info) {
        auto dst_name = fixPath(info["data"]);
        auto src_name = opt_dir + "/" + QFileInfo(dst_name).fileName();

        if (QFileInfo(dst_name).isFile()) {
            // backup existing file
            mv(dst_name, dst_name + ".back");
            on_error.push_back([dst_name]() { mv(dst_name + ".back", dst_name); });
            on_ok.push_back([dst_name]() { rm(dst_name + ".back"); });
        } else {
            mkpath(dirName(dst_name));
        }
        cp(src_name, dst_name);
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
        process_type process_data = skip;
        for (auto const &line : lines) {
            action_type action;
            auto info = parse_export_line(line);
            if (!info["tag"].isEmpty()) {
                action = actions.value(info["tag"], skip_action);
                process_data = action(info);
            } else {
                process_data(info["data"]);
            }
        }
        for (auto &ok_function : on_ok)
            ok_function();
    } catch(...) {
        for (auto &error_function : on_error)
            error_function();
        throw;
    }
}

int get_filenames(QString &db_name, QString &ini_name)
{
    auto notes_dir = NotesDirectory.arg(QDir::homePath());
    if (!QFileInfo(notes_dir).exists()) {
        qCDebug(lcBackup) << "Nothing to backup, no directory:" << notes_dir;
        return 1;
    }
    QStringList files;
    find_files(notes_dir, "*.sqlite", files);
    if (!files.size()) {
        qCDebug(lcBackup) << "No sqlite notes db, nothing to export";
        return 1;
    }
    db_name = files[0];

    find_files(notes_dir, "*.ini", files);
    if (!files.size()) {
        qCDebug(lcBackup) << "No sqlite notes db ini found";
        return 1;
    }
    ini_name = files[0];
    return 0;
}

QString sql_query(QString const &db_name, QString const &ini_name)
{
    QStringList data = {
        "-- @version@1",
        "-- @file@" + ini_name,
        "-- @db@" + db_name,
        "-- @delete@",
        "DROP TABLE notes;",
        "-- @create@",
        "CREATE TABLE notes (pagenr INTEGER, color TEXT, body TEXT);",
        "-- @data@"
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
    return data.join("\n");
}

void export_notes()
{
    QString db_name;
    QString ini_name;
    if (get_filenames(db_name, ini_name) != 0) {
        return;
    }

    auto data = sql_query(db_name, ini_name);
    auto out_dir = vault::unit::optValue("dir");
    auto sql_fname = get_export_fname(out_dir);

    qCDebug(lcBackup) << "Writing data to" << sql_fname;
    QFile f(sql_fname);
    if (f.open(QFile::WriteOnly)) {
        f.write(data.toUtf8());
    } else {
        qCDebug(lcBackup) << "Can't open " << sql_fname;
    }
    f.close();
    qCDebug(lcBackup) << "Copying ini from" << ini_name << "to" << out_dir;
    cp(ini_name, out_dir);
}

void import_notes()
{
    vault::unit::runProcess("pkill", {"^jolla-notes$"});
    QString const opt_dir = vault::unit::optValue("dir");
    auto sql_fname = get_export_fname(opt_dir);
    qCDebug(lcBackup) << "Reading data from" << sql_fname;
    if (QFileInfo(sql_fname).exists()) {
        QFile file(sql_fname);
        if (file.open(QFile::ReadOnly)) {
            auto data = file.readAll();
            process_sqlite_import(data, opt_dir);
            file.close();
        } else {
            qCDebug(lcBackup) << "Reading" << sql_fname << "failed";
        }
    } else {
        qCDebug(lcBackup) << "Nothing to import, no file" << sql_fname;
    }
}

}

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    auto action = vault::unit::optValue("action");
    try {
        if (action == "export") {
            export_notes();
        } else if (action == "import") {
            import_notes();
        }
        else {
            return 1;
        }
    } catch (std::exception const &e) {
        qCDebug(lcBackup) << e.what();
        return 1;
    }
    return 0;
}
