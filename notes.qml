import QtQuick 1.1
import Sailfish.Silica 1.0
import "qml"

ApplicationWindow
{
    id: app
    initialPage: OverviewPage { id: overviewpage }
    cover: Qt.resolvedUrl("qml/CoverPage.qml")
}
