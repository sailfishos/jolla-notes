import QtQuick 1.1
import Sailfish.Silica 1.0

Item {
    property alias color: label.color
    property alias text: label.text
    property alias pageNumber: pageNumberLabel.text
    property alias maximumLineCount: label.maximumLineCount

    Column {
        id: labelColumn
        OpacityRampEffect {
            sourceItem: labelColumn
            offset: 0.3
            slope: 1.2
        }
        anchors {
            left: parent.left
            right: pageNumberLabel.left
            bottom: parent.bottom
        }
        Label {
            id: label
            lineHeight: 0.8
            width: parent.width
        }
        Item {
            height: theme.paddingMedium
            width: parent.width
        }
    }
    Label {
        id: pageNumberLabel
        color: label.color
        font.pixelSize: theme.fontSizeExtraLarge
        anchors {
            right: parent.right
            bottom: labelColumn.bottom
            bottomMargin: -4
        }
    }
}
