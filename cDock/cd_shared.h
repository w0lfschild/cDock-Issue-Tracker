//
//  cd_shared.h
//  cDock
//
//  Created by Wolfgang Baird on 12/21/15.
//  Copyright © 2015 Wolfgang Baird. All rights reserved.
//

#ifndef cd_shared_h
#define cd_shared_h
#define dockPath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.apple.dock.plist"]
#define thmePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/org.w0lf.cDock.plist"]
#define thmeName [[NSMutableDictionary dictionaryWithContentsOfFile:thmePath] objectForKey:@"cd_theme"]
#define prefPath [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/cDock/themes/"] stringByAppendingPathComponent:thmeName]
#define prefFile [[prefPath stringByAppendingPathComponent:thmeName ] stringByAppendingString:@".plist"]

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

#endif /* cd_shared_h */
