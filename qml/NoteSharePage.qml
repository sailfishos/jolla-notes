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
import Sailfish.TransferEngine 1.0

Page {
    id: page

    property string name
    property string text
    property string type: "text/plain"
    property string icon: "icon-launcher-notes"

    ShareMethodList {
        id: methodlist

        anchors.fill: parent
        header: PageHeader {
            //: Page header for share method selection
            //% "Share note"
            title: qsTrId("notes-he-share-note")
        }
        content: {
            "name": name,
            "data": text,
            "type": type,
            "icon": icon,
            // also some non-standard fields for Twitter/Facebook status sharing:
            "status" : text,
            "linkTitle" : name
        }
        filter: type

        ViewPlaceholder {
            enabled: methodlist.count == 0
            //: Empty state for share method selection page
            //% "No sharing accounts available. You can add accounts in settings"
            text: qsTrId("notes-ph-no-share-methods")
        }
    }
}
