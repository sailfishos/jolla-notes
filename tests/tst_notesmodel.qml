// SPDX-FileCopyrightText: 2017 Jolla Ltd.
// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick 2.0
import QtTest 1.0
import "../../../usr/share/jolla-notes/pages"

TestCase {
    name: "NotesModel"

    SignalSpy {
        id: countSpy

        target: model
        signalName: "countChanged"
    }
    SignalSpy {
        id: populatedSpy

        target: model
        signalName: "populatedChanged"
    }
    NotesModel {
        id: model
    }

    function initTestCase() {
        if (!model.populated) {
            populatedSpy.clear()
            populatedSpy.wait()
            cleanup()
        }
    }

    function cleanup() {
        while (model.count > 0) {
            model.deleteNote(model.get(0).uid)
            countSpy.clear()
            countSpy.wait()
        }
    }

    function test_model() {
        var count = model.count

        model.newNote(1, "First text", model.nextColor())
        console.log("Add new note")
        count = count + 1
        countSpy.clear()
        countSpy.wait()
        compare(model.count, count)

        console.log("Add new note")
        model.newNote(1, "Second text", model.nextColor())
        count = count + 1
        countSpy.clear()
        countSpy.wait()
        compare(model.count, count)
        compare(model.get(0).text, "Second text")

        console.log("Search")
        model.filter = "Fi"
        countSpy.clear()
        countSpy.wait()
        compare(model.get(0).text, "First text")

        console.log("Remove search")
        model.filter = ""
        countSpy.clear()
        countSpy.wait()
        compare(model.get(0).text, "Second text")
        compare(model.count, count)

        console.log("Search no results")
        model.filter = "unlikely_STRING_.;?+"
        countSpy.clear()
        countSpy.wait()
        compare(model.count, 0)

        console.log("Another search")
        model.filter = "rst"
        countSpy.clear()
        countSpy.wait()
        compare(model.get(0).text, "First text")
        verify(model.count > 0)

        console.log("Remove search")
        model.filter = ""
        countSpy.clear()
        countSpy.wait()
        compare(model.count, count)

        console.log("Delete")
        model.deleteNote(model.get(0).uid)
        count = count - 1
        countSpy.clear()
        countSpy.wait()
        compare(model.count, count)
        compare(model.get(0).text, "First text")
    }

    function test_specialcharacters() {
        var count = model.count

        model.newNote(1, "'\n%", model.nextColor())
        model.newNote(1, "'\n%", model.nextColor())
        model.newNote(1, '"\\_', model.nextColor())
        console.log("Add two notes with special characters")
        count = count + 3
        countSpy.clear()
        countSpy.wait()
        compare(model.count, count)

        model.filter = "\n"
        countSpy.clear()
        countSpy.wait()
        tryCompare(model, "count", 2)
        compare(model.get(0).text, "'\n%")

        console.log("Searching with \\")
        model.filter = "\\"
        tryCompare(model, "count", 1)
        compare(model.get(0).text, '"\\_')
        console.log("Searching with \\n")

        console.log("Searching with '")
        model.filter = "'"
        tryCompare(model, "count", 2)
        compare(model.get(0).text, "'\n%")

        console.log('Searching with "')
        model.filter = '"'
        tryCompare(model, "count", 1)
        compare(model.get(0).text, '"\\_')

        console.log('Searching with %')
        model.filter = "%"
        tryCompare(model, "count", 2)
        compare(model.get(0).text, "'\n%")

        console.log('Searching with _')
        model.filter = '_'
        tryCompare(model, "count", 1)
        compare(model.get(0).text, '"\\_')
    }
}
