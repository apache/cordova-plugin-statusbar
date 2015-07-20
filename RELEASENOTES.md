<!--
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#  KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
-->
# Release Notes

### 0.1.5 (Apr 17, 2014) (First release as a core Cordova Plugin)
* CB-6316: Added README.md which point to the new location for docs
* CB-6316: Added license header to the documentation. Added README.md which point to the new location for docs
* CB-6316: Moved StatusBar plugin documentation to docs folder
* CB-6314: [android] Add StatusBar.isVisible support to Android
* CB-6460: Update license headers

### 0.1.6 (Jun 05, 2014)
* CB-6783 - added StatusBarStyle config preference,  updated docs (closes #9)
* CB-6812 Add license
* CB-6491 add CONTRIBUTING.md
* CB-6264 minor formatting issue
* Update docs with recent WP changes, remove 'clear' from the loist of named colors in documentation
* CB-6513 - Statusbar plugin for Android is not compiling

### 0.1.7 (Aug 06, 2014)
* Add LICENSE and NOTICE
* Update statusbar.js
* Update backgroundColorByHexString function
* ios: Use a persistent callbackId instead of calling sendJs
* CB-6626 ios: Add a JS event for tapping on statusbar
* ios: Fix hide to adjust webview's frame only when status bar is not overlaying webview
* CB-6127 Updated translations for docs
* android: Fix StatusBar.initialize() not running on UI thread

### 0.1.8 (Sep 17, 2014)
* CB-7549 [StatusBar][iOS 8] Landscape issue
* CB-7486 Remove StatusBarBackgroundColor intial preference (black background) so background will be initially transparent
* Renamed test dir, added nested plugin.xml
* added documentation for manual tests, moved background color test below overlay test
* CB-7195 ported statusbar tests to framework

### 0.1.9 (Dec 02, 2014)
* Fix onload attribute within <feature> to be a <param>
* CB-8010 - Statusbar colour does not change to orange
* added checks for running on windows when StatusBar is NOT available
* CB-7986 Add cordova-plugin-statusbar support for **Windows Phone 8.1**
* CB-7977 Mention `deviceready` in plugin docs
* CB-7979 Each plugin doc should have a ## Installation section
* Inserting leading space after # for consistency
* CB-7549 - (Re-fix) `StatusBar` **iOS 8** Landscape issue (closes #15)
* CB-7700 cordova-plugin-statusbar documentation translation: cordova-plugin-statusbar
* CB-7571 Bump version of nested plugin to match parent plugin

### 0.1.10 (Feb 04, 2015)
* CB-8351 ios: Use argumentForIndex rather than NSArray extension

### 1.0.0 (Apr 15, 2015)
* CB-8746 gave plugin major version bump
* CB-8683 changed plugin-id to pacakge-name
* CB-8653 properly updated translated docs to use new id
* CB-8653 updated translated docs to use new id
* Use TRAVIS_BUILD_DIR, install paramedic by npm
* CB-8653 Updated Readme
* - Use StatusBarBackgroundColor instead of AndroidStatusBarBackgroundColor, and added a quirk to the readme.
* - Add support for StatusBar.backgroundColorByHexString (and StatusBar.backgroundColorByName) on Android 5 and up
* Allow setting the statusbar backgroundcolor on Android
* CB-8575 Integrate TravisCI
* CB-8438 cordova-plugin-statusbar documentation translation: cordova-plugin-statusbar
* CB-8538 Added package.json file

### 1.0.1 (Jun 17, 2015)
* add auto-tests for basic api
* CB-9180 Add correct supported check for Windows 8.1 desktop
* CB-9128 cordova-plugin-statusbar documentation translation: cordova-plugin-statusbar
* fix npm md issue
