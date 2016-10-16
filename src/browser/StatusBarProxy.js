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

var appropriateMetaTagName = null;

var MetaTagName = {
    IOS_SAFARI: 'apple-mobile-web-app-status-bar-style',
    WINDOWS_PHONE: 'msapplication-navbutton-color',
    DEFAULT: 'theme-color'
};

function isSupported() {
    if (_supported === null) {
        if (getAppropriateMetaTagName()) {
            _supported = true;
        } else {
            _supported = false;
        }
    }

    return _supported;
}

function findMetaTag(tagName) {
    var metaTags = document.head.getElementsByTagName('meta');
    if(metaTags) {
        for (var i = 0; i < metaTags.length; i++) {
            if (metaTags[i].name === tagName) {
                return metaTags[i];
            }
        }
    } else {
        return false;
    }
}

function getStatusBar() {
    if (!isSupported()) {
        throw new Error("Status bar is not supported");
    }

    statusBarThemeMetaTag = findMetaTag(getAppropriateMetaTagName());

    if(!statusBarThemeMetaTag) {
        statusBarThemeMetaTag = document.createElement('meta');
        statusBarThemeMetaTag.name = getAppropriateMetaTagName();

        if (getAppropriateMetaTagName() === MetaTagName.IOS_SAFARI) {
            /*
             * The meta tag has no effect on iOS Safari unless you first specify full-screen mode as described in apple-apple-mobile-web-app-capable.
             * If the apple-apple-mobile-web-app-capable isn't in place already, we'll add it here.
             */
            if (!findMetaTag('apple-mobile-web-app-capable')) {
                var iOSwebAppMetaTag = document.createElement('meta');
                iOSwebAppMetaTag.name = 'apple-mobile-web-app-capable';
                iOSwebAppMetaTag.content = 'yes';

                document.head.appendChild(iOSwebAppMetaTag);
            }
        }

        document.head.appendChild(statusBarThemeMetaTag);
    }
}

function getAppropriateMetaTagName() {
    if (appropriateMetaTagName === null) {
        // TODO: Make userAgent identification more robust
        if(navigator.userAgent.indexOf('iPhone' > -1) && navigator.userAgent.indexOf('Chrome' === -1)) {
            // iOS Safari
            appropriateMetaTagName = MetaTagName.IOS_SAFARI;
        } if (navigator.userAgent.indexOf('IEMobile') > -1) {
            // Windows Phone
            appropriateMetaTagName = MetaTagName.WINDOWS_PHONE;
        } else {
            // Chrome, Firefox OS, Opera and Vivaldi
            appropriateMetaTagName = MetaTagName.DEFAULT;
        }
    }

    return appropriateMetaTagName;    
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
        var overlay = false;

        if (getAppropriateMetaTagName() === MetaTagName.IOS_SAFARI &&
            statusBarThemeMetaTag.content === 'black-translucent') {
            overlay = true;
        }        

        return overlay;
    },

    styleDefault: function () {
        // dark text ( to be used on a light background )
        if (isSupported()) {
            if (getAppropriateMetaTagName() === MetaTagName.IOS_SAFARI) {
                setStatusBarColor('default');
            } else {
                setStatusBarColor('');
            }
        }
    },

    styleLightContent: function () {
        // light text ( to be used on a dark background )
        if (isSupported()) {
            if (getAppropriateMetaTagName() === MetaTagName.IOS_SAFARI) {
                setStatusBarColor('black');
            } else {
                setStatusBarColor(BRIGHTEST_SUPPORTED_COLOR);
            }
        }
    },

    styleBlackTranslucent: function () {
        if (getAppropriateMetaTagName() === MetaTagName.IOS_SAFARI) {
            return setStatusBarColor('black-translucent');
        } else {
            return module.exports.styleLightContent();
        }
    },

    styleBlackOpaque: function () {
        return module.exports.styleLightContent();
    },

    backgroundColorByHexString: function (win, fail, args) {
        var hex = args[0];
        if(isSupported()) {
            setStatusBarColor(hex);
        }
    },

    isVisible: true,

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
