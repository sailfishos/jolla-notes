// SPDX-FileCopyrightText: 2025 Damien Caliste
//
// SPDX-License-Identifier: BSD-3-Clause

#include "directoryfiles.h"

#include <QSaveFile>
#include <QFileInfo>
#include <QDebug>

namespace {
    QString defaultColor()
    {
        static QStringList defaultColors
            = QStringList() << "red" << "blue" << "green" << "pink" << "yellow" << "violet" << "orange";
        static int next = 0;

        return defaultColors.at((next++) % defaultColors.count());
    }

    QString uniqueFileName(const QDir &dir, const QString &fileName)
    {
        const QFileInfo fileInfo(fileName);
        const QString base = fileInfo.baseName();
        QString ext = fileInfo.completeSuffix();
        if (!ext.isEmpty())
            ext.prepend(QChar('.'));

        int id = 1;
        QString unique = fileName;
        while (dir.exists(unique))
            unique = QString::fromLatin1("%1-%2%3").arg(base).arg(id++).arg(ext);
        return unique;
    }
}

DirectoryWorker::DirectoryWorker(QObject *parent)
    : QObject(parent)
{
    connect(&mWatcher, &QFileSystemWatcher::directoryChanged,
            this, &DirectoryWorker::onDirectoryChanged);
    connect(&mWatcher, &QFileSystemWatcher::fileChanged,
            this, &DirectoryWorker::onFileChanged);
}

DirectoryWorker::~DirectoryWorker()
{
}

void DirectoryWorker::onDirectoryChanged(const QString &path)
{
    Q_UNUSED(path);

    QStringList files = mWatcher.files();

    QStringList sortedFileNames;
    QList<File*> addedFiles;
    mMetaData->beginGroup(QStringLiteral("colors"));
    for (const QString &fileName : mDir.entryList(QDir::Files | QDir::NoSymLinks | QDir::Readable, QDir::Time)) {
        const QString filePath(mDir.filePath(fileName));
        if (!files.removeOne(filePath)) {
            QFile ioFile(filePath);
            if (ioFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
                File *file = new File;
                file->mName = fileName;
                file->mBody = ioFile.readAll();
                file->mColor = mMetaData->value(fileName, defaultColor()).toString();
                if (mWatcher.addPath(filePath)) {
                    qDebug() << "directory changed, adding" << fileName;
                    addedFiles << file;
                    sortedFileNames << fileName;
                } else {
                    delete file;
                }
            }
        } else {
            sortedFileNames << fileName;
        }
    }
    mMetaData->endGroup();
    if (!sortedFileNames.isEmpty()) {
        // Main thread will take ownership of File pointers.
        emit filesListed(sortedFileNames, addedFiles);
    }
}

void DirectoryWorker::onFileChanged(const QString &path)
{
    const QString fileName = QFileInfo(path).baseName();
    QFile ioFile(path);
    if (!ioFile.exists()) {
        qDebug() << "file deleted" << path;
        emit fileDeleted(fileName);
    } else if (ioFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        // The way QSaveFile is commiting the file, erase and recreate it.
        // As mentioned in the documentation, we need to readd it in that
        // case.
        if (!mWatcher.files().contains(path))
            mWatcher.addPath(path);
        qDebug() << "file changed, rereading" << path;
        emit fileUpdated(fileName, ioFile.readAll());
    } else {
        qWarning() << "cannot read file" << path;
    }
}

void DirectoryWorker::setDirectory(const QString &path)
{
    QList<File*> files;

    if (mDir.path() == path)
        return;
    mDir.setPath(path);

    delete mMetaData;
    const QString settingPath(mDir.filePath(QStringLiteral(".notes.ini")));
    mMetaData = new QSettings(settingPath, QSettings::IniFormat, this);

    if (!mWatcher.files().isEmpty())
        mWatcher.removePaths(mWatcher.files());
    if (!mWatcher.directories().isEmpty())
        mWatcher.removePaths(mWatcher.directories());
    mWatcher.addPath(path);

    onDirectoryChanged(path);
}

