//
//  Initialize.m
//  cd
//
//  Created by Mustafa Gezen on 20.07.2015.
//  Copyright © 2015 Mustafa Gezen. All rights reserved.
//

#import "Opee/Opee.h"
# define dockPath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.apple.dock.plist"]
# define thmePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/org.w0lf.cDock.plist"]
# define thmeName [[NSMutableDictionary dictionaryWithContentsOfFile:thmePath] objectForKey:@"cd_theme"]
# define prefPath [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/cDock/themes/"] stringByAppendingPathComponent:thmeName]
# define prefFile [[prefPath stringByAppendingPathComponent:thmeName ] stringByAppendingString:@".plist"]

OPInitialize {
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
                system("killall -KILL Dock; sleep 1; osascript -e 'tell application \"Dock\" to inject SIMBL into Snow Leopard'");
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
        
//        Dock background frame adjustments x pos, y pos, width, height
//        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_increaseX"];
//        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_increaseY"];
//        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_increaseW"];
//        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_increaseH"];
        
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