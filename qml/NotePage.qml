import QtQuick 1.1
import Sailfish.Silica 1.0

Page {
    id: notePage

    property alias currentIndex: notesList.currentIndex

    SlideshowView {
        id: notesList

        model: notesModel
        anchors.fill: parent
        interactive: count > 1

        delegate:  Item {
            id: wrapper

            property Item contentItem
            width: PathView.view.width
            height: notePage.height

            Component.onCompleted: {
                contentItem = itemPool.get(wrapper)
                contentItem.text = model.text
                contentItem.color = model.color
            }
            Component.onDestruction: {
                itemPool.free(contentItem)
            }
        }
    }
    ItemPool {
        id: itemPool
        SilicaFlickable {

            property color color
            property alias text: textArea.text

            focus: true
            anchors.fill: parent

            TextArea {
                id: textArea
                focus: true
                anchors.fill: parent
            }
        }
    }    
}
