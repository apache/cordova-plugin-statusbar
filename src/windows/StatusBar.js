/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */
var statusBar = Windows.UI.ViewManagement.StatusBar.getForCurrentView();

function darkForeground () {
    // dark text ( to be used on a light background )
    statusBar.foregroundColor = { a: 0, r: 0, g: 0, b: 0 };
}

function lightForeground() {
    // light text ( to be used on a dark background )
    statusBar.foregroundColor = { a: 0, r: 255, g: 255, b: 255 };
}

function hexToRgb(hex) {
    // Expand shorthand form (e.g. "03F") to full form (e.g. "0033FF")
    var shorthandRegex = /^#?([a-f\d])([a-f\d])([a-f\d])$/i;
    hex = hex.replace(shorthandRegex, function (m, r, g, b) {
        return r + r + g + g + b + b;
    });

    var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
    } : null;
}

var StatusBar = {
    _ready: function(win, fail) {
        win(statusBar.occludedRect.height !== 0);
    },

    overlaysWebView: function () {
        // not supported
    },

    styleDefault: function () {
        darkForeground();
    },

    styleLightContent: function () {
        lightForeground();
    },

    styleBlackTranslucent: function () {
        // #88000000 ? Apple says to use lightContent instead
        lightForeground();
    },

    styleBlackOpaque: function () {
        // #FF000000 ? Apple says to use lightContent instead
        lightForeground();
    },

    backgroundColorByHexString: function (win, fail, args) {
        var rgb = hexToRgb(args[0]);
        statusBar.backgroundColor = { a: 0, r: rgb.r, g: rgb.g, b: rgb.b };
        statusBar.backgroundOpacity = 1;
    },

    show: function (win, fail) {
        statusBar.showAsync().done(win, fail);
    },

    hide: function (win, fail) {
        statusBar.hideAsync().done(win, fail);
    }
};

require("cordova/exec/proxy").add("StatusBar", StatusBar);
