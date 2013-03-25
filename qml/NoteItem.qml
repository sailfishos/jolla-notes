import QtQuick 1.1
import Sailfish.Silica 1.0

import "colors.js" as ColorUtil

MouseArea {
    property int pageNumber
    property color color
    property string text

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
}
