// Helper functions specifically for jolla-notes testing,
// on top of SilicaTestCase which has the general helpers.
// Assumption: the application window has id 'main'

import QtTest 1.0
import QtQuick.LocalStorage 2.0 as Sql

SilicaTestCase {
    property var defaultNotes: ["Fear", "Surprise", "Ruthless efficiency",
                                "Fanatical devotion", "Nice red uniforms"]

    // Notes doesn't rely on the pagestack transition speed,
    // so speed it up for faster tests.
    onRunningChanged: if (running) fastforward_page_transitions()

    // This is temporary -- some debug logging until the keyboard related
    // tests are stable in the VM.
    SignalSpy {
        id: imsizespy
        signalName: "imSizeChanged"
        target: main.pageStack

        onCountChanged: {
            console.log("imSize " + main.pageStack.imSize + " count " + count)
        }
    }

    function clear_db() {
        var db = Sql.LocalStorage.openDatabaseSync('silicanotes', '', 'Notes', 10000)
        db.transaction(function (tx) {
            tx.executeSql('DELETE FROM notes')
            tx.executeSql('UPDATE next_color_index SET value = 0')
        })
    }

    // Create some notes to use for other tests.
    // Ends at the first listed note's page.
    function make_notes_fixture(notes) {
        var oldCount = notesModel.count
        for (var i = notes.length-1; i >= 0; i--) {
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
        // Skip the delay before the last note is saved.
        // It's cheating, but it's ok because this is a _fixture function.
        currentPage.saveNote()
        compare(notesModel.count, oldCount + notes.length)
    }

    function check_deletion(old_count, notetext) {
	// Check that the note has been deleted
	wait_for("note item gone from overview", function () {
	    return !find_text(currentPage, notetext)
	})
        compare(notesModel.count, old_count-1, "a note has been deleted")
        for (var i = 0; i < notesModel.count; i++) {
            if (notesModel.get(i).text == notetext)
            	fail("note deleted from model")
        }
    }

    function check_remorse() {
        var remorse = wait_find("remorse item started", currentPage,
                                function (it) {
            return it.text == "notes-la-deleting"
                   && it.visible && it.opacity == 1.0
        })
            fastforward_remorseitem(remorse)
    }
}
