import QtQuick 1.1
import Sailfish.Silica 1.0

import "colors.js" as ColorUtil

MouseArea {
    id: noteitem

    property int pageNumber
    property color color
    property string text

    clip: true;

    // Create a tint with 10% of the primaryColor in the lower left,
    // down to 0% in the upper right.
    // Is there any way to use OpacityRampEffect instead of Gradient here?
    Rectangle {
        rotation: 45 // diagonal gradient
        // Use square root of 2, rounded up a little bit, to make the
        // rotated square cover all of the parent square
        width: parent.width * 1.412136
        height: parent.height * 1.412136
        x: parent.width - width

        gradient: Gradient {
            GradientStop { position: 0.0; color: ColorUtil.set_alpha(theme.primaryColor, 0) }
            GradientStop { position: 1.0; color: ColorUtil.set_alpha(theme.primaryColor, 0.1) }
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: theme.paddingLarge

        Text {
            anchors.fill: parent
            anchors.bottomMargin: theme.paddingLarge
            font { pixelSize: theme.fontSizeMedium }
            color: theme.primaryColor
            textFormat: Text.PlainText
            wrapMode: Text.Wrap
            // @todo this uses an approximation of the real line height.
            // Is there any way to get the exact height?
            maximumLineCount: Math.floor(height / (font.pixelSize * 1.1875))
            elide: Text.ElideRight
            text: noteitem.text
        }

        Rectangle {
            id: colortag

            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: 64
            height: 8
            radius: 2
            color: noteitem.color
        }
    }

    Text {
        id: pagenumber

        anchors.baseline: parent.bottom
        anchors.baselineOffset: -theme.paddingMedium
        anchors.right: parent.right
        anchors.rightMargin: theme.paddingMedium
        opacity: 0.4
        color: theme.primaryColor
        font { pixelSize: theme.fontSizeExtraLarge }
        horizontalAlignment: Text.AlignRight
        text: noteitem.pageNumber
    }
}
