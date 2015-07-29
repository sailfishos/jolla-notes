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
import org.nemomobile.configuration 1.0
import com.jolla.notes.settings.translations 1.0

Page {
    id: settingsPage

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width

            PageHeader {
                //: Notes settings page header
                //% "Notes"
                title: qsTrId("settings_notes-he-notes")
            }

            ComboBox {
                id: transferFormatCombo
                //% "Sharing format"
                label: qsTrId("settings_notes-he-sharing_format")
                currentIndex: transferAsVNoteConfig.value == false ? 0 : 1
                onCurrentIndexChanged: transferAsVNoteConfig.value = currentIndex == 0 ? false : true
                menu: ContextMenu {
                    id: transferFormatComboMenu
                    MenuItem {
                        id: transferAsPTextMenu
                        //: Whether to transfer notes as plain text files
                        //% "Plain-text"
                        text: qsTrId("settings_notes-la-plain-text")
                    }
                    MenuItem {
                        id: transferAsVNoteMenu
                        //: Whether to transfer notes as vNote files
                        //% "vNote"
                        text: qsTrId("settings_notes-la-vnote")
                    }
                }
            }
            Label {
                id: vnoteWarningLabel
                anchors.left: transferFormatCombo.left
                anchors.leftMargin: transferFormatCombo.labelMargin
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                visible: !transferFormatComboMenu._open
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
                opacity: (!transferFormatComboMenu._open && transferFormatCombo.currentIndex == 1) ? 1.0 : 0.0
                Behavior on opacity { FadeAnimation {} }
                //: Description informing the user of the disadvantes of using vNote format for sharing
                //% "Notes sent in vNote format may not be readable by the recipient"
                text: qsTrId("settings_notes-la-vnote_description")
            }
        }
        VerticalScrollDecorator {}
    }

    ConfigurationValue {
       id: transferAsVNoteConfig
       key: "/apps/jolla-notes/settings/transferAsVNote"
       defaultValue: false
    }
}
