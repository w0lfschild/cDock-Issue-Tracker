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
    //    self.checkUpdates;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}

- (void)checkUpdates {
    NSBundle *myBundle = [NSBundle mainBundle];
    NSString *path = [myBundle pathForResource:@"updates/wUpdater.app/Contents/MacOS/wUpdater" ofType:@""];
    
//    dlurl=$(curl -s https://api.github.com/repos/w0lfschild/cDock/releases/latest | grep 'browser_' | cut -d\" -f4)
//    "$wupd_path" c "$app_path" org.w0lf.cDock "$3cur_ver" "$verurl" "$logurl" "$dlurl" "$autoinstall" &
    NSArray *args = [NSArray arrayWithObjects:@"c", [[NSBundle mainBundle] bundlePath], @"org.w0lf.cDock2",
            [NSString stringWithFormat:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]],
            @"https://raw.githubusercontent.com/w0lfschild/cDock/master/_resource/version.txt",
            @"https://raw.githubusercontent.com/w0lfschild/cDock/master/_resource/versionInfo.txt",
            @"https://github.com/w0lfschild/test/raw/master/cDock-GUI.zip",
            @"0", nil];

    [NSTask launchedTaskWithLaunchPath:path arguments:args];
    NSLog(@"Checking for updates...");
}

- (IBAction)showAboutWindow:(id)sender {
    [self.aboutWindowController setAppURL:[[NSURL alloc] initWithString:@"https://github.com/w0lfschild/cDock2"]];
    [self.aboutWindowController setAppName:@"cDock2"];
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
