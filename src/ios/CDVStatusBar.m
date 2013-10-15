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
#import <objc/runtime.h>
#import <Cordova/CDVViewController.h>

static const void *kHideStatusBar = &kHideStatusBar;
static const void *kStatusBarStyle = &kStatusBarStyle;

@interface CDVViewController (StatusBar)

@property (nonatomic, retain) id sb_hideStatusBar;
@property (nonatomic, retain) id sb_statusBarStyle;
    
@end

@implementation CDVViewController (StatusBar)

@dynamic sb_hideStatusBar;
@dynamic sb_statusBarStyle;
    
- (id)sb_hideStatusBar {
    return objc_getAssociatedObject(self, kHideStatusBar);
}
    
- (void)setSb_hideStatusBar:(id)newHideStatusBar {
    objc_setAssociatedObject(self, kHideStatusBar, newHideStatusBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)sb_statusBarStyle {
    return objc_getAssociatedObject(self, kStatusBarStyle);
}
    
- (void)setSb_statusBarStyle:(id)newStatusBarStyle {
    objc_setAssociatedObject(self, kStatusBarStyle, newStatusBarStyle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
    
- (BOOL) prefersStatusBarHidden {
    return [self.sb_hideStatusBar boolValue];
}
    
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return (UIStatusBarStyle)[self.sb_statusBarStyle intValue];
}
    
@end


@implementation CDVStatusBar

- (id)settingForKey:(NSString*)key
{
    return [self.commandDelegate.settings objectForKey:[key lowercaseString]];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if ([keyPath isEqual:@"statusBarHidden"]) {
        NSNumber* newValue = [change objectForKey:NSKeyValueChangeNewKey];
        BOOL boolValue = [newValue boolValue];

        [self.commandDelegate evalJs:[NSString stringWithFormat:@"StatusBar.isVisible = %@;", boolValue? @"false" : @"true" ]];
    }
}

- (void)pluginInitialize
{
    BOOL isiOS7 = (IsAtLeastiOSVersion(@"7.0"));
                   
    // init
    NSNumber* uiviewControllerBasedStatusBarAppearance = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIViewControllerBasedStatusBarAppearance"];
    _uiviewControllerBasedStatusBarAppearance = (uiviewControllerBasedStatusBarAppearance == nil || [uiviewControllerBasedStatusBarAppearance boolValue]) && isiOS7;
    
    // observe the statusBarHidden property
    [[UIApplication sharedApplication] addObserver:self forKeyPath:@"statusBarHidden" options:NSKeyValueObservingOptionNew context:NULL];
    
    _statusBarOverlaysWebView = YES; // default
    
    CGRect frame = [[UIApplication sharedApplication] statusBarFrame];
    
    _statusBarBackgroundView = [[UIView alloc] initWithFrame:frame];
    _statusBarBackgroundView.backgroundColor = [UIColor blackColor];
    _statusBarBackgroundView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin);
    
    [self styleLightContent:nil]; // match default backgroundColor of #000000
    
    NSString* setting;
    
    setting  = @"StatusBarOverlaysWebView";
    if ([self settingForKey:setting]) {
        self.statusBarOverlaysWebView = [(NSNumber*)[self settingForKey:setting] boolValue];
    }

    setting  = @"StatusBarBackgroundColor";
    if ([self settingForKey:setting]) {
        [self _backgroundColorByHexString:[self settingForKey:setting]];
    }
}

- (void) _ready:(CDVInvokedUrlCommand*)command
{
    // set the initial value
    [self.commandDelegate evalJs:[NSString stringWithFormat:@"StatusBar.isVisible = %@;", [UIApplication sharedApplication].statusBarHidden? @"false" : @"true" ]];
}

- (void) setStatusBarOverlaysWebView:(BOOL)statusBarOverlaysWebView
{
    // we only care about the latest iOS version or a change in setting
    if (!IsAtLeastiOSVersion(@"7.0") || statusBarOverlaysWebView == _statusBarOverlaysWebView) {
        return;
    }

    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    if (statusBarOverlaysWebView) {
        
        [_statusBarBackgroundView removeFromSuperview];
        self.webView.frame = bounds;

    } else {

        CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
        bounds.origin.y = statusBarFrame.size.height;
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

- (void) overlaysWebView:(CDVInvokedUrlCommand*)command
{
    id value = [command.arguments objectAtIndex:0];
    if (!([value isKindOfClass:[NSNumber class]])) {
        value = [NSNumber numberWithBool:YES];
    }
    
    self.statusBarOverlaysWebView = [value boolValue];
}

- (void) refreshStatusBarAppearance
{
    SEL sel = NSSelectorFromString(@"setNeedsStatusBarAppearanceUpdate");
    if ([self.viewController respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.viewController performSelector:sel withObject:nil];
#pragma clang diagnostic pop
    }
}
    
- (void) setStyleForStatusBar:(UIStatusBarStyle)style
{
    if (_uiviewControllerBasedStatusBarAppearance) {
        CDVViewController* vc = (CDVViewController*)self.viewController;
        vc.sb_statusBarStyle = [NSNumber numberWithInt:style];
        [self refreshStatusBarAppearance];
        
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:style];
    }
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
    [self setStyleForStatusBar:UIStatusBarStyleDefault];
}

- (void) styleLightContent:(CDVInvokedUrlCommand*)command
{
    [self setStyleForStatusBar:UIStatusBarStyleLightContent];
}

- (void) styleBlackTranslucent:(CDVInvokedUrlCommand*)command
{
    [self setStyleForStatusBar:UIStatusBarStyleBlackTranslucent];
}

- (void) styleBlackOpaque:(CDVInvokedUrlCommand*)command
{
    [self setStyleForStatusBar:UIStatusBarStyleBlackOpaque];
}

- (void) backgroundColorByName:(CDVInvokedUrlCommand*)command
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

- (void) _backgroundColorByHexString:(NSString*)hexString
{
    unsigned int rgbValue = 0;
    NSScanner* scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];
    
    _statusBarBackgroundView.backgroundColor = [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (void) backgroundColorByHexString:(CDVInvokedUrlCommand*)command
{
    NSString* value = [command.arguments objectAtIndex:0];
    if (!([value isKindOfClass:[NSString class]])) {
        value = @"#000000";
    }
    
    if (![value hasPrefix:@"#"] || [value length] < 7) {
        return;
    }
    
    [self _backgroundColorByHexString:value];
}

- (void) hideStatusBar
{
    if (_uiviewControllerBasedStatusBarAppearance) {
        CDVViewController* vc = (CDVViewController*)self.viewController;
        vc.sb_hideStatusBar = [NSNumber numberWithBool:YES];
        [self refreshStatusBarAppearance];

    } else {
        UIApplication* app = [UIApplication sharedApplication];
        [app setStatusBarHidden:YES];
    }
}
    
- (void) hide:(CDVInvokedUrlCommand*)command
{
    UIApplication* app = [UIApplication sharedApplication];
    
    if (!app.isStatusBarHidden)
    {
        self.viewController.wantsFullScreenLayout = YES;
        [self hideStatusBar];

        if (IsAtLeastiOSVersion(@"7.0")) {
            [_statusBarBackgroundView removeFromSuperview];
        }
        
        CGRect bounds = [[UIScreen mainScreen] bounds];
        
        self.viewController.view.frame = bounds;
        self.webView.frame = bounds;
    }
}
    
- (void) showStatusBar
{
    if (_uiviewControllerBasedStatusBarAppearance) {
        CDVViewController* vc = (CDVViewController*)self.viewController;
        vc.sb_hideStatusBar = [NSNumber numberWithBool:NO];
        [self refreshStatusBarAppearance];

    } else {
        UIApplication* app = [UIApplication sharedApplication];
        [app setStatusBarHidden:NO];
    }
}
    
- (void) show:(CDVInvokedUrlCommand*)command
{
    UIApplication* app = [UIApplication sharedApplication];
    
    if (app.isStatusBarHidden)
    {
        BOOL isIOS7 = (IsAtLeastiOSVersion(@"7.0"));
        self.viewController.wantsFullScreenLayout = isIOS7;
        
        [self showStatusBar];
        
        if (isIOS7) {
            CGRect bounds = [[UIScreen mainScreen] bounds];
            self.viewController.view.frame = bounds;
            
            CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
            
            if (!self.statusBarOverlaysWebView) {
                bounds.origin.y = statusBarFrame.size.height;
                bounds.size.height -= statusBarFrame.size.height;
                
                [self.webView.superview addSubview:_statusBarBackgroundView];
            }

            self.webView.frame = bounds;
            
        } else {
            
            CGRect bounds = [[UIScreen mainScreen] applicationFrame];
            self.viewController.view.frame = bounds;
        }
    }
}

- (void) dealloc
{
    [[UIApplication sharedApplication] removeObserver:self forKeyPath:@"statusBarHidden"];
}


@end
