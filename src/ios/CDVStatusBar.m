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


@interface CDVStatusBar () <UIScrollViewDelegate>
- (void)fireTappedEvent;
- (void)updateIsVisible:(BOOL)visible;
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
        [self updateIsVisible:![newValue boolValue]];
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
    
    [self initializeStatusBarBackgroundView];
    
    self.viewController.view.autoresizesSubviews = YES;
    
    NSString* setting;
    
    setting  = @"StatusBarOverlaysWebView";
    if ([self settingForKey:setting]) {
        self.statusBarOverlaysWebView = [(NSNumber*)[self settingForKey:setting] boolValue];
    }
    
    setting  = @"StatusBarBackgroundColor";
    if ([self settingForKey:setting]) {
        [self _backgroundColorByHexString:[self settingForKey:setting]];
    }
    
    setting  = @"StatusBarStyle";
    if ([self settingForKey:setting]) {
        [self setStatusBarStyle:[self settingForKey:setting]];
    }
    
    // blank scroll view to intercept status bar taps
    self.webView.scrollView.scrollsToTop = NO;
    UIScrollView *fakeScrollView = [[UIScrollView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    fakeScrollView.delegate = self;
    fakeScrollView.scrollsToTop = YES;
    [self.viewController.view addSubview:fakeScrollView]; // Add scrollview to the view heirarchy so that it will begin accepting status bar taps
    [self.viewController.view sendSubviewToBack:fakeScrollView]; // Send it to the very back of the view heirarchy
    fakeScrollView.contentSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height * 2.0f); // Make the scroll view longer than the screen itself
    fakeScrollView.contentOffset = CGPointMake(0.0f, UIScreen.mainScreen.bounds.size.height); // Scroll down so a tap will take scroll view back to the top
}

- (void)onReset {
    _eventsCallbackId = nil;
}

- (void)fireTappedEvent {
    if (_eventsCallbackId == nil) {
        return;
    }
    NSDictionary* payload = @{@"type": @"tap"};
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:payload];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:_eventsCallbackId];
}

- (void)updateIsVisible:(BOOL)visible {
    if (_eventsCallbackId == nil) {
        return;
    }
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:visible];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:_eventsCallbackId];
}


- (void) _ready:(CDVInvokedUrlCommand*)command
{
    _eventsCallbackId = command.callbackId;
    [self updateIsVisible:![UIApplication sharedApplication].statusBarHidden];
}

- (void) initializeStatusBarBackgroundView
{
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    statusBarFrame = [self invertFrameIfNeeded:statusBarFrame orientation:self.viewController.interfaceOrientation];
    
    _statusBarBackgroundView = [[UIView alloc] initWithFrame:statusBarFrame];
    _statusBarBackgroundView.backgroundColor = _statusBarBackgroundColor;
    _statusBarBackgroundView.autoresizingMask = (UIViewAutoresizingFlexibleWidth  | UIViewAutoresizingFlexibleBottomMargin);
    _statusBarBackgroundView.autoresizesSubviews = YES;
}

- (CGRect) invertFrameIfNeeded:(CGRect)rect orientation:(UIInterfaceOrientation)orientation {
    // landscape is where (width > height). On iOS < 8, we need to invert since frames are
    // always in Portrait context
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) && (rect.size.width < rect.size.height)) {
        CGFloat temp = rect.size.width;
        rect.size.width = rect.size.height;
        rect.size.height = temp;
        rect.origin = CGPointZero;
    }
    
    return rect;
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
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            self.webView.frame = CGRectMake(0, 0, bounds.size.height, bounds.size.width);
        } else {
            self.webView.frame = bounds;
        }
        
    } else {
        
        CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
        statusBarFrame = [self invertFrameIfNeeded:statusBarFrame orientation:self.viewController.interfaceOrientation];
        
        [self initializeStatusBarBackgroundView];
        
        CGRect frame = self.webView.frame;
        frame.origin.y = statusBarFrame.size.height;
        frame.size.height -= statusBarFrame.size.height;
        
        self.webView.frame = frame;
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
    id value = [command argumentAtIndex:0];
    if (!([value isKindOfClass:[NSNumber class]])) {
        value = [NSNumber numberWithBool:YES];
    }
    
    self.statusBarOverlaysWebView = [value boolValue];
}

- (void) refreshStatusBarAppearanceWithAnimation:(BOOL)refreshAnimated duration:(NSTimeInterval)duration
{
    SEL sel = NSSelectorFromString(@"setNeedsStatusBarAppearanceUpdate");
    if ([self.viewController respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if (refreshAnimated) {
            [UIView animateWithDuration:duration animations:^() {
                [self.viewController performSelector:sel withObject:nil];
            }completion:^(BOOL finished){}];
        } else {
            [self.viewController performSelector:sel withObject:nil];
        }
#pragma clang diagnostic pop
    }
}

- (void) refreshStatusBarAppearanceWithAnimation:(BOOL)refreshAnimated
{
    [self refreshStatusBarAppearanceWithAnimation:refreshAnimated duration:0.1];
}

- (void) refreshStatusBarAppearance
{
    [self refreshStatusBarAppearanceWithAnimation:NO];
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
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 70000
# define TRANSLUCENT_STYLE UIStatusBarStyleBlackTranslucent
#else
# define TRANSLUCENT_STYLE UIStatusBarStyleLightContent
#endif
    [self setStyleForStatusBar:TRANSLUCENT_STYLE];
}

- (void) styleBlackOpaque:(CDVInvokedUrlCommand*)command
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 70000
# define OPAQUE_STYLE UIStatusBarStyleBlackOpaque
#else
# define OPAQUE_STYLE UIStatusBarStyleLightContent
#endif
    [self setStyleForStatusBar:OPAQUE_STYLE];
}

