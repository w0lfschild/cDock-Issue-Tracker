//
//  AppDelegate.m
//  cDock-Helper
//
//  Created by Wolfgang Baird on 10/3/15.
//  Copyright © 2015 Wolfgang Baird. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property int dockPID;
@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
//    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
//                                                           selector:@selector(thingHappened:)
//                                                               name:NSWorkspaceDidLaunchApplicationNotification
//                                                             object:nil];
//    
//    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
//                                                           selector:@selector(thingHappened:)
//                                                               name:NSWorkspaceDidTerminateApplicationNotification
//                                                             object:nil];
    
    _dockPID = 0;
    NSArray *run = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *t in run)
    {
        if ([t.bundleIdentifier isEqualToString:@"com.apple.dock"])
        {
            _dockPID = t.processIdentifier;
            NSLog(@"%d", t.processIdentifier);
        }
    }
    
    dispatch_queue_t myQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(myQueue, ^{
        // Insert code to be executed on another thread here
        
        do
        {
            for (NSRunningApplication *t in [[NSWorkspace sharedWorkspace] runningApplications])
            {
                if ([t.bundleIdentifier isEqualToString:@"com.apple.dock"])
                {
                    if (t.processIdentifier != _dockPID)
                    {
                        _dockPID = t.processIdentifier;
                        NSLog(@"New ID");
                    }
                }
            }
            usleep(3000000);
            // Objective-C statements here
        } while (true);
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // Insert code to be executed on the main thread here
//        });
    });
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}



-(void) thingHappened:(NSNotification *)notification {
    NSRunningApplication *runApp = [[notification userInfo] valueForKey:@"NSWorkspaceApplicationKey"];
//    NSArray *run = [[NSWorkspace sharedWorkspace] runningApplications];
//    NSLog(@"%@", run);
    NSLog(@"%@", runApp.bundleIdentifier);
    if ([runApp.bundleIdentifier isEqualToString:@"com.apple.dock"])
        NSLog(@"start");
    
}

@end
