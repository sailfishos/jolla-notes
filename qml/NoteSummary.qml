import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0

Text {
    anchors {
        top: parent.top
        topMargin: - (font.pixelSize / 4)
        left: parent.left
        right: parent.right
    }
    height: parent.height
    font { family: Theme.fontFamily; pixelSize: Theme.fontSizeSmall }
    color: Theme.primaryColor
    textFormat: Text.PlainText
    wrapMode: Text.Wrap
    // @todo this uses an approximation of the real line height.
    // Is there any way to get the exact height?
    maximumLineCount: Math.floor((height - Theme.paddingLarge) / (font.pixelSize * 1.1875))
// XXX Qt5 port - until QTBUG-31471 fix is available
//    elide: Text.ElideRight
}
