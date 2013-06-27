import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0

Rectangle {
    signal clicked
    property alias pageNumber: label.text

    height: Theme.itemSizeExtraSmall
    width: Theme.itemSizeExtraSmall
    radius: Theme.paddingSmall/2
    anchors {
        right: parent.right
        rightMargin: Theme.paddingLarge
        verticalCenter: parent.verticalCenter
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
