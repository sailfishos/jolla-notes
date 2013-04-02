import QtQuick 1.1
import Sailfish.Silica 1.0

Page {
    id: notePage

    property int currentIndex: -1
    property alias editMode: textArea.focus

    onCurrentIndexChanged: {
        if (currentIndex >= 0 && currentIndex < notesModel.count) {
            var item = notesModel.get(currentIndex)
            noteview.savedText = item.text
            noteview.text = item.text
            noteview.color = item.color
            noteview.pageNumber = item.pagenr
        } else {
            noteview.savedText = ''
            noteview.text = ''
            noteview.color = "white"
            noteview.pageNumber = 0
        }
    }

    SilicaFlickable {
        id: noteview

        property color color
        property alias text: textArea.text
        property int pageNumber
        property string savedText

        anchors.fill: parent

        TextArea {
            id: textArea
            anchors.fill: parent
            font { family: theme.fontFamily; pixelSize: theme.fontSizeMedium }

            onTextChanged: {
                if (text != noteview.savedText)
                    notesModel.updateNote(currentIndex, text)
                noteview.savedText = text
            }
        }
    }    
}
