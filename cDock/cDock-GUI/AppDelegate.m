//
//  AppDelegate.m
//  ModckPreferences
//
//  Created by Mustafa Gezen on 19.07.2015.
//  Copyright © 2015 Mustafa Gezen. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
    self.aboutWindowController = [[PFAboutWindowController alloc] init];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}

- (IBAction)showAboutWindow:(id)sender {
    [self.aboutWindowController setAppURL:[[NSURL alloc] initWithString:@"https://github.com/w0lfschild/cDock2"]];
    [self.aboutWindowController setAppName:@"cDock 2"];
    [self.aboutWindowController setAppCopyright:[[NSAttributedString alloc] initWithString:@"Copyright (c) 2015 Perceval F"
                                                                                attributes:@{
                                                                                             NSForegroundColorAttributeName : [NSColor tertiaryLabelColor],
                                                                                             NSFontAttributeName  : [NSFont fontWithName:@"HelveticaNeue" size:11]}]];
    [self.aboutWindowController setWindowShouldHaveShadow:YES];
    [self.aboutWindowController setAppVersion:[NSString stringWithFormat:@"Version %@ (Build 1)", [NSString stringWithFormat:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]]];
    [self.aboutWindowController showCredits:nil];
    [[NSRunningApplication currentApplication] activateWithOptions:(NSApplicationActivateAllWindows | NSApplicationActivateIgnoringOtherApps)];
    [self.aboutWindowController showWindow:nil];
}

@end
