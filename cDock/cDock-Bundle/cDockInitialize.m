//
//  cDockInitialize.m
//

#import "cd_shared.h"

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

void notificationCallback (CFNotificationCenterRef center, void * observer, CFStringRef name, const void * object, CFDictionaryRef userInfo) {
    if ([(id)userInfo objectForKey:@"shadow"]) {
        loadShadows = true;
    }
    
    if ([(id)userInfo objectForKey:@"indicators"]) {
        loadIndicators = true;
    }
    
    if ([(id)userInfo objectForKey:@"images"]) {
        loadImages = true;
    }
    
    if ([(id)userInfo objectForKey:@"dock"]) {
        dispatch_prefFile = true;
        dispatch_dockFile = true;
        _forceRefresh();
    }
}

@interface cDockInitialize : NSObject
@end

@implementation cDockInitialize

+ (void)load {
    // Check macOS version
    osx_minor = [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion;
    
    // Watch for notifications from GUI
    CFNotificationCenterRef center = CFNotificationCenterGetDistributedCenter();
    CFNotificationCenterAddObserver(center, NULL, notificationCallback, CFSTR("MyNotification"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    
    // Make sure some prferences exist
    [cDockInitialize setupPrefs];
    
    // El Capitan and above swizzle
    if (osx_minor >= 11)
        ZKSwizzle(_CDDOCKFloorLayer, Dock.FloorLayer);
    
    // Yosemite swizzle
    if (osx_minor == 10)
        ZKSwizzle(_CDDOCKFloorLayer, DOCKFloorLayer);
    
    // Mavericks swizzle
    if (osx_minor == 9) {
        ZKSwizzle(_CDMAVFloor, DOCKGlassFloorLayer);
        ZKSwizzle(_CDMAVSide, DOCKSideGlassFloorLayer);
    }
    
    // Force refresh the dock
    _forceRefresh();
    
    // We've loaded
    NSLog(@"OS X 10.%li, cDock loaded...", osx_minor);
}


+ (void)setupPrefs {
    if (![[NSFileManager defaultManager] fileExistsAtPath:thmePath]) {
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        [newDict setObject:[NSNumber numberWithBool:false] forKey:@"cd_enabled"];
        [newDict setObject:@"default" forKey:@"cd_theme"];
        [newDict writeToFile:thmePath atomically:NO];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:prefFile]) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:prefPath]) {
            NSError * error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:prefPath withIntermediateDirectories:YES attributes:nil error:&error];
        }
    }
}

@end