void DirectoryWorker::add(const QString &fileName, const QString &body, const QString &color)
{
    const QString filePath(mDir.filePath(fileName));
    QSaveFile ioFile(filePath);

    //  | QIODevice::NewOnly
    if (!ioFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "cannot open new file" << fileName << ioFile.error();
        return;
    }

    QTextStream out(&ioFile);
    out << body;

    qDebug() << "adding file" << fileName;
    if (!ioFile.commit()) {
        qWarning() << "cannot save new file" << fileName << ioFile.error();
        return;
    }

    mMetaData->setValue(QString::fromLatin1("colors/%1").arg(fileName), color);
    mMetaData->sync();
}

void DirectoryWorker::updateBody(const QString &fileName, const QString &body)
{
    const QString filePath(mDir.filePath(fileName));
    QSaveFile ioFile(filePath);

    if (!ioFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "cannot open for update file" << fileName << ioFile.error();
        return;
    }

    QTextStream out(&ioFile);
    out << body;

    qDebug() << "updating file content" << fileName;
    if (!ioFile.commit()) {
        qWarning() << "cannot save updated body" << fileName << ioFile.error();
    }
}

void DirectoryWorker::updateColor(const QString &fileName, const QString &color)
{
    qDebug() << "updating file color" << fileName;
    mMetaData->setValue(QString::fromLatin1("colors/%1").arg(fileName), color);
    mMetaData->sync();
}

void DirectoryWorker::remove(const QString &fileName)
{
    const QString filePath(mDir.filePath(fileName));
    QFile ioFile(filePath);

    qDebug() << "removing file" << fileName;
    if (!ioFile.remove()) {
        qWarning() << "cannot delete file" << fileName;
        return;
    }

    mMetaData->remove(QString::fromLatin1("colors/%1").arg(fileName));
    mMetaData->sync();
}

DirectoryFiles::DirectoryFiles(QObject *parent)
    : QObject(parent)
{
    qRegisterMetaType<QList<File*>>();

    mWorker.moveToThread(&mWorkerThread);
    connect(&mWorker, &DirectoryWorker::filesListed, this, &DirectoryFiles::onFilesListed);
    connect(&mWorker, &DirectoryWorker::fileDeleted, this, &DirectoryFiles::onFileDeleted);
    connect(&mWorker, &DirectoryWorker::fileUpdated, this, &DirectoryFiles::onFileUpdated);

    mWorkerThread.setObjectName("directory worker");
    mWorkerThread.start();

    mModifiedDelay.setInterval(25);
    mModifiedDelay.setSingleShot(true);
    connect(&mModifiedDelay, &QTimer::timeout, this, &DirectoryFiles::modified);
}

DirectoryFiles::~DirectoryFiles()
{
    mWorkerThread.quit();
    mWorkerThread.wait();
}

bool DirectoryFiles::ready() const
{
    return mReady;
}

QString DirectoryFiles::path() const
{
    return mPath;
}

void DirectoryFiles::setPath(const QString &path)
{
    if (path == mPath)
        return;

    mPath = path;
    emit pathChanged();

    if (mReady) {
        mReady = false;
        emit readyChanged();
    }

    QMetaObject::invokeMethod(&mWorker, "setDirectory", Qt::QueuedConnection,
                              Q_ARG(QString, mPath));
}

bool DirectoryFiles::validatePath(const QString &path) const
{
    QDir dir(path);

    return dir.exists() && dir.isReadable();
}

QStringList DirectoryFiles::listFilenames(const QString &filter) const
{
    qDebug() << "getting filtered list of files" << filter;
    if (filter.isEmpty()) {
        return mSortedFileNames;
    } else {
        QStringList fileNames;
        for (const QString &fileName : mSortedFileNames) {
            if (mFilesByName.value(fileName)->mBody.contains(filter, Qt::CaseInsensitive)
                || fileName.contains(filter, Qt::CaseInsensitive)) {
                fileNames.append(fileName);
            }
        }
        return fileNames;
    }
}

