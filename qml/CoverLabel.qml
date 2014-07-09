import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property alias color: pageNumberLabel.color
    property alias text: label.text
    property alias pageNumber: pageNumberLabel.text
    property alias maximumLineCount: label.maximumLineCount
    property real lineHeight

    height: lineHeight * label.maximumLineCount

    Label {
        id: label

        lineHeight: 0.8
        font.pixelSize: Theme.fontSizeSmall
        // extra padding is needed to avoid clipping by the opacity ramp
        height: implicitHeight + Theme.paddingMedium
        anchors {
            left: parent.left
            bottom: parent.bottom
            right: pageNumberLabel.left
        }
    }

    OpacityRampEffect {
        sourceItem: label
        offset: 0.3
        slope: 1.2
    }

    Label {
        id: pageNumberLabel

        property int number: parseInt(text)

        anchors {
            right: parent.right
            baseline: label.baseline
            baselineOffset: parent.lineHeight * (label.lineCount-1)
        }
        font.pixelSize: number < 10 ? Theme.fontSizeHuge
                                    : number < 1000 ? Theme.fontSizeLarge
                                                   : number < 10000 ? Theme.fontSizeMedium
                                                                   : Theme.fontSizeSmall
    }
}
