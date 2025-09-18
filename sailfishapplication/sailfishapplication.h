// SPDX-FileCopyrightText: 2013 - 2015 Jolla Ltd.
// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

#ifndef SAILFISHAPPLICATION_H
#define SAILFISHAPPLICATION_H

class QString;
class QGuiApplication;
class QQuickView;

namespace Sailfish {

QGuiApplication *createApplication(int &argc, char **argv);
QQuickView *createView(const QString & = QString::null);
void setSource(QQuickView *view, const QString &file);
void showView(QQuickView* view);

}

#endif // SAILFISHAPPLICATION_H

