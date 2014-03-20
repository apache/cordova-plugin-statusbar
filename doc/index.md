<!---
    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.
-->
#org.apache.cordova.statusbar

StatusBar
======

> The `StatusBar` object provides some functions to customize the iOS and Android StatusBar.


Preferences
-----------

#### config.xml

-  __StatusBarOverlaysWebView__ (boolean, defaults to true). On iOS 7, make the statusbar overlay or not overlay the WebView at startup.

        <preference name="StatusBarOverlaysWebView" value="true" />
            
- __StatusBarBackgroundColor__ (color hex string, defaults to #000000). On iOS 7, set the background color of the statusbar by a hex string (#RRGGBB) at startup.

        <preference name="StatusBarBackgroundColor" value="#000000" />

Hiding at startup
-----------

During runtime you can use the StatusBar.hide function below, but if you want the StatusBar to be hidden at app startup, you must modify your app's Info.plist file.

Add/edit these two attributes if not present. Set **"Status bar is initially hidden"** to **"YES"** and set **"View controller-based status bar appearance"** to **"NO"**. If you edit it manually without Xcode, the keys and values are:


	<key>UIStatusBarHidden</key>
	<true/>
	<key>UIViewControllerBasedStatusBarAppearance</key>
	<false/>

 
Methods
-------

- StatusBar.overlaysWebView
- StatusBar.styleDefault
- StatusBar.styleLightContent
- StatusBar.styleBlackTranslucent
- StatusBar.styleBlackOpaque
- StatusBar.backgroundColorByName
- StatusBar.backgroundColorByHexString
- StatusBar.hide
- StatusBar.show

Properties
--------

- StatusBar.isVisible

Permissions
-----------

#### config.xml

            <feature name="StatusBar">
                <param name="ios-package" value="CDVStatusBar" onload="true" />
            </feature>

StatusBar.overlaysWebView
=================

On iOS 7, make the statusbar overlay or not overlay the WebView.

    StatusBar.overlaysWebView(true);

Description
-----------

On iOS 7, set to false to make the statusbar appear like iOS 6. Set the style and background color to suit using the other functions.


Supported Platforms
-------------------

- iOS

Quick Example
-------------

    StatusBar.overlaysWebView(true);
    StatusBar.overlaysWebView(false);

StatusBar.styleDefault
=================

Use the default statusbar (dark text, for light backgrounds).

    StatusBar.styleDefault();


Supported Platforms
-------------------

- iOS

StatusBar.styleLightContent
=================

Use the lightContent statusbar (light text, for dark backgrounds).

    StatusBar.styleLightContent();


Supported Platforms
-------------------

- iOS

StatusBar.styleBlackTranslucent
=================

Use the blackTranslucent statusbar (light text, for dark backgrounds).

    StatusBar.styleBlackTranslucent();


Supported Platforms
-------------------

- iOS

StatusBar.styleBlackOpaque
=================

Use the blackOpaque statusbar (light text, for dark backgrounds).

    StatusBar.styleBlackOpaque();


Supported Platforms
-------------------

- iOS


StatusBar.backgroundColorByName
=================

On iOS 7, when you set StatusBar.statusBarOverlaysWebView to false, you can set the background color of the statusbar by color name.

    StatusBar.backgroundColorByName("red");

Supported color names are:

    black, darkGray, lightGray, white, gray, red, green, blue, cyan, yellow, magenta, orange, purple, brown, clear


Supported Platforms
-------------------

- iOS

StatusBar.backgroundColorByHexString
=================

On iOS 7, when you set StatusBar.statusBarOverlaysWebView to false, you can set the background color of the statusbar by a hex string (#RRGGBB).

    StatusBar.backgroundColorByHexString("#C0C0C0");


Supported Platforms
-------------------

- iOS

StatusBar.hide
=================

Hide the statusbar.

    StatusBar.hide();


Supported Platforms
-------------------

- iOS
- Android

StatusBar.show
=================

Shows the statusbar.

    StatusBar.show();


Supported Platforms
-------------------

- iOS
- Android


StatusBar.isVisible
=================

Read this property to see if the statusbar is visible or not.

    if (StatusBar.isVisible) {
    	// do something
    }


Supported Platforms
-------------------

- iOS
- Android


    