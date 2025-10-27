// SPDX-FileCopyrightText: 2025 Damien Caliste
//
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: root

    signal selected(string providerId, string sourceId)

    function select(provider, uid) {
        selected(provider, uid)
        pageStack.pop()
    }

    SilicaFlickable {
        anchors.fill: parent

        contentHeight: column.height

        Column {
            id: column
            width: parent.width

            PageHeader {
                //% "note providers"
                title: qsTrId("notes-la-providers")
            }

            ProviderItem {
                //% "On device"
                text: qsTrId("notes-me-local")
                onClicked: select("local", "")
            }
            Repeater {
                model: journalProvider.model
                delegate: ProviderItem {
                    text: accountDisplayName
                    description: providerDisplayName
                    iconSource: accountIcon
                    onClicked: select("journals", StandardPaths.cache + "/nextcloud-" + accountId + "-mkcal.db")
                }
            }
        }

        VerticalScrollDecorator {}
    }
}
