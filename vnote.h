/*
 * Copyright (C) 2012-2015 Jolla Ltd.
 *
 * The code in this file is distributed under multiple licenses, and as such,
 * may be used under any one of the following licenses:
 *
 *   - GNU General Public License as published by the Free Software Foundation;
 *     either version 2 of the License (see LICENSE.GPLv2 in the root directory
 *     for full terms), or (at your option) any later version.
 *   - GNU Lesser General Public License as published by the Free Software
 *     Foundation; either version 2.1 of the License (see LICENSE.LGPLv21 in the
 *     root directory for full terms), or (at your option) any later version.
 *   - Alternatively, if you have a commercial license agreement with Jolla Ltd,
 *     you may use the code under the terms of that license instead.
 *
 * You can visit <https://sailfishos.org/legal/> for more information
 */

#ifndef VNOTE_H
#define VNOTE_H

#include <QObject>
#include <QString>
#include <QDateTime>
#include <QStringList>

class VNoteConverter : public QObject
{
    Q_OBJECT

public:
    VNoteConverter(QObject *parent = 0);
    Q_INVOKABLE QString vNote(const QString &noteText,
                              const QDateTime &createdDate = QDateTime(),
                              const QDateTime &modifiedDate = QDateTime()) const;
    Q_INVOKABLE QStringList plainTextNotes(const QString &vnoteText) const;
    Q_INVOKABLE QStringList importFromFile(const QUrl &filePath) const;
};

#endif
