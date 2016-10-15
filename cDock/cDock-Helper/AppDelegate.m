//
//  AppDelegate.m
//  cDock-Helper
//
//  Created by Wolfgang Baird on 10/3/15.
//  Copyright © 2015 Wolfgang Baird. All rights reserved.
//

@import Sparkle;
@import SIMBLManager;
#import "AppDelegate.h"
#include <CoreServices/CoreServices.h>
#include <sys/types.h>
#include <sys/event.h>
#include <sys/time.h>

@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

// We assume that some other code sets up gTargetPID.
static pid_t gTargetPID = -1;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self startObserving];
    [self checkSIMBL];
    [self checkForUpdates];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)startObserving {
    bool dockIsRunning = false;
    NSRunningApplication *app = nil;
    while (!dockIsRunning) {
        NSArray *processess = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.dock"];
        if (processess.count) {
            app = [processess objectAtIndex:0];
            if (app.processIdentifier != -1)
            {
                dockIsRunning = true;
                usleep(1000000);
                break;
            }
        }
        usleep(100000);
    }
    NSLog(@"Injecting");
    system("osascript -e \"tell application \\\"Dock\\\" to inject SIMBL into Snow Leopard\"");
    gTargetPID = app.processIdentifier;
    NSLog(@"%d", app.processIdentifier);
    NSLog(@"%@", app.bundleIdentifier);
    [self testNoteExit:nil];
}

- (void)checkForUpdates {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    path = [[[path stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
//    NSLog(@"%@", path);
    NSBundle *GUIBundle = [NSBundle bundleWithPath:path];
    SUUpdater *myUpdater = [SUUpdater updaterForBundle:GUIBundle];
    NSDictionary *GUIDefaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"org.w0lf.cDock-GUI"];
//    NSLog(@"%@", GUIDefaults);
    
    if (![[GUIDefaults objectForKey:@"SUHasLaunchedBefore"] boolValue])
    {
        [myUpdater setAutomaticallyChecksForUpdates:true];
        [myUpdater setAutomaticallyDownloadsUpdates:true];
    }
    
    if ([[GUIDefaults objectForKey:@"SUEnableAutomaticChecks"] boolValue])
    {
        NSLog(@"Checking for updates...");
        [myUpdater checkForUpdatesInBackground];
    }
}

- (void)checkSIMBL {    
    Boolean install = false;
    Boolean installOne = false;
    Boolean installTwo = false;
    SIMBLManager *sim_m = [SIMBLManager sharedInstance];
    
    if ([sim_m AGENT_needsUpdate])
    {
        install = true;
        installOne = true;
    }
    
    if ([sim_m OSAX_needsUpdate])
    {
        install = true;
        installTwo = true;
    }
    
    if (install)
    {
        if (installOne && !installTwo)
            [sim_m AGENT_install];
        
        if (installOne && installTwo)
            [sim_m SIMBL_install];
        
        if (installTwo && !installOne)
            [sim_m OSAX_install];
    }
}

- (IBAction)testNoteExit:(id)sender {
//    FILE *                  f;
    int                     kq;
    struct kevent           changes;
    CFFileDescriptorContext context = { 0, (__bridge void *)(self), NULL, NULL, NULL };
    CFRunLoopSourceRef      rls;
    
    // Create the kqueue and set it up to watch for SIGCHLD. Use the
    // new-in-10.5 EV_RECEIPT flag to ensure that we get what we expect.
    
    kq = kqueue();
    
    EV_SET(&changes, gTargetPID, EVFILT_PROC, EV_ADD | EV_RECEIPT, NOTE_EXIT, 0, NULL);
    (void) kevent(kq, &changes, 1, &changes, 1, NULL);
    
    // Wrap the kqueue in a CFFileDescriptor (new in Mac OS X 10.5!). Then
    // create a run-loop source from the CFFileDescriptor and add that to the
    // runloop.
    
    CFFileDescriptorRef noteExitKQueueRef = CFFileDescriptorCreate(NULL, kq, true, NoteExitKQueueCallback, &context);
    rls = CFFileDescriptorCreateRunLoopSource(NULL, noteExitKQueueRef, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
    CFRelease(rls);
    
    CFFileDescriptorEnableCallBacks(noteExitKQueueRef, kCFFileDescriptorReadCallBack);
    
    // Execution continues in NoteExitKQueueCallback, below.
}

static void NoteExitKQueueCallback(CFFileDescriptorRef f, CFOptionFlags callBackTypes, void *info) {
    struct kevent   event;
    
    (void) kevent( CFFileDescriptorGetNativeDescriptor(f), NULL, 0, &event, 1, NULL);
    
    // You've been notified!
    NSLog(@"terminated %d", (int) (pid_t) event.ident);
    AppDelegate *new = [[AppDelegate alloc] init];
    [new startObserving];
    // You've been notified!
}

@end
