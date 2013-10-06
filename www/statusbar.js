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

var StatusBar = function() {
};

StatusBar.statusBarOverlaysWebView = function(doOverlay) {
    exec(null, null, "StatusBar", "statusBarOverlaysWebView", [doOverlay]);
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

StatusBar.statusBarBackgroundColorByName = function(colorname) {
    exec(null, null, "StatusBar", "statusBarBackgroundColorByName", [colorname]);
}

StatusBar.statusBarBackgroundColorByHexString = function(hexString) {
    exec(null, null, "StatusBar", "statusBarBackgroundColorByHexString", [hexString]);
}

// TODO:
StatusBar.isVisible = true;

module.exports = StatusBar;
