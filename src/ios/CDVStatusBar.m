/*
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
 */

/* 
 NOTE: plugman/cordova cli should have already installed this,
 but you need the value UIViewControllerBasedStatusBarAppearance
 in your Info.plist as well to set the styles in iOS 7
 */

#import "CDVStatusBar.h"

@implementation CDVStatusBar

- (id)settingForKey:(NSString*)key
{
    return [self.commandDelegate.settings objectForKey:[key lowercaseString]];
}

- (void) checkInfoPlistKey
{
    NSNumber* uiviewControllerBasedStatusBarAppearance = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIViewControllerBasedStatusBarAppearance"];
    if (uiviewControllerBasedStatusBarAppearance == nil || [uiviewControllerBasedStatusBarAppearance boolValue]) {
        NSLog(@"ERROR: To use the statusbar plugin, in your app's Info.plist, you need to add a 'UIViewControllerBasedStatusBarAppearance' key with a value of <false/>");
    }
}

- (void)pluginInitialize
{
    _statusBarOverlaysWebView = YES; // default
    
    CGRect frame = [[UIApplication sharedApplication] statusBarFrame];
    
    _statusBarBackgroundView = [[UIView alloc] initWithFrame:frame];
    _statusBarBackgroundView.backgroundColor = [UIColor blackColor];
    [self styleLightContent:nil]; // match default backgroundColor of #000000
    
    NSString* setting;
    
    setting  = @"StatusBarOverlaysWebView";
    if ([self settingForKey:setting]) {
        self.statusBarOverlaysWebView = [(NSNumber*)[self settingForKey:setting] boolValue];
    }

    setting  = @"StatusBarBackgroundColor";
    if ([self settingForKey:setting]) {
        [self _statusBarBackgroundColorByHexString:[self settingForKey:setting]];
    }
}

- (void) setStatusBarOverlaysWebView:(BOOL)statusBarOverlaysWebView
{
    // we only care about the latest iOS version or a change in setting
    if (!IsAtLeastiOSVersion(@"7.0") || statusBarOverlaysWebView == _statusBarOverlaysWebView) {
        return;
    }
    
    if (statusBarOverlaysWebView) {
        
        CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
        CGRect bounds = self.viewController.view.bounds;
        bounds.origin.y = 0;
        bounds.size.height += statusBarFrame.size.height;
        
        self.webView.frame = bounds;
        
        [_statusBarBackgroundView removeFromSuperview];

    } else {
        CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
        CGRect bounds = self.viewController.view.bounds;
        bounds.origin.y += statusBarFrame.size.height;
        bounds.size.height -= statusBarFrame.size.height;
        
        self.webView.frame = bounds;
        [self.webView.superview addSubview:_statusBarBackgroundView];
    }
    
    _statusBarOverlaysWebView = statusBarOverlaysWebView;
}

- (BOOL) statusBarOverlaysWebView
{
    return _statusBarOverlaysWebView;
}

- (void) statusBarOverlaysWebView:(CDVInvokedUrlCommand*)command
{
    id value = [command.arguments objectAtIndex:0];
    if (!([value isKindOfClass:[NSNumber class]])) {
        value = [NSNumber numberWithBool:YES];
    }
    
    self.statusBarOverlaysWebView = [value boolValue];
}

- (void) setStatusBarStyle:(NSString*)statusBarStyle
{
    // default, lightContent, blackTranslucent, blackOpaque
    NSString* lcStatusBarStyle = [statusBarStyle lowercaseString];
    
    if ([lcStatusBarStyle isEqualToString:@"default"]) {
        [self styleDefault:nil];
    } else if ([lcStatusBarStyle isEqualToString:@"lightcontent"]) {
        [self styleLightContent:nil];
    } else if ([lcStatusBarStyle isEqualToString:@"blacktranslucent"]) {
        [self styleBlackTranslucent:nil];
    } else if ([lcStatusBarStyle isEqualToString:@"blackopaque"]) {
        [self styleBlackOpaque:nil];
    }
}

- (void) styleDefault:(CDVInvokedUrlCommand*)command
{
    [self checkInfoPlistKey];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void) styleLightContent:(CDVInvokedUrlCommand*)command
{
    [self checkInfoPlistKey];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void) styleBlackTranslucent:(CDVInvokedUrlCommand*)command
{
    [self checkInfoPlistKey];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
}

- (void) styleBlackOpaque:(CDVInvokedUrlCommand*)command
{
    [self checkInfoPlistKey];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
}

- (void) statusBarBackgroundColorByName:(CDVInvokedUrlCommand*)command
{
    id value = [command.arguments objectAtIndex:0];
    if (!([value isKindOfClass:[NSString class]])) {
        value = @"black";
    }
    
    SEL selector = NSSelectorFromString([value stringByAppendingString:@"Color"]);
    if ([UIColor respondsToSelector:selector]) {
        _statusBarBackgroundView.backgroundColor = [UIColor performSelector:selector];
    }
}

- (void) _statusBarBackgroundColorByHexString:(NSString*)hexString
{
    unsigned int rgbValue = 0;
    NSScanner* scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];
    
    _statusBarBackgroundView.backgroundColor = [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (void) statusBarBackgroundColorByHexString:(CDVInvokedUrlCommand*)command
{
    NSString* value = [command.arguments objectAtIndex:0];
    if (!([value isKindOfClass:[NSString class]])) {
        value = @"#000000";
    }
    
    if (![value hasPrefix:@"#"] || [value length] < 7) {
        return;
    }
    
    [self _statusBarBackgroundColorByHexString:value];
}


@end
