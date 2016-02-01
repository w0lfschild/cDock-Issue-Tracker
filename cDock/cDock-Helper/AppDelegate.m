//
//  AppDelegate.m
//  cDock-Helper
//
//  Created by Wolfgang Baird on 10/3/15.
//  Copyright © 2015 Wolfgang Baird. All rights reserved.
//

@import Sparkle;
#import "AppDelegate.h"
#include <CoreServices/CoreServices.h>
#include <sys/types.h>
#include <sys/event.h>
#include <sys/time.h>

@interface AppDelegate ()

@property int dockPID;
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

- (BOOL) runProcessAsAdministrator:(NSString*)scriptPath
                     withArguments:(NSArray *)arguments
                            output:(NSString **)output
                  errorDescription:(NSString **)errorDescription {
    
    NSString * allArgs = [arguments componentsJoinedByString:@" "];
    NSString * fullScript = [NSString stringWithFormat:@"'%@' %@", scriptPath, allArgs];
    
    NSDictionary *errorInfo = [NSDictionary new];
    NSString *script =  [NSString stringWithFormat:@"do shell script \"%@\" with administrator privileges", fullScript];
    
    NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
    NSAppleEventDescriptor * eventResult = [appleScript executeAndReturnError:&errorInfo];
    
    // Check errorInfo
    if (! eventResult)
    {
        // Describe common errors
        *errorDescription = nil;
        if ([errorInfo valueForKey:NSAppleScriptErrorNumber])
        {
            NSNumber * errorNumber = (NSNumber *)[errorInfo valueForKey:NSAppleScriptErrorNumber];
            if ([errorNumber intValue] == -128)
                *errorDescription = @"The administrator password is required to do this.";
        }
        
        // Set error message from provided message
        if (*errorDescription == nil)
        {
            if ([errorInfo valueForKey:NSAppleScriptErrorMessage])
                *errorDescription =  (NSString *)[errorInfo valueForKey:NSAppleScriptErrorMessage];
        }
        
        return NO;
    }
    else
    {
        // Set output to the AppleScript's output
        *output = [eventResult stringValue];
        
        return YES;
    }
}

- (void)startObserving {
    bool dockIsRunning = false;
    NSRunningApplication *app = nil;
    while (!dockIsRunning) {
        NSArray *processess = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.dock"];
        if (processess.count) {
            dockIsRunning = true;
            app = [processess objectAtIndex:0];
            usleep(1000000);
            break;
        }
        usleep(100000);
    }
    NSLog(@"Injecting");
    system("osascript -e \"tell application \\\"Dock\\\" to inject SIMBL into Snow Leopard\"");
    gTargetPID = app.processIdentifier;
    NSLog(@"%d", app.processIdentifier);
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
        [myUpdater setUpdateCheckInterval:86400];
    }
}

- (void)checkSIMBL {
    NSMutableDictionary *local = [NSMutableDictionary dictionaryWithContentsOfFile:@"/System/Library/ScriptingAdditions/SIMBL.osax/Contents/Info.plist"];
    NSMutableDictionary *current = [NSMutableDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SIMBL.osax/Contents/Info" ofType:@"plist"]];
    NSString *locVer = [local objectForKey:@"CFBundleVersion"];
    NSString *curVer = [current objectForKey:@"CFBundleVersion"];
    
    if (![locVer isEqualToString:curVer])
        [self installSIMBL];
}

- (void)installSIMBL {
    NSString *output = nil;
    NSString *processErrorDescription = nil;
    NSString *script = [[NSBundle mainBundle] pathForResource:@"SIMBL_Install" ofType:@"sh"];
//    NSLog(@"%@", script);
    bool success = [self runProcessAsAdministrator:script withArguments:[[NSArray alloc] init] output:&output errorDescription:&processErrorDescription];
    
    if (!success) {
        NSLog(@"Fail");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"SIMBL install failed!"];
        [alert setInformativeText:@"Something went wrong, probably System Integrity Protection."];
        [alert addButtonWithTitle:@"Ok"];
        NSLog(@"%ld", (long)[alert runModal]);
    }
}

- (IBAction)testNoteExit:(id)sender
{
    FILE *                  f;
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

static void NoteExitKQueueCallback(
                                   CFFileDescriptorRef f,
                                   CFOptionFlags       callBackTypes,
                                   void *              info
                                   )
{
    struct kevent   event;
    
    (void) kevent( CFFileDescriptorGetNativeDescriptor(f), NULL, 0, &event, 1, NULL);
    
    // You've been notified!
    NSLog(@"terminated %d", (int) (pid_t) event.ident);
    AppDelegate *new = [[AppDelegate alloc] init];
    [new startObserving];
    // You've been notified!
}

@end
