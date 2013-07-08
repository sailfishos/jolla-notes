import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0

Item {
    property alias color: label.color
    property alias text: label.text
    property alias pageNumber: pageNumberLabel.text
    property alias maximumLineCount: label.maximumLineCount
    property real lineHeight

    height: lineHeight * label.maximumLineCount

    Label {
        id: label
        lineHeight: 0.8
        height: implicitHeight + Theme.paddingMedium
        anchors {
            left: parent.left
            right: pageNumberLabel.left
            bottom: parent.bottom
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
            baseline: label.baseline
            baselineOffset: parent.lineHeight * (label.lineCount-1)
        }
        font.pixelSize: number < 10 ? Theme.fontSizeHuge
                                    : number < 100 ? Theme.fontSizeLarge
                                                   : number < 1000 ? Theme.fontSizeMedium
                                                                   : Theme.fontSizeSmall
    }
}
