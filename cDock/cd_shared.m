//
//  cd_shared.m
//  cDock
//
//  Created by Wolfgang Baird on 12/21/15.
//  Copyright © 2015 Wolfgang Baird. All rights reserved.
//

#import "cd_shared.h"

@interface cd_shared : NSObject
@end

@implementation cd_shared 

void _loadImages()
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (loadImages)
    {
        loadImages = false;
        NSString *picFile;
        
        picFile = [NSString stringWithFormat:@"%@/background.png", prefPath];
        if ([fileManager fileExistsAtPath:picFile])
            background = CGImageCreateWithPNGDataProvider(CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:picFile]), NULL, true, kCGRenderingIntentDefault);
        else
            background = nil;
        
        picFile = [NSString stringWithFormat:@"%@/background1.png", prefPath];
        if ([fileManager fileExistsAtPath:picFile])
            background1 = CGImageCreateWithPNGDataProvider(CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:picFile]), NULL, true, kCGRenderingIntentDefault);
        else
            background1 = nil;
        
        CGDataProviderRef imgDataProvider;
        imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/indicator_large.png", prefPath]]);
        large = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
        imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/indicator_medium.png", prefPath]]);
        medium = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
        imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/indicator_small.png", prefPath]]);
        small = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
        imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/indicator_medium_simple.png", prefPath]]);
        medium_simple = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
        imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/indicator_small_simple.png", prefPath]]);
        small_simple = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
    }
}

void _toggleIndicators()
{
    //    Class cls1 = NSClassFromString(@"DOCK.FloorLayer");
    //    SEL aSel1 = NSSelectorFromString(@"layoutSublayers");
    //    if ([cls1 respondsToSelector:aSel1]) {
    //        [cls1 performSelector:aSel1];
    //    }
    
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

void _forceRefresh()
{
    if (osx_minor > 9) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("AppleInterfaceThemeChangedNotification"), (void *)0x1, NULL, YES);
        });
    }
    
    if (FLOORLAYER == nil)
    {
        Class cls1 = NSClassFromString(@"DOCK.FloorLayer");
        SEL aSel1 = NSSelectorFromString(@"layoutSublayers");
        if ([cls1 respondsToSelector:aSel1]) {
            [cls1 performSelector:aSel1];
        }
        _toggleIndicators();
    } else {
        SEL aSel = NSSelectorFromString(@"layoutSublayers");
        if ([FLOORLAYER respondsToSelector:aSel]) {
            [FLOORLAYER performSelector:aSel];
        }
    }
}

// Fix for icon shadows / reflection layer not intializing on their own...
void _loadShadows(CALayer *layer)
{
    if (loadShadows) {
        loadShadows = false;
        
        SEL aSel = @selector(layoutSublayers);
        SEL bSel = @selector(updateIndicatorForSize:);
        
        if ([[[Preferences sharedInstance] objectForKey:@"cd_colorIndicator"] boolValue]) {
            Class cls = NSClassFromString(@"DOCKIndicatorLayer");
            if ([cls respondsToSelector:bSel]) {
                [cls performSelector:bSel];
            }
        }
        
        // Fix Tiles and Indicators
        NSMutableArray *tileLayers = [[NSMutableArray alloc] initWithArray:layer.superlayer.sublayers];
        for (CALayer *item in tileLayers)
        {
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
    
    if (loadIndicators)
    {
        loadIndicators = false;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            _toggleIndicators();
        });
    }
}


@end
