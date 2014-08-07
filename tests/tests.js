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

exports.defineManualTests = function (contentEl, createActionButton) {
    function log(msg) {
        var el = document.getElementById("info");
        var logLine = document.createElement('div');
        logLine.innerHTML = msg;
        el.appendChild(logLine);
    }

    function doShow() {
        StatusBar.show();
        log('StatusBar.isVisible=' + StatusBar.isVisible);
    }

    function doHide() {
        StatusBar.hide();
        log('StatusBar.isVisible=' + StatusBar.isVisible);
    }

    function doColor1() {
        log('set color=red');
        StatusBar.backgroundColorByName('red');
    }

    function doColor2() {
        log('set style=translucent black');
        StatusBar.styleBlackTranslucent();
    }

    function doColor3() {
        log('set style=default');
        StatusBar.styleDefault();
    }

    var showOverlay = true;
    function doOverlay() {
        showOverlay = !showOverlay;
        StatusBar.overlaysWebView(showOverlay);
        log('Set overlay=' + showOverlay);
    }

    /******************************************************************************/

    contentEl.innerHTML = '<div id="info"></div>' +
        'Also: tapping bar on iOS should emit a log.' +
        '<div id="action-show"></div>' +
        '<div id="action-hide"></div>' +
        '<div id="action-color1"></div>' +
        '<div id="action-color2"></div>' +
        '<div id="action-color3"></div>' +
        '<div id="action-overlays"></div>';

    log('StatusBar.isVisible=' + StatusBar.isVisible);
    window.addEventListener('statusTap', function () {
        log('tap!');
    }, false);

    createActionButton("Show", function () {
        doShow();
    }, 'action-show');

    createActionButton("Hide", function () {
        doHide();
    }, 'action-hide');

    createActionButton("Style=red", function () {
        doColor1();
    }, 'action-color1');

    createActionButton("Style=translucent black", function () {
        doColor2();
    }, 'action-color2');

    createActionButton("Style=default", function () {
        doColor3();
    }, 'action-color3');

    createActionButton("Toggle Overlays", function () {
        doOverlay();
    }, 'action-overlays');
};
