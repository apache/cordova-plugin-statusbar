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
declare class StatusBar {
	/** Flag for whether or not the statusbar is visible */
    static isVisible:Boolean;
    /** On iOS 7, make the statusbar overlay or not overlay the WebView */
    static overlaysWebView(doOverlay:Boolean):void;
    /** Use the default statusbar (dark text, for light backgrounds) */
    static styleDefault():void;
    /** Use the lightContent statusbar (light text, for dark backgrounds) */
    static styleLightContent():void;
    /** Use the blackTranslucent statusbar (light text, for dark backgrounds) */
    static styleBlackTranslucent():void;
    /** Use the blackOpaque statusbar (light text, for dark backgrounds) */
    static styleBlackOpaque():void;
    /** On iOS 7, when you set StatusBar.statusBarOverlaysWebView to false, 
        you can set the background color of the statusbar by color name */
    static backgroundColorByName(name:String):void;
    /** Sets the background color of the statusbar by a hex string */
    static backgroundColorByHexString(hex:String):void;
    /** Hide the statusbar */
    static hide():void;
    /** Show the statusbar */
    static show():void;
}