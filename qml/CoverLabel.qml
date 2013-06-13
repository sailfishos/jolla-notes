import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0

Item {
    property alias color: label.color
    property alias text: label.text
    property alias pageNumber: pageNumberLabel.text
    property alias maximumLineCount: label.maximumLineCount

    Text {
        id: label
        lineHeight: 0.8
        font.pixelSize: Theme.fontSizeMedium
        color: Theme.primaryColor
        anchors {
            left: parent.left
            right: pageNumberLabel.left
            top: parent.top
            bottom: parent.bottom
            bottomMargin: Theme.paddingMedium
        }
    }

    OpacityRampEffect {
        sourceItem: label
        offset: 0.3
        slope: 1.2
    }

    Label {
        id: pageNumberLabel
        color: label.color

        property int number: parseInt(text)

        anchors {
            right: parent.right
            bottom: label.bottom
            bottomMargin: -4
        }
        font.pixelSize: number < 10 ? Theme.fontSizeHuge
                                    : number < 100 ? Theme.fontSizeLarge
                                                   : number < 1000 ? Theme.fontSizeMedium
                                                                   : Theme.fontSizeSmall
    }
}
