//
//  cd_shared.h
//  cDock
//
//  Created by Wolfgang Baird on 12/21/15.
//  Copyright © 2015 Wolfgang Baird. All rights reserved.
//

#define appsuppt    [[[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] firstObject] path]
#define dockPath    [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.apple.dock.plist"]
#define thmePath    [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/org.w0lf.cDock.plist"]
#define thmeName    [[NSMutableDictionary dictionaryWithContentsOfFile:thmePath] objectForKey:@"cd_theme"]
#define prefPath    [[appsuppt stringByAppendingPathComponent:@"cDock/themes/"] stringByAppendingPathComponent:thmeName]
#define prefFile    [[prefPath stringByAppendingPathComponent:thmeName ] stringByAppendingString:@".plist"]
#define readPref(p) [[Preferences sharedInstance] valueForKeyPath:p]

#define iscDockEnabled   [[[Preferences sharedInstance2] objectForKey:@"cd_enabled"] boolValue]

#import "Preferences.h"
#import "ZKSwizzle.h"
@import AppKit;

extern NSInteger orient;
extern long osx_minor;
extern CGImageRef background;
extern CGImageRef background1;
extern BOOL loadShadows;
extern BOOL loadImages;
extern BOOL loadIndicators;
extern CALayer *FLOORLAYER;

extern CGImageRef large;
extern CGImageRef medium;
extern CGImageRef small;
extern CGImageRef medium_simple;
extern CGImageRef small_simple;

extern bool dispatch_prefFile;
extern bool dispatch_dockFile;

extern void _loadShadows();
extern void _forceRefresh();
extern void _loadImages();
extern NSColor* _readColor(NSString* key);

@interface cd_shared : NSObject
@end
