// SPDX-FileCopyrightText: 2025 Damien Caliste
//
// SPDX-License-Identifier: BSD-3-Clause

#ifndef DIRECTORYFILES_H
#define DIRECTORYFILES_H

#include <QObject>
#include <QThread>
#include <QMap>
#include <QVariant>
#include <QString>
#include <QStringList>
#include <QDir>
#include <QFileSystemWatcher>
#include <QSharedPointer>
#include <QSettings>
#include <QTimer>

class File
{
    Q_GADGET
    Q_PROPERTY(QString name MEMBER mName)
    Q_PROPERTY(QString body MEMBER mBody)
    Q_PROPERTY(QString color MEMBER mColor)

public:
    QString mName;
    QString mBody;
    QString mColor;
};
Q_DECLARE_METATYPE(File)
Q_DECLARE_METATYPE(File*)

class DirectoryWorker : public QObject
{
    Q_OBJECT

public:
    DirectoryWorker(QObject *parent = nullptr);
    ~DirectoryWorker();

public slots:
    void setDirectory(const QString &path);
    void add(const QString &fileName, const QString &body, const QString &color);
    void updateBody(const QString &fileName, const QString &body);
    void updateColor(const QString &fileName, const QString &color);
    void remove(const QString &fileName);

signals:
    void filesListed(QStringList sortedList, QList<File*> newFiles);
    void fileUpdated(QString fileName, QString body);
    void fileDeleted(QString fileName);

private:
    void onDirectoryChanged(const QString &path);
    void onFileChanged(const QString &path);
    
    QDir mDir;
    QFileSystemWatcher mWatcher;
    QSettings *mMetaData = nullptr;
};

class DirectoryFiles : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool ready READ ready NOTIFY readyChanged)
    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged)

public:
    DirectoryFiles(QObject *parent = nullptr);
    ~DirectoryFiles();

    bool ready() const;

    QString path() const;
    void setPath(const QString &uid);

    Q_INVOKABLE bool validatePath(const QString &path) const;

    Q_INVOKABLE QStringList listFilenames(const QString &filter = QString()) const;
    Q_INVOKABLE QVariant file(const QString &fileName) const;

    Q_INVOKABLE QVariant add(int position, const QString &name, const QString &body, const QString &color);
    Q_INVOKABLE void updateBody(const QString &fileName, const QString &body);
    Q_INVOKABLE void updateColorString(const QString &fileName, const QString &color);
    Q_INVOKABLE void updateTimeStamp(const QString &fileName);
    Q_INVOKABLE void remove(const QString &fileName);

signals:
    void readyChanged();
    void pathChanged();
    void modified();

private:
    void onFileDeleted(QString fileName);
    void onFilesListed(QStringList sortedList, QList<File*> newFiles);
    void onFileUpdated(QString fileName, QString body);

    bool mReady = false;
    QString mPath;
    QStringList mSortedFileNames;
    QMap<QString, QSharedPointer<File>> mFilesByName;
    QThread mWorkerThread;
    DirectoryWorker mWorker;
    QTimer mModifiedDelay;
};

#endif
