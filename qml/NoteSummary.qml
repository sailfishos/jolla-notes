import QtQuick 1.1
import Sailfish.Silica 1.0

Text {
    anchors {
        top: parent.top
        topMargin: - (font.pixelSize / 4)
        left: parent.left
        right: parent.right
    }
    height: parent.height
    font { family: theme.fontFamily; pixelSize: theme.fontSizeSmall }
    color: theme.primaryColor
    textFormat: Text.PlainText
    wrapMode: Text.Wrap
    // @todo this uses an approximation of the real line height.
    // Is there any way to get the exact height?
    maximumLineCount: Math.floor((height - theme.paddingLarge) / (font.pixelSize * 1.1875))
    elide: Text.ElideRight
}
