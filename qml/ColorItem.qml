import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    id: coloritem

    signal clicked
    property bool isPortrait
    property alias pageNumber: label.text

    height: Theme.itemSizeExtraSmall
    width: Theme.itemSizeExtraSmall
    radius: Theme.paddingSmall/2
    anchors {
        // The anchors that depend on isPortrait are managed with states
        // (see below) to avoid ordering problems: setting anchors to
        // 'undefined' has to be done before related anchors are assigned.
        // See http://qt-project.org/doc/qt-5/qtquick-positioning-anchors.html
        // The default state is portrait mode.
        right: parent.right
        rightMargin: Theme.paddingLarge
        verticalCenter: parent.verticalCenter
        topMargin: Theme.paddingLarge
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

    states: State {
        name: "landscape"
        when: !isPortrait
        AnchorChanges {
            target: coloritem
            anchors {
                verticalCenter: undefined
                top: parent.top
            }
        }
    }
}
