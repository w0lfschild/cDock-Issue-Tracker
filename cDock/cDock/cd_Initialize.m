//
//  cDockInitialize.m
//

#import "cd_shared.h"
#import "UncaughtExceptionHandler.h"

NSInteger orient = 0;
long osx_minor = 0;
CGImageRef background;
CGImageRef background1;
BOOL loadShadows = true;
BOOL loadImages = true;
BOOL loadIndicators = true;
CALayer *FLOORLAYER = nil;
CGImageRef large;
CGImageRef medium;
CGImageRef small;
CGImageRef medium_simple;
CGImageRef small_simple;
bool dispatch_prefFile = true;
bool dispatch_dockFile = true;

// Force dock into dark or light mode
ZKSwizzleInterface(wb_CFXPreferences, _CFXPreferences, NSObject)
@implementation wb_CFXPreferences

- (void *)copyAppValueForKey:(struct __CFString *)arg1 identifier:(struct __CFString *)arg2 container:(struct __CFString *)arg3 configurationURL:(struct __CFURL *)arg4
{
//    NSLog(@"wb_ %@", arg1);
    if ([(__bridge NSString *)arg1 isEqualToString:@"AppleInterfaceTheme"] || [(__bridge NSString *)arg1 isEqualToString:@"AppleInterfaceStyle"]) {
        if ([[[Preferences sharedInstance2] objectForKey:@"cd_enabled"] boolValue])
        {
            if ([[[Preferences sharedInstance] objectForKey:@"cd_darkMode"] intValue] == 1) {
                return @"Light";
            } else if ([[[Preferences sharedInstance] objectForKey:@"cd_darkMode"] intValue] == 2) {
                return @"Dark";
            } else if ([[[Preferences sharedInstance] objectForKey:@"cd_darkMode"] intValue] == 3) {
                if ([(id)ZKOrig(void *, arg1, arg2, arg3, arg4)  isEqual:@"Dark"]) {
                    return @"Light";
                } else {
                    return @"Dark";
                }
            } else {
                return ZKOrig(void *, arg1, arg2, arg3, arg4);
            }
        } else {
            return ZKOrig(void *, arg1, arg2, arg3, arg4);
        }
    } else {
        return ZKOrig(void *, arg1, arg2, arg3, arg4);
    }
}

@end

void notificationCallback (CFNotificationCenterRef center,
                           void * observer,
                           CFStringRef name,
                           const void * object,
                           CFDictionaryRef userInfo) {
//    CFShow(CFSTR("Received notification (dictionary):"));
//    NSLog(@"Got notification"); 
//    NSLog(@"%@", userInfo);
    
    if ([ (id)userInfo objectForKey:@"shadow"]) {
        loadShadows = true;
    }
    
    if ([ (id)userInfo objectForKey:@"indicators"]) {
        loadIndicators = true;
    }
    
    if ([ (id)userInfo objectForKey:@"images"]) {
        loadImages = true;
    }
    
//    NSLog(@"%@", res);
    if ([ (id)userInfo objectForKey:@"dock"]) {
        dispatch_prefFile = true;
        dispatch_dockFile = true;
        _forceRefresh();
//        NSLog(@"%@", res);
//        NSLog(@"cDock Reloaded");
    }
}

void _setupPrefs()
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:thmePath]) {
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        
        [newDict setObject:[NSNumber numberWithBool:false] forKey:@"cd_enabled"];
        [newDict setObject:@"default" forKey:@"cd_theme"];
        
        [newDict writeToFile:thmePath atomically:NO];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:prefFile]) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:prefPath]) {
            NSError * error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath: prefPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:&error];
        }
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        
        // There are so many of these I need to add here....
        
        // Stuff
        [newDict setObject:[NSNumber numberWithBool:false] forKey:@"cd_fullWidth"];
        [newDict setObject:[NSNumber numberWithBool:false] forKey:@"cd_hideLabels"];
        [newDict setObject:[NSNumber numberWithBool:false] forKey:@"cd_darkenMouseOver"];
        [newDict setObject:[NSNumber numberWithBool:false] forKey:@"cd_customIndicator"];
        [newDict setObject:[NSNumber numberWithBool:false] forKey:@"cd_iconReflection"];
        [newDict setObject:[NSNumber numberWithBool:false] forKey:@"cd_isTransparent"];
        [newDict setObject:[NSNumber numberWithInt:0] forKey:@"cd_darkMode"];
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_cornerRadius"];
        
        // Default layers
        [newDict setObject:[NSNumber numberWithBool:true] forKey:@"cd_showFrost"];
        [newDict setObject:[NSNumber numberWithBool:true] forKey:@"cd_showGlass"];
        [newDict setObject:[NSNumber numberWithBool:true] forKey:@"cd_showSeparator"];
        
        // Icon shadows
        [newDict setObject:[NSNumber numberWithBool:false] forKey:@"cd_iconShadow"];
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_iconShadowBGR"];
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_iconShadowBGG"];
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_iconShadowBGB"];
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_iconShadowBGA"];  // Alpha
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_iconShadowBGS"];  // Size
        
        // Dock background coloring
        [newDict setObject:[NSNumber numberWithBool:false] forKey:@"cd_dockBG"];
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_dockBGR"];
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_dockBGG"];
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_dockBGB"];
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_dockBGA"];
        
        // Label background coloring
        [newDict setObject:[NSNumber numberWithBool:false] forKey:@"cd_labelBG"];
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_labelBGR"];
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_labelBGG"];
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_labelBGB"];
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_labelBGA"];
        
        [newDict writeToFile:prefFile atomically:NO];
    }
}

@interface initialize : NSObject
@end
@implementation initialize
+ (void)load
{
    // Read system version
    osx_minor = [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion;
    
    // access DistributedCenter
    CFNotificationCenterRef center = CFNotificationCenterGetDistributedCenter();
    
    // add an observer
    CFNotificationCenterAddObserver(center, NULL, notificationCallback,
                                    CFSTR("MyNotification"), NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    
    InstallUncaughtExceptionHandler();
    
    // Create prefs if they don't exist
    _setupPrefs();
    
    // Swizzle based on OSX version
    if (osx_minor >= 11)
        ZKSwizzle(_CDDOCKFloorLayer, Dock.FloorLayer);
    if (osx_minor == 10)
        ZKSwizzle(_CDDOCKFloorLayer, DOCKFloorLayer);
    if (osx_minor == 9)
    {
        ZKSwizzle(_CDMAVFloor, DOCKGlassFloorLayer);
        ZKSwizzle(_CDMAVSide, DOCKSideGlassFloorLayer);
    }
    
    // Force dock to refresh
    _forceRefresh();
    
    NSLog(@"OS X 10.%li, cDock loaded...", osx_minor);
}
@end
