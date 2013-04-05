import QtQuick 1.1
import Sailfish.Silica 1.0

import "colors.js" as ColorUtil

MouseArea {
    id: noteitem

    property int pageNumber
    property color color
    property alias text: summary.text

    // Create a tint with 10% of the primaryColor in the lower left,
    // down to 0% in the upper right.
    // Is there any way to use OpacityRampEffect instead of Gradient here?
    Item {
        // The rectangle inside is rotated to rotate the gradient,
        // but then it needs to be clipped back to an upright square.
        // This container item does the clipping so that the NoteItem itself
        // doesn't have to clip (which would interfere with context menus)
        anchors.fill: parent
        clip: true

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
    }

    Item {
        anchors { fill: parent; margins: theme.paddingLarge }

        NoteSummary {
            id: summary
        }

        OpacityRampEffect {
            sourceItem: summary
            slope: 0.6
            offset: 0
            direction: OpacityRampEffect.TopToBottom
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
        font { family: theme.fontFamily; pixelSize: theme.fontSizeLarge }
        horizontalAlignment: Text.AlignRight
        text: noteitem.pageNumber
    }
}
