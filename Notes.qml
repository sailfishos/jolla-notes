/*
 * Copyright (C) 2012-2015 Jolla Ltd.
 *
 * The code in this file is distributed under multiple licenses, and as such,
 * may be used under any one of the following licenses:
 *
 *   - GNU General Public License as published by the Free Software Foundation;
 *     either version 2 of the License (see LICENSE.GPLv2 in the root directory
 *     for full terms), or (at your option) any later version.
 *   - GNU Lesser General Public License as published by the Free Software
 *     Foundation; either version 2.1 of the License (see LICENSE.LGPLv21 in the
 *     root directory for full terms), or (at your option) any later version.
 *   - Alternatively, if you have a commercial license agreement with Jolla Ltd,
 *     you may use the code under the terms of that license instead.
 *
 * You can visit <https://sailfishos.org/legal/> for more information
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.dbus 2.0
import "qml"

ApplicationWindow
{
    id: app

    property Item currentNotePage

    initialPage: Component {
        OverviewPage {
            id: overviewpage
            property Item currentPage: pageStack.currentPage
            onCurrentPageChanged: {
                if (currentPage == overviewpage) {
                    currentNotePage = null
                } else if (currentPage.hasOwnProperty("__jollanotes_notepage")) {
                    currentNotePage = currentPage
                }
            }
        }
    }
    cover: Qt.resolvedUrl("qml/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations
    _defaultPageOrientations: Orientation.All
    _defaultLabelFormat: Text.PlainText

    // exposed as a property so that the tests can access it
    property NotesModel notesModel: NotesModel { id: notesModel }

    function openNewNote(operationType) {
        pageStack.push(notePage, {potentialPage: 1, editMode: true}, operationType)
    }

    Component {
        id: notePage
        NotePage { }
    }

    DBusAdaptor {
        service: "com.jolla.notes"
        path: "/"
        iface: "com.jolla.notes"

        function newNote() {
            if (pageStack.currentPage.__jollanotes_notepage === undefined || pageStack.currentPage.currentIndex >= 0) {
                // don't open a new note if already showing a new unedited note
                openNewNote(PageStackAction.Immediate)
            }
            app.activate()
        }

        function importNoteFile(pathList) {
            // If the user has an empty note open (or we automatically pushed newNote
            // page due to having no notes) then we need to pop that page.
            if (notesModel.count == 0
                    && pageStack.currentPage.__jollanotes_notepage !== undefined
                    && pageStack.currentPage.potentialPage == 1) {
                pageStack.pop(null, true)
            }

            // For compatibility reasons this signal sometimes receives an array of strings
            var filePath
            if (typeof pathList === 'string') {
                filePath = pathList
            } else if (typeof pathList === 'object' && pathList.length !== undefined && pathList.length > 0) {
                filePath = pathList[0]
                if (pathList.length > 1) {
                    console.warn('jolla-notes: Importing only first path from:', pathList)
                }
            }
            if (filePath && (String(filePath) != '')) {
                console.log('jolla-notes: Importing note file:', filePath)
                var plaintextNotes = vnoteConverter.importFromFile(filePath)
                var originalNotesModelCount = notesModel.count
                for (var index in plaintextNotes) {
                    // insert the note into the database
                    notesModel.newNote(notesModel.count+1, plaintextNotes[index], notesModel.nextColor())
                }
                while (originalNotesModelCount < notesModel.count) {
                    if (pageStack.currentPage.__jollanotes_notepage === undefined) {
                        // the current page is the overview page.  indicate to the user which notes were imported,
                        // by flashing the delegates of the imported notes in the gridview.
                        pageStack.currentPage.flashGridDelegate(originalNotesModelCount)
                    } else {
                        // a note is currently open.  Queue up the indication to the user
                        // so that it gets displayed when they next return to the gridview.
                        var overviewPage = pageStack.previousPage(pageStack.currentPage)
                        overviewPage._flashDelegateIndexes[overviewPage._flashDelegateIndexes.length] = originalNotesModelCount
                    }
                    originalNotesModelCount++
                }
                app.activate()
            }
        }
    }
}
