import QtQuick 2.0

Item {
    // providing dummy translations for app descriptions shown on Store
    function qsTrIdString() {
        //% "Notes is a handy app for writing down things you need to remember. "
        //% "With Notes app you can quickly write small notes and memos."
        QT_TRID_NOOP("notes-la-store_app_summary")

        //% "You can quickly create a new note using the cover action or the quick action in Top Menu. "
        //% "Use the main page pulley to find a specific note using word search. Set colours for notes, "
        //% "so you can categorise them more easily. Long press a word to select it. Keeping your finger "
        //% "pressed a bit longer will select the entire row and finally everything. Adjust text selection "
        //% "by moving handles horizontally. Text is automatically copied to clipboard when a selection is "
        //% "made or changed. Paste by tapping the clipboard icon on top left of the keyboard."
        QT_TRID_NOOP("notes-la-store_app_description")
    }
}
