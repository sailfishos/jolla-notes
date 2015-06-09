/****************************************************************************
**
** Copyright (C) 2015 Jolla Ltd.
** Contact: Chris Adams <chris.adams@jollamobile.com>
**
****************************************************************************/

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

            SectionHeader {
                //% "Sharing format"
                text: qsTrId("settings_notes-he-sharing_format")
            }

            TextSwitch {
                id: transferAsPTextSwitch
                automaticCheck: false
                //: Whether to transfer notes as plain text files
                //% "Plain-text"
                text: qsTrId("settings_notes-la-plain-text")
                checked: !transferAsVNoteConfig.value
                onClicked: {
                    if (checked) {
                        checked = false
                        transferAsVNoteSwitch.checked = true
                        transferAsVNoteConfig.value = true
                    } else {
                        checked = true
                        transferAsVNoteSwitch.checked = false
                        transferAsVNoteConfig.value = false
                    }
                }
            }

            TextSwitch {
                id: transferAsVNoteSwitch
                automaticCheck: false
                //: Whether to transfer notes as vNote files
                //% "vNote"
                text: qsTrId("settings_notes-la-vnote")
                //: Description informing the user that if this toggle is selected notes will be transferred as vNote files
                //% "Notes sent in vNote format may not be readable by the recipient"
                description: qsTrId("settings_notes-la-vnote_description")
                checked: transferAsVNoteConfig.value
                onClicked: {
                    if (checked) {
                        checked = false
                        transferAsPTextSwitch.checked = true
                        transferAsVNoteConfig.value = false
                    } else {
                        checked = true
                        transferAsPTextSwitch.checked = false
                        transferAsVNoteConfig.value = true
                    }
                }
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
