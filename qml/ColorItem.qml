import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0

Rectangle {
    signal clicked
    property bool isPortrait
    property alias pageNumber: label.text

    height: Theme.itemSizeExtraSmall
    width: Theme.itemSizeExtraSmall
    radius: Theme.paddingSmall/2
    anchors {
        right: isPortrait ? parent.right : undefined
        rightMargin: Theme.paddingLarge
        verticalCenter: isPortrait ? parent.verticalCenter : undefined
        top: isPortrait ? undefined : parent.top
        topMargin: Theme.itemSizeLarge
        left: isPortrait ? undefined : parent.left
        leftMargin: Theme.paddingLarge
    }
    Label {
        id: label
        font.pixelSize: Theme.fontSizeLarge
        anchors.centerIn: parent
    }
    MouseArea {
        anchors { fill: parent; margins: -Theme.paddingMedium }
        onClicked: parent.clicked()
    }
}
