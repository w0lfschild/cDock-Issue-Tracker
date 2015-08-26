//
//  WindowController.m
//  cDock
//
//  Created by Wolfgang Baird on 8/26/15.
//  Copyright © 2015 Wolfgang Baird. All rights reserved.
//

#import "WindowController.h"
#import "WAYAppStoreWindow.h"
#import "INAppStoreWindow.h"

@interface WindowController ()

@end

@implementation WindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
//    INAppStoreWindow *aWindow = (INAppStoreWindow *) [self window];
    WAYAppStoreWindow *aWindow = (WAYAppStoreWindow *) [self window];
    [aWindow setTitlebarAppearsTransparent:true];
    [aWindow setTitleVisibility:NSWindowTitleHidden];
    
    CGRect myFrame = aWindow.frame;
    [aWindow setTitleBarHeight:80]; //62
    [aWindow setFrame:myFrame display:true];
    
    self.window.backgroundColor = [NSColor whiteColor];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
