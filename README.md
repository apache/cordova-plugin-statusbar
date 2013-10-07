StatusBar
======

> The `StatusBar` object provides some functions to customize the iOS StatusBar.

The plugin reads the __StatusBarOverlaysWebView__ (boolean, defaults to true) and __StatusBarBackgroundColor__ (color hex string, defaults to #000000) values from config.xml.

For iOS 7, to use the statusbar style functions, you need the addition of a key in your Info.plist. See the Permissions section below.
 
Methods
-------

- StatusBar.statusBarOverlaysWebView
- StatusBar.styleDefault
- StatusBar.styleLightContent
- StatusBar.styleBlackTranslucent
- StatusBar.styleBlackOpaque
- StatusBar.statusBarBackgroundColorByName
- StatusBar.statusBarBackgroundColorByHexString

Properties
--------

- StatusBar.isVisible (TODO: not implemented yet)

Permissions
-----------

#### config.xml

            <feature name="StatusBar">
                <param name="ios-package" value="CDVStatusBar" onload="true" />
            </feature>

#### [ProjectName]-Info.plist

            <key>UIViewControllerBasedStatusBarAppearance</key>
            <false/>

StatusBar.statusBarOverlaysWebView
=================

On iOS 7, make the statusbar overlay or not overlay the WebView.

    StatusBar.statusBarOverlaysWebView(true);

Description
-----------

On iOS 7, set to false to make the statusbar appear like iOS 6. Set the style and background color to suit using the other functions.


Supported Platforms
-------------------

- iOS

Quick Example
-------------

    StatusBar.statusBarOverlaysWebView(true);
    StatusBar.statusBarOverlaysWebView(false);

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


StatusBar.statusBarBackgroundColorByName
=================

On iOS 7, when you set StatusBar.statusBarOverlaysWebView to false, you can set the background color of the statusbar by color name.

    StatusBar.statusBarBackgroundColorByName("red");

Supported color names are:

    black, darkGray, lightGray, white, gray, red, green, blue, cyan, yellow, magenta, orange, purple, brown, clear


Supported Platforms
-------------------

- iOS

StatusBar.statusBarBackgroundColorByHexString
=================

On iOS 7, when you set StatusBar.statusBarOverlaysWebView to false, you can set the background color of the statusbar by a hex string (#RRGGBB).

    StatusBar.statusBarBackgroundColorByHexString("#C0C0C0");


Supported Platforms
-------------------

- iOS



    