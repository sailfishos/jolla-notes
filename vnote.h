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
