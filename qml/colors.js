// Copyright (C) 2012-2013 Jolla Ltd.
// Contact: Richard Braakman <richard.braakman@jollamobile.com>

function set_alpha(color, a) {
    // Unfortunately Qt4 doesn't have any way to access the components
    // of a color directly, so we have to operate on the string form.
    var color_str = "" + color
    var alpha = Math.floor(a * 255 + 0.5).toString(16)
    if (alpha.length == 1)
        alpha = "0" + alpha
    if (color_str.length == 7) { // RGB
        return '#' + alpha + color_str.substr(1)
    } else if (color_str.length == 9) { // ARGB
        return '#' + alpha + color_str.substr(3)
    } else {
        console.log("set_alpha received odd color: " + color_str);
    }
}
