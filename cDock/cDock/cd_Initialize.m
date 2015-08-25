//
//  cDockInitialize.m
//

#import "Preferences.h"
#import "ZKSwizzle.h"
#import "fishhook.h"
#import <dlfcn.h>
@import AppKit;

# define dockPath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.apple.dock.plist"]
# define thmePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/org.w0lf.cDock.plist"]
# define thmeName [[NSMutableDictionary dictionaryWithContentsOfFile:thmePath] objectForKey:@"cd_theme"]
# define prefPath [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/cDock/themes/"] stringByAppendingPathComponent:thmeName]
# define prefFile [[prefPath stringByAppendingPathComponent:thmeName ] stringByAppendingString:@".plist"]

extern NSInteger orient;
extern long osx_minor;
extern BOOL dispatch_prefFile;
extern BOOL dispatch_dockFile;
extern BOOL loadShadows;
extern BOOL loadImages;
extern void _forceRefresh();

void notificationCallback (CFNotificationCenterRef center,
                           void * observer,
                           CFStringRef name,
                           const void * object,
                           CFDictionaryRef userInfo) {
//    CFShow(CFSTR("Received notification (dictionary):"));
    NSLog(@"Got notification"); 
    
    NSString *res = [ (id)userInfo objectForKey:@"TestKey"];
//    NSLog(@"%@", res);
    
    if ([res isEqualToString:@"Reload"]) {
        dispatch_prefFile = true;
        dispatch_dockFile = true;
        loadImages = true;
        loadShadows = true;
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
    
    // Make sure hide-mirror = true for 10.9 but just do it on all versions anyways
    if ([[NSFileManager defaultManager] fileExistsAtPath:dockPath]) {
        NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:dockPath];
        if ([[ plist objectForKey:@"hide-mirror"] boolValue] == false) {
            system("defaults write com.apple.dock hide-mirror -bool TRUE");
            plist = [NSMutableDictionary dictionaryWithContentsOfFile:dockPath];
            if ([[ plist objectForKey:@"hide-mirror"] boolValue] == true) {
                system("killall -KILL Dock; sleep 1; osascript -e \"tell application \"Dock\" to inject SIMBL into Snow Leopard\"");
            }
        }
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
+ (void)load {
    // Read system version
    osx_minor = [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion;
    
    // access DistributedCenter
    CFNotificationCenterRef center = CFNotificationCenterGetDistributedCenter();
    
    // add an observer
    CFNotificationCenterAddObserver(center, NULL, notificationCallback,
                                    CFSTR("MyNotification"), NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    
    // remove oberver
//    CFNotificationCenterRemoveObserver(center, NULL, CFSTR("TestValue"), NULL);
    
    // Create prefs if they don't exist
    _setupPrefs();
    
    // Swizzle based on OSX version
    if (osx_minor == 11)
        ZKSwizzle(_CDDOCKFloorLayer, Dock.FloorLayer);
    if (osx_minor == 10)
        ZKSwizzle(_CDDOCKFloorLayer, DOCKFloorLayer);
    if (osx_minor == 9)
    {
        ZKSwizzle(_CDMAVFloor, DOCKGlassFloorLayer);
        ZKSwizzle(_CDMAVSide, DOCKSideGlassFloorLayer);
    }
    
    // Something tells me I could do this without fishhook if I already have ZKSwizzle
    // But I don't really know what's going on here
    if (osx_minor > 9) {
        orig_CFPreferencesCopyAppValue = dlsym(RTLD_DEFAULT, "CFPreferencesCopyAppValue");
        rebind_symbols((struct rebinding[1]){{"CFPreferencesCopyAppValue", hax_CFPreferencesCopyAppValue}}, 1);
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("AppleInterfaceThemeChangedNotification"), (void *)0x1, NULL, YES);
//        });
    }
    
    // Force dock to refresh
    _forceRefresh();
    
    NSLog(@"OS X 10.%li, cDock loaded...", osx_minor);
}

// Force dock into dark or light mode
static id (*orig_CFPreferencesCopyAppValue)(CFStringRef key, CFStringRef applicationID);
id hax_CFPreferencesCopyAppValue(CFStringRef key, CFStringRef applicationID)
{
//    NSLog(@"Key: %@, Original Value: %@", key, orig_CFPreferencesCopyAppValue(key, applicationID));
    if ([(__bridge NSString *)key isEqualToString:@"AppleInterfaceTheme"] || [(__bridge NSString *)key isEqualToString:@"AppleInterfaceStyle"]) {
        if ([[[Preferences sharedInstance] objectForKey:@"cd_darkMode"] intValue] == 1) {
            return @"Light";
        } else if ([[[Preferences sharedInstance] objectForKey:@"cd_darkMode"] intValue] == 2) {
            return @"Dark";
        } else if ([[[Preferences sharedInstance] objectForKey:@"cd_darkMode"] intValue] == 3) {
            if ([orig_CFPreferencesCopyAppValue(key, applicationID)  isEqual: @"Dark"]) {
                return @"Light";
            } else {
                return @"Dark";
            }
        } else {
            return orig_CFPreferencesCopyAppValue(key, applicationID);
        }
    } else {
        return orig_CFPreferencesCopyAppValue(key, applicationID);
    }
}
@end

