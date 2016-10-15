/*
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

var BRIGHTEST_SUPPORTED_COLOR = '#EFEFEF';

var _supported = null; // set to null so we can check first time

var statusBarThemeMetaTag = null;

function isSupported() {
    // if not checked before, run check

    // TODO: add checks to verify on a supported browser and OS
    // if (_supported === null) {
    //     if (navigator.userAgent.indexOf('Android' > -1)) {
    //         _supported = true;
    //     } else {
    //         _supported = false;
    //     }
    // }

    _supported = true;

    return _supported;
}

function getStatusBar() {
    if (!isSupported()) {
        throw new Error("Status bar is not supported");
    }

    var metaTags = document.head.getElementsByTagName('meta');
    if (metaTags) {
        for (var i = 0; i < metaTags.length; i++) {
            if (metaTags[i].name === 'theme-color') {
                statusBarThemeMetaTag = metaTags[i];
                break;
            }
        }
    } else {
        statusBarThemeMetaTag = new HTMLMetaElement();
        statusBarThemeMetaTag.name = 'theme-color';

        document.head.appendChild(statusBarThemeMetaTag);
    }
}

function setStatusBarColor(hexColor) {
    if (statusBarThemeMetaTag) {
        statusBarThemeMetaTag.content = hexColor;
    }
}

module.exports = {
    _ready: function(win, fail) {
        if(isSupported()) {
            getStatusBar();
            win(true);
        }
    },

    overlaysWebView: function () {
        // not supported
    },

    styleDefault: function () {
        // dark text ( to be used on a light background )
        if (isSupported()) {
            setStatusBarColor('');
        }
    },

    styleLightContent: function () {
        // light text ( to be used on a dark background )
        if (isSupported()) {
            setStatusBarColor(BRIGHTEST_SUPPORTED_COLOR);
        }
    },

    styleBlackTranslucent: function () {
        // #88000000 ? Apple says to use lightContent instead
        return module.exports.styleLightContent();
    },

    styleBlackOpaque: function () {
        // #FF000000 ? Apple says to use lightContent instead
        return module.exports.styleLightContent();
    },

    backgroundColorByHexString: function (win, fail, args) {
        var hex = args[0];
        if(isSupported()) {
            setStatusBarColor(hex);
        }
    },

    show: function (win, fail) {
        // added support check so no error thrown, when calling this method
        if (isSupported()) {
            return;
        }
    },

    hide: function (win, fail) {
        // added support check so no error thrown, when calling this method
        if (isSupported()) {
            return;
        }
    }
};

require("cordova/exec/proxy").add("StatusBar", module.exports);
