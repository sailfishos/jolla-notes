// SPDX-FileCopyrightText: 2013 - 2017 Jolla Ltd.
// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

#ifndef VNOTE_H
#define VNOTE_H

#include <QObject>
#include <QString>
#include <QDateTime>
#include <QStringList>

QT_BEGIN_NAMESPACE
class QTextStream;
QT_END_NAMESPACE

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

    QStringList plainTextNotes(QTextStream &stream) const;
};

#endif
