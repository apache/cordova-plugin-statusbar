---
# cordova-docs build metadata
title: Statusbar
description: Control the device status bar.
---
<!---
# license: Licensed to the Apache Software Foundation (ASF) under one
#         or more contributor license agreements.  See the NOTICE file
#         distributed with this work for additional information
#         regarding copyright ownership.  The ASF licenses this file
#         to you under the Apache License, Version 2.0 (the
#         "License"); you may not use this file except in compliance
#         with the License.  You may obtain a copy of the License at
#
#           http://www.apache.org/licenses/LICENSE-2.0
#
#         Unless required by applicable law or agreed to in writing,
#         software distributed under the License is distributed on an
#         "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#         KIND, either express or implied.  See the License for the
#         specific language governing permissions and limitations
#         under the License.
-->

# cordova-plugin-statusbar

[![npm - Latest](https://img.shields.io/npm/v/cordova-plugin-statusbar/latest?label=Latest%20Release%20(npm))](https://npmjs.com/package/cordova-plugin-statusbar)
[![GitHub](https://img.shields.io/github/package-json/v/apache/cordova-plugin-statusbar?label=Development%20(Git))](https://github.com/apache/cordova-plugin-statusbar)

[![GitHub - Node Workflow](https://github.com/apache/cordova-plugin-statusbar/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/apache/cordova-plugin-statusbar/actions/workflows/ci.yml?query=branch%3Amaster)
[![Android Testsuite](https://github.com/apache/cordova-plugin-statusbar/actions/workflows/android.yml/badge.svg)](https://github.com/apache/cordova-plugin-statusbar/actions/workflows/android.yml)
[![Chrome Testsuite](https://github.com/apache/cordova-plugin-statusbar/actions/workflows/chrome.yml/badge.svg)](https://github.com/apache/cordova-plugin-statusbar/actions/workflows/chrome.yml)
[![iOS Testsuite](https://github.com/apache/cordova-plugin-statusbar/actions/workflows/ios.yml/badge.svg)](https://github.com/apache/cordova-plugin-statusbar/actions/workflows/ios.yml)
[![Lint Test](https://github.com/apache/cordova-plugin-statusbar/actions/workflows/lint.yml/badge.svg)](https://github.com/apache/cordova-plugin-statusbar/actions/workflows/lint.yml)
[![GitHub - Release Audit Workflow](https://github.com/apache/cordova-plugin-statusbar/actions/workflows/release-audit.yml/badge.svg?branch=master)](https://github.com/apache/cordova-plugin-statusbar/actions/workflows/release-audit.yml?query=branch%3Amaster)

> [!WARNING]
> This plugin is deprecated. Use the status bar functionality built into the Cordova platform cores instead. See [Deprecation and migration](#deprecation-and-migration) for replacements and remaining differences.

## Deprecation and migration

Basic status bar functionality is built into [cordova-android 15.0.0](https://cordova.apache.org/announcements/2026/03/06/cordova-android-15.0.0.html) and [cordova-ios 8.0.0](https://cordova.apache.org/announcements/2025/11/23/cordova-ios-8.0.0.html) and later. The cores provide the JavaScript API `window.statusbar` in place of this plugin's [StatusBar](#methods) object. Status bar development will continue in the platform cores.

The comparison below describes [cordova-android 15.1.0](https://cordova.apache.org/announcements/2026/07/22/cordova-android-15.1.0.html) and [cordova-ios 8.1.1](https://cordova.apache.org/announcements/2026/07/07/cordova-ios-8.1.1.html). The core functionality is not a direct replacement for every plugin feature.

- [Light or dark text and icons](#light-or-dark-text-and-icons)
- [Show, hide, visibility](#show-hide-visibility)
- [Background color](#background-color)
- [Overlay the WebView or reserve space for the bar](#overlay-the-webview-or-reserve-space-for-the-bar)
- [Status bar tap and scroll-to-top configuration](#status-bar-tap-and-scroll-to-top-configuration)
- [Migrating an app](#migrating-an-app)

### Light or dark text and icons

#### Plugin

- config.xml preference [StatusBarStyle](#configxml)
- JS API [StatusBar.styleDefault()](#statusbarstyledefault) and [StatusBar.styleLightContent()](#statusbarstylelightcontent).

#### cordova-android

- Appearance is determined by the background color.
- Since cordova-android 15.1.0, this also applies when using the JS API `window.statusbar.setBackgroundColor(cssColor)` in edge-to-edge mode.

#### cordova-ios

- iOS 18.5 and later automatically choose the appearance based on the background color.
- [cordova-ios PR #1689](https://github.com/apache/cordova-ios/pull/1689) adds automatic light/dark appearance based on background luminance on iOS older than 18.5. It is merged but is not included in 8.1.1.

### Show, hide, visibility

#### Plugin

- JS API [StatusBar.show()](#statusbarshow) and [StatusBar.hide()](#statusbarhide).
- JS API [StatusBar.isVisible](#statusbarisvisible)

#### cordova-android

- JS API `window.statusbar.visible`, which can be set to `true` or `false` and read for the visibility.
- In cordova-android 15.1.0, hiding does not fully hide the system status bar. [cordova-android PR #2000](https://github.com/apache/cordova-android/pull/2000) fixes complete hiding of the system status bar. It is merged but is not included in 15.1.0.

#### cordova-ios

- JS API `window.statusbar.visible`, which can be set to `true` or `false` and read for the visibility.

### Background color

#### Plugin

- config.xml preference [StatusBarBackgroundColor](#configxml)
- JS API [StatusBar.backgroundColorByName()](#statusbarbackgroundcolorbyname) and [StatusBar.backgroundColorByHexString()](#statusbarbackgroundcolorbyhexstring).

#### cordova-android

- config.xml preference `StatusBarBackgroundColor`
- JS API `window.statusbar.setBackgroundColor(cssColor)`. Since 15.1.0, the JavaScript method also controls the dark/light appearance in edge-to-edge mode, without painting a background. In edge-to-edge mode, you can style the content behind the transparent status bar in CSS.

#### cordova-ios

- index.html `<meta name="theme-color" content="#ffffff">`, which can also be updated at runtime
- JS API `window.statusbar.setBackgroundColor(cssColor)`
- config.xml preference `StatusBarBackgroundColor`.
- You can style the content behind the status bar in CSS when using `viewport-fit=cover`.

#### Note

The JS API `window.statusbar.setBackgroundColor(cssColor)` works with [CSS colors](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Values/color_value), which can be for e.g. `rebeccapurple`, `#RRGGBBAA`, `rgb(255 0 153)`.

### Overlay the WebView or reserve space for the bar

#### Plugin

- config.xml preference [StatusBarOverlaysWebView](#configxml)
- Android: JS API [StatusBar.overlaysWebView()](#statusbaroverlayswebview)
- iOS: `viewport-fit=contain` or `viewport-fit=cover`.

#### cordova-android

- config.xml preference `AndroidEdgeToEdge`, which is not a complete replacement for it. `<preference name="StatusBarOverlaysWebView" value="true">` cannot be adapted. The config.xml preference `StatusBarOverlaysWebView` is not supported. [cordova-android PR #2010](https://github.com/apache/cordova-android/pull/2010) proposes viewport-based layout handling which would support `viewport-fit=contain` or `viewport-fit=cover` like on iOS. It is still work in progress and is not available in 15.1.0.

#### cordova-ios

Use `viewport-fit=cover` in the viewport meta tag to draw beneath the status bar. Omit it or use `viewport-fit=auto` for automatic safe-area insets. This controls layout, not whether the system status bar is visible.

### Status bar tap and scroll-to-top configuration

#### Plugin

- iOS only: config.xml preference `StatusBarDefaultScrollToTop` and JS event [statusTap](#statustap).

#### cordova-ios

No direct core replacement exists for the plugin's event or preference. Apps relying on custom tap handling need another implementation. This feature does not apply to Android.

### Migrating an app

Update to a platform version that supports the features your app needs, replace the plugin calls and preferences using the sections above, then remove the plugin:

```sh
cordova plugin remove cordova-plugin-statusbar
```

Use the core JavaScript API after `deviceready`. Both cores can forward calls to the old plugin while it is installed, so verify the replacement behavior after removing it. The core color method accepts CSS colors; eight-digit hexadecimal JavaScript values use `#RRGGBBAA`, unlike the old plugin's Android `#AARRGGBB` format. CSS alpha handling is fixed in Android 15.1.0 and supported in iOS 8.1.1.

When drawing beneath the status bar on iOS, use CSS safe-area insets such as `env(safe-area-inset-top)` to keep interactive content clear of it.

The documentation below describes the deprecated plugin API for existing users.

> The `StatusBar` object provides some functions to customize the iOS and Android StatusBar.

## Installation

This installation method requires cordova 5.0+

    cordova plugin add cordova-plugin-statusbar

It is also possible to install via repo url directly ( unstable )

    cordova plugin add https://github.com/apache/cordova-plugin-statusbar.git


Preferences
-----------

#### config.xml

-  __StatusBarOverlaysWebView__ (boolean, defaults to true). Make the statusbar overlay or not overlay the WebView at startup.

        <preference name="StatusBarOverlaysWebView" value="true" />

    ##### iOS Specifics

    The status bar will be transparent if `StatusBarOverlaysWebView` is set to `true`. A background color cannot be applied.

    ##### Android Quirks
    
    Only supported on Android 5 or later. Earlier versions will ignore this preference.

- __StatusBarBackgroundColor__ (color hex string, no default value). Set the background color of the statusbar by a hex string (#RRGGBB) at startup. If this value is not set, the background color will be transparent.

        <preference name="StatusBarBackgroundColor" value="#000000" />

    #### Android Specifics

    If `StatusBarOverlaysWebView` is set to true, then a 8 digit hex (#AARRGGBB) string can optionally be used to define the transparency.

- __StatusBarStyle__ (status bar style, defaults to lightcontent). Set the status bar style (e.g. text color). Available options: `default`, `lightcontent`.

        <preference name="StatusBarStyle" value="lightcontent" />

- __StatusBarDefaultScrollToTop__ (boolean, defaults to false). On iOS, allows the Cordova WebView to use default scroll-to-top behavior. Defaults to false so you can listen to the "statusTap" event (described below) and customize the behavior instead.

        <preference name="StatusBarDefaultScrollToTop" value="false" />

### Android Quirks
The Android 5+ guidelines specify using a different color for the statusbar than your main app color (unlike the uniform statusbar color of many iOS apps), so you may want to set the statusbar color at runtime instead via `StatusBar.backgroundColorByHexString` or `StatusBar.backgroundColorByName`. One way to do that would be:
```js
if (cordova.platformId == 'android') {
    StatusBar.backgroundColorByHexString("#333");
}
```

It is also possible to make the status bar semi-transparent. Android uses hexadecimal ARGB values, which are formatted as #AARRGGBB. That first pair of letters, the AA, represent the alpha channel. You must convert your decimal opacity values to a hexadecimal value. You can read more about it [here](https://stackoverflow.com/questions/5445085/understanding-colors-on-android-six-characters/11019879#11019879).

For example, a black status bar with 20% opacity:
```js
if (cordova.platformId == 'android') {
    StatusBar.overlaysWebView(true);
    StatusBar.backgroundColorByHexString('#33000000');
}
```

### iOS Quirks
Starting with iOS 11 you must include `viewport-fit=cover` in your viewport meta tag if you want the status bar to overlay the webview:

```html
<meta name="viewport" content="initial-scale=1, width=device-width, viewport-fit=cover">
```



Hiding at startup
-----------

During runtime you can use the StatusBar.hide function below, but if you want the StatusBar to be hidden at app startup on iOS, you must modify your app's Info.plist file.

Add/edit these two attributes if not present. Set **"Status bar is initially hidden"** to **"YES"** and set **"View controller-based status bar appearance"** to **"NO"**. If you edit it manually without Xcode, the keys and values are:


	<key>UIStatusBarHidden</key>
	<true/>
	<key>UIViewControllerBasedStatusBarAppearance</key>
	<false/>


Methods
-------
This plugin defines global `StatusBar` object.

Although in the global scope, it is not available until after the `deviceready` event.

    document.addEventListener("deviceready", onDeviceReady, false);
    function onDeviceReady() {
        console.log(StatusBar);
    }

- StatusBar.overlaysWebView
- StatusBar.styleDefault
- StatusBar.styleLightContent
- StatusBar.backgroundColorByName
- StatusBar.backgroundColorByHexString
- StatusBar.hide
- StatusBar.show

Properties
--------

- StatusBar.isVisible

Events
------

- statusTap

StatusBar.overlaysWebView
=================

Make the statusbar overlay or not overlay the WebView.

    StatusBar.overlaysWebView(true);

Description
-----------

Set to true to make the statusbar overlay on top of your app. Ensure that you adjust your styling accordingly so that your app's title bar or content is not covered. Set to false to make the statusbar solid and not overlay your app. You can then set the style and background color to suit using the other functions.


Supported Platforms
-------------------

- iOS
- Android 5+

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
- Android 6+

StatusBar.styleLightContent
=================

Use the lightContent statusbar (light text, for dark backgrounds).

    StatusBar.styleLightContent();


Supported Platforms
-------------------

- iOS
- Android 6+

StatusBar.backgroundColorByName
=================

On iOS, when you set StatusBar.overlaysWebView to false, you can set the background color of the statusbar by color name.

    StatusBar.backgroundColorByName("red");

Supported color names are:

    black, darkGray, lightGray, white, gray, red, green, blue, cyan, yellow, magenta, orange, purple, brown


Supported Platforms
-------------------

- iOS
- Android

StatusBar.backgroundColorByHexString
=================

Sets the background color of the statusbar by a hex string.

    StatusBar.backgroundColorByHexString("#C0C0C0");

CSS shorthand properties are also supported.

    StatusBar.backgroundColorByHexString("#333"); // => #333333
    StatusBar.backgroundColorByHexString("#FAB"); // => #FFAABB

On iOS you can set the background color of the statusbar by a hex string (#RRGGBB) if StatusBar.overlaysWebView is false.

On Android, when StatusBar.overlaysWebView is true you can also specify values as #AARRGGBB, where AA is an alpha value.

Supported Platforms
-------------------

- iOS
- Android

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

statusTap
=========

Listen for this event to know if the statusbar was tapped.

    window.addEventListener('statusTap', function() {
        // scroll-up with document.body.scrollTop = 0; or do whatever you want
    });


Supported Platforms
-------------------

- iOS
