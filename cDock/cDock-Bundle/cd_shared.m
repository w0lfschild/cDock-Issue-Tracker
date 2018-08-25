//
//  cd_shared.m
//  cDock
//
//  Created by Wolfgang Baird on 12/21/15.
//  Copyright © 2015 Wolfgang Baird. All rights reserved.
//

#import "cd_shared.h"

@implementation cd_shared 

CGImageRef _fetchIMG(NSString* file) {
    CGImageRef result = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *picFile = [NSString stringWithFormat:@"%@/%@", prefPath, file];
    if ([fileManager fileExistsAtPath:picFile])
        result = CGImageCreateWithPNGDataProvider(CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:picFile]), NULL, true, kCGRenderingIntentDefault);
    //    CGDataProviderRef imgDataProvider;
    //        imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:picFile]);
    //        result = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
    return result;
}

NSColor* _readColor(NSString* key) {
    NSColor *goodColor = nil;
    NSMutableDictionary *keyDict = [readPref(key) copy];
    NSNumber *red = nil, *blu = nil, *grn = nil;
    if ([keyDict allKeys].count) {
        red = [keyDict objectForKey:@"red"];
        blu = [keyDict objectForKey:@"blu"];
        grn = [keyDict objectForKey:@"grn"];
    }
    goodColor = [NSColor colorWithRed:red.floatValue/255.0 green:grn.floatValue/255.0 blue:blu.floatValue/255.0 alpha:100.0];
    return goodColor;
}

void _loadImages() {
    if (loadImages) {
        loadImages      = false;
        background      = _fetchIMG(@"background.png");
        background1     = _fetchIMG(@"background1.png");
        large           = _fetchIMG(@"indicator_large.png");
        medium          = _fetchIMG(@"indicator_medium.png");
        small           = _fetchIMG(@"indicator_small.png");
        medium_simple   = _fetchIMG(@"indicator_medium_simple.png");
        small_simple    = _fetchIMG(@"indicator_small_simple.png");
    }
}

void _toggleIndicators() {    
    Class cls = NSClassFromString(@"DOCKPreferences");
    id dockPref = nil;
    SEL aSel = NSSelectorFromString(@"preferences");
    if ([cls respondsToSelector:aSel]) {
        dockPref = [cls performSelector:aSel];
    }
    if (dockPref) {
        NSString *key = @"showProcessIndicatorsPref";
        id val = [dockPref valueForKey:key];
        if (val) {
            [dockPref setValue:[NSNumber numberWithBool:![val boolValue]] forKey:key];
            [dockPref setValue:val forKey:key];
        }
    }
}

void _forceRefresh() {
    // Send AppleInterfaceThemeChangedNotification if we're on macOS above Mavericks
    if (osx_minor > 9) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("AppleInterfaceThemeChangedNotification"), (void *)0x1, NULL, YES);
        });
    }
    
    // Either hook the floor layer for the first time or send it layoutSublayers
    if (FLOORLAYER == nil) {
        Class cls1;
        if (osx_minor == 10) {
            cls1 = NSClassFromString(@"DOCKFloorLayer");
        } else {
            cls1 = NSClassFromString(@"DOCK.FloorLayer");
        }
        SEL aSel1 = NSSelectorFromString(@"layoutSublayers");
        if ([cls1 respondsToSelector:aSel1])
            [cls1 performSelector:aSel1];
        _toggleIndicators();
    } else {
        SEL aSel = NSSelectorFromString(@"layoutSublayers");
        if ([FLOORLAYER respondsToSelector:aSel])
            [FLOORLAYER performSelector:aSel];
    }
}

void _loadShadows(CALayer *layer) {
    if (loadShadows) {
        loadShadows = false;
        
        SEL aSel = @selector(layoutSublayers);
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        SEL bSel = @selector(updateIndicatorForSize:);
        #pragma clang diagnostic pop
        
        if ([[[Preferences sharedInstance] objectForKey:@"cd_colorIndicator"] boolValue]) {
            Class cls = NSClassFromString(@"DOCKIndicatorLayer");
            if ([cls respondsToSelector:bSel]) {
                [cls performSelector:bSel];
            }
        }
        
        // Fix Tiles and Indicators
        NSMutableArray *tileLayers = [[NSMutableArray alloc] initWithArray:layer.superlayer.sublayers];
        for (CALayer *item in tileLayers) {
            if (item.class == NSClassFromString(@"DOCKTileLayer")) {
                if ([item respondsToSelector:aSel])
                    [item performSelector:aSel];
            }
            
            if (item.class == NSClassFromString(@"DOCKIndicatorLayer")) {
                if ([item respondsToSelector:aSel]) {
                    [item performSelector:aSel];
                }
            }
            
            //                if ([[[Preferences sharedInstance] objectForKey:@"cd_colorIndicator"] boolValue]) {
            //                    if (item.class == NSClassFromString(@"DOCKIndicatorLayer")) {
            //                        if ([item respondsToSelector:bSel])
            //                            [item performSelector:bSel withObject:[NSNumber numberWithFloat:0]];
            //                    }
            //                }
        }
    }
    
    if (loadIndicators) {
        loadIndicators = false;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            _toggleIndicators();
        });
    }
}

@end
