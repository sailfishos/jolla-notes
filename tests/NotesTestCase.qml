// Helper functions specifically for jolla-notes testing,
// on top of SilicaTestCase which has the general helpers.
// Assumption: the application window has id 'main'

import QtQuickTest 1.0

SilicaTestCase {

    // Notes doesn't rely on the pagestack transition speed,
    // so speed it up for faster tests.
    onRunningChanged: if (running) fastforward_page_transitions()

    // This is temporary -- some debug logging until the keyboard related
    // tests are stable in the VM.
    SignalSpy {
        id: imsizespy
        signalName: "imSizeChanged"
        target: pageStack

        onCountChanged: {
            console.log("imSize " + pageStack.imSize + " count " + count)
        }
    }

    function clear_db() {
        var db = openDatabaseSync('silicanotes', '', 'Notes', 10000)
        db.transaction(function (tx) {
            tx.executeSql('DELETE FROM notes')
            tx.executeSql('UPDATE next_color_index SET value = 0')
        })
    }

    // Create some notes to use for other tests.
    // Ends at the last created note's page.
    function make_notes_fixture(notes) {
        var oldCount = notesModel.count
        for (var i = 0; i < notes.length; i++) {
            select_pull_down('notes-me-new-note')
            wait_pagestack()
            // Wait for an empty note page
            wait_find("empty note page", main, function(it) {
                return it.text == ""
                       && it.placeholderText == "notes-ph-empty-note"
            })
            compare(currentPage.text, '')
            currentPage.text = notes[i]
            wait_inputpanel_open()
            wait_animation_stop(currentPage)
        }
        compare(notesModel.count, oldCount + notes.length,
                "" + notes.length + " notes created")
    }
}
