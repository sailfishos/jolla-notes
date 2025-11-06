// SPDX-FileCopyrightText: 2017 - 2022 Jolla Ltd.
// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

function indexOf(model, uid) {
    for (var idx = 0; idx < model.count; idx++) {
        if (model.get(idx).uid == uid)
            return idx
    }
    console.warn("unable to find index of uid", uid)
    return undefined
}

WorkerScript.onMessage = function(msg) {
    var i
    var model = msg.model

    if (msg.action === "insert") {
        model.insert(0, {
                         "uid": msg.uid,
                         "text": msg.text,
                         "color": msg.color
                     })

    } else if (msg.action === "remove") {
        model.remove(indexOf(model, msg.uid))

    } else if (msg.action === "colorupdate") {
        model.setProperty(indexOf(model, msg.uid), "color", msg.color)

    } else if (msg.action === "textupdate") {
        model.setProperty(indexOf(model, msg.uid), "text", msg.text)

    } else if (msg.action === "movetotop") {
        model.move(indexOf(model, msg.uid), 0, 1) // move 1 item to position 0

    } else if (msg.action === "update") {
        var results = msg.results
        if (model.count > results.length) {
            model.remove(results.length, model.count - results.length)
        }
        for (i = 0; i < results.length; i++) {
            var result = results[i]
            if (i < model.count) {
                model.set(i, {
                              "uid": result.uid,
                              "text": result.text,
                              "color": result.color
                          })
            } else {
                model.append({
                                 "uid": result.uid,
                                 "text": result.text,
                                 "color": result.color
                             })
            }
        }
    }

    model.sync()
    WorkerScript.sendMessage({"reply": msg.action})
}
