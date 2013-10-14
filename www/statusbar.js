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

var argscheck = require('cordova/argscheck'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec');

// prime it
exec(null, null, "StatusBar", "_ready", []);

var StatusBar = function() {
};

StatusBar.overlaysWebView = function(doOverlay) {
    exec(null, null, "StatusBar", "overlaysWebView", [doOverlay]);
};

StatusBar.styleDefault = function() {
    exec(null, null, "StatusBar", "styleDefault", []);
};

StatusBar.styleLightContent = function() {
    exec(null, null, "StatusBar", "styleLightContent", []);
};

StatusBar.styleBlackTranslucent = function() {
    exec(null, null, "StatusBar", "styleBlackTranslucent", []);
};

StatusBar.styleBlackOpaque = function() {
    exec(null, null, "StatusBar", "styleBlackOpaque", []);
};

StatusBar.backgroundColorByName = function(colorname) {
    exec(null, null, "StatusBar", "backgroundColorByName", [colorname]);
}

StatusBar.backgroundColorByHexString = function(hexString) {
    exec(null, null, "StatusBar", "backgroundColorByHexString", [hexString]);
}

StatusBar.hide = function() {
    exec(null, null, "StatusBar", "hide", []);
}

StatusBar.show = function() {
    exec(null, null, "StatusBar", "show", []);
}

StatusBar.isVisible = true;

module.exports = StatusBar;
