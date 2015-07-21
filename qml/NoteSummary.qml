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

import QtQuick 2.0
import Sailfish.Silica 1.0

Text {
    anchors {
        top: parent.top
        topMargin: - (font.pixelSize / 4)
        left: parent.left
        right: parent.right
    }
    height: parent.height
    font { family: Theme.fontFamily; pixelSize: Theme.fontSizeSmall }
    color: Theme.primaryColor
    textFormat: Text.PlainText
    wrapMode: Text.Wrap
    // @todo this uses an approximation of the real line height.
    // Is there any way to get the exact height?
    maximumLineCount: Math.floor((height - Theme.paddingLarge) / (font.pixelSize * 1.1875))
// XXX Qt5 port - until QTBUG-31471 fix is available
//    elide: Text.ElideRight
}