QVariant DirectoryFiles::file(const QString &fileName) const
{
    const QSharedPointer<File> file(mFilesByName.value(fileName));
    return QVariant::fromValue(file ? *file : File{});
}

void DirectoryFiles::onFilesListed(QStringList sortedList, QList<File*> newFiles)
{
    if (newFiles.isEmpty() && mSortedFileNames == sortedList)
        return;

    if (newFiles.count() == sortedList.count())
        mFilesByName.clear();

    mSortedFileNames = sortedList;
    for (File *file : newFiles) {
        QSharedPointer<File> item(file);
        mFilesByName.insert(item->mName, item);
    }    

    if (!mReady) {
        mReady = true;
        emit readyChanged();
    }

    qDebug() << "notifying files listed.";
    mModifiedDelay.start();
}

void DirectoryFiles::onFileDeleted(QString fileName)
{
    mFilesByName.remove(fileName);
    mSortedFileNames.removeOne(fileName);
    qDebug() << "notifying file deleted" << fileName;
    // Delay modified signal to allow patterns like saving to
    // an intermediate file and rename.
    mModifiedDelay.start();
}

void DirectoryFiles::onFileUpdated(QString fileName, QString body)
{
    QMap<QString, QSharedPointer<File>>::Iterator it = mFilesByName.find(fileName);
    if (it == mFilesByName.end()) {
        qWarning() << "cannot find updated file" << fileName;
        return;
    }
    it.value()->mBody = body;
    qDebug() << "notifying file updated" << fileName;
    mModifiedDelay.start();
}

QVariant DirectoryFiles::add(int position, const QString &name, const QString &body, const QString &color)
{
    QSharedPointer<File> item(new File);
    item->mName = uniqueFileName(QDir(mPath), name);
    item->mBody = body;
    item->mColor = color;

    mSortedFileNames.insert(position, item->mName);
    mFilesByName.insert(item->mName, item);

    QMetaObject::invokeMethod(&mWorker, "add", Qt::QueuedConnection,
                              Q_ARG(QString, item->mName),
                              Q_ARG(QString, body),
                              Q_ARG(QString, color));

    return file(item->mName);
}

void DirectoryFiles::updateBody(const QString &fileName, const QString &body)
{
    QSharedPointer<File> file(mFilesByName.value(fileName));
    if (!file) {
        qWarning() << "no file" << fileName;
        return;
    }

    file->mBody = body;

    QMetaObject::invokeMethod(&mWorker, "updateBody", Qt::QueuedConnection,
                              Q_ARG(QString, file->mName),
                              Q_ARG(QString, body));
}

void DirectoryFiles::updateColorString(const QString &fileName, const QString &color)
{
    QSharedPointer<File> file(mFilesByName.value(fileName));
    if (!file) {
        qWarning() << "no file" << fileName;
        return;
    }

    file->mColor = color;

    QMetaObject::invokeMethod(&mWorker, "updateColor", Qt::QueuedConnection,
                              Q_ARG(QString, file->mName),
                              Q_ARG(QString, color));
}

void DirectoryFiles::updateTimeStamp(const QString &fileName)
{
    QSharedPointer<File> file(mFilesByName.value(fileName));
    if (!file) {
        qWarning() << "no file" << fileName;
        return;
    }

    // Fake a change in the file, so its access time is modified.
    // From Qt5.10, use QFileDevice::setFileTime instead.
    QMetaObject::invokeMethod(&mWorker, "updateBody", Qt::QueuedConnection,
                              Q_ARG(QString, file->mName),
                              Q_ARG(QString, file->mBody));

    // Need to reorder the list, file will be first now.
    mSortedFileNames.removeOne(fileName);
    mSortedFileNames.prepend(file->mName);
}

void DirectoryFiles::remove(const QString &fileName)
{
    mFilesByName.remove(fileName);
    mSortedFileNames.removeOne(fileName);

    QMetaObject::invokeMethod(&mWorker, "remove", Qt::QueuedConnection,
                              Q_ARG(QString, fileName));
}
