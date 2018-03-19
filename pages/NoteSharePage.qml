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
        serviceFilter: ["sharing", "e-mail", "IM"]
        containerPage: page
    }
}