- (void) backgroundColorByName:(CDVInvokedUrlCommand*)command
{
    id value = [command argumentAtIndex:0];
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
    
    _statusBarBackgroundColor = [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
    _statusBarBackgroundView.backgroundColor = _statusBarBackgroundColor;
}

- (void) backgroundColorByHexString:(CDVInvokedUrlCommand*)command
{
    NSString* value = [command argumentAtIndex:0];
    if (!([value isKindOfClass:[NSString class]])) {
        value = @"#000000";
    }
    
    if (![value hasPrefix:@"#"] || [value length] < 7) {
        return;
    }
    
    [self _backgroundColorByHexString:value];
}

- (void) hideStatusBarWithAnimation:(BOOL)animated duration:(NSTimeInterval)duration
{
    if (_uiviewControllerBasedStatusBarAppearance) {
        CDVViewController* vc = (CDVViewController*)self.viewController;
        vc.sb_hideStatusBar = [NSNumber numberWithBool:YES];
        [self refreshStatusBarAppearanceWithAnimation:animated duration:duration];
        
    } else {
        UIApplication* app = [UIApplication sharedApplication];
        [app setStatusBarHidden:YES withAnimation:animated];
    }
}

- (void) hide:(CDVInvokedUrlCommand*)command
{
    UIApplication* app = [UIApplication sharedApplication];
    
    if (!app.isStatusBarHidden)
    {
        CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
        
        id animated = [command argumentAtIndex:0];
        if (!([animated isKindOfClass:[NSNumber class]])) {
            animated = [NSNumber numberWithBool:NO];
        }
        
        id duration = [command argumentAtIndex:1];
        if (!([duration isKindOfClass:[NSNumber class]])) {
            duration = [NSNumber numberWithDouble:0.1];
        }
        
        [self hideStatusBarWithAnimation:[animated boolValue] duration:[duration doubleValue]];
        
        if (IsAtLeastiOSVersion(@"7.0")) {
            [_statusBarBackgroundView removeFromSuperview];
        }
        
        if (!_statusBarOverlaysWebView) {
            
            CGRect frame = self.webView.frame;
            frame.origin.y = 0;
            if (!self.statusBarOverlaysWebView) {
                frame.size.height += MIN(statusBarFrame.size.height, statusBarFrame.size.width);
            }
            
            self.webView.frame = frame;
        }
        
        _statusBarBackgroundView.hidden = YES;
    }
}

- (void) showStatusBarWithAnimation:(BOOL)animated duration:(NSTimeInterval)duration
{
    if (_uiviewControllerBasedStatusBarAppearance) {
        CDVViewController* vc = (CDVViewController*)self.viewController;
        vc.sb_hideStatusBar = [NSNumber numberWithBool:NO];
        [self refreshStatusBarAppearanceWithAnimation:animated duration:duration];
        
    } else {
        UIApplication* app = [UIApplication sharedApplication];
        [app setStatusBarHidden:NO withAnimation:animated];
    }
}

- (void) show:(CDVInvokedUrlCommand*)command
{
    UIApplication* app = [UIApplication sharedApplication];
    
    if (app.isStatusBarHidden)
    {
        BOOL isIOS7 = (IsAtLeastiOSVersion(@"7.0"));
        
        id animated = [command argumentAtIndex:0];
        if (!([animated isKindOfClass:[NSNumber class]])) {
            animated = [NSNumber numberWithBool:NO];
        }
        
        id duration = [command argumentAtIndex:1];
        if (!([duration isKindOfClass:[NSNumber class]])) {
            duration = [NSNumber numberWithDouble:0.1];
        }
        
        [self showStatusBarWithAnimation:[animated boolValue] duration:[duration doubleValue]];
        
        if (isIOS7) {
            CGRect frame = self.webView.frame;
            self.viewController.view.frame = [[UIScreen mainScreen] bounds];
            
            CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
            statusBarFrame = [self invertFrameIfNeeded:statusBarFrame orientation:self.viewController.interfaceOrientation];
            
            if (!self.statusBarOverlaysWebView) {
                
                // there is a possibility that when the statusbar was hidden, it was in a different orientation
                // from the current one. Therefore we need to expand the statusBarBackgroundView as well to the
                // statusBar's current size
                CGRect sbBgFrame = _statusBarBackgroundView.frame;
                frame.origin.y = statusBarFrame.size.height;
                frame.size.height -= statusBarFrame.size.height;
                sbBgFrame.size = statusBarFrame.size;
                
                _statusBarBackgroundView.frame = sbBgFrame;
                [self.webView.superview addSubview:_statusBarBackgroundView];
            }
            
            self.webView.frame = frame;
            
        } else {
            
            CGRect bounds = [[UIScreen mainScreen] applicationFrame];
            self.viewController.view.frame = bounds;
        }
        
        _statusBarBackgroundView.hidden = NO;
    }
}

- (void) dealloc
{
    [[UIApplication sharedApplication] removeObserver:self forKeyPath:@"statusBarHidden"];
}


#pragma mark - UIScrollViewDelegate

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    [self fireTappedEvent];
    return NO;
}

@end
