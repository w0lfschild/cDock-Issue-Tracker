//
//  AppDelegate.m
//  cDock-Menubar
//
//  Created by Wolfgang Baird on 7/21/15.
//  Copyright © 2015 Wolfgang Baird. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (assign, nonatomic) BOOL darkModeOn;
@end

@implementation AppDelegate

NSStatusItem *statusItem;
NSMenu *theMenu;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    theMenu = [[NSMenu alloc] initWithTitle:@""];
    [theMenu setAutoenablesItems:NO];
    
    [theMenu addItemWithTitle:@"Restart Dock" action:@selector(restart_dock:) keyEquivalent:@""];
    [theMenu addItemWithTitle:@"Restart Finder" action:@selector(restart_finder:) keyEquivalent:@""];
    [theMenu addItemWithTitle:@"Restart Agent" action:@selector(restart_agent:) keyEquivalent:@""];
    [theMenu addItem:[NSMenuItem separatorItem]]; // A thin grey line
    [theMenu addItemWithTitle:@"Open cDock" action:@selector(open_cdock:) keyEquivalent:@""];
    [theMenu addItem:[NSMenuItem separatorItem]]; // A thin grey line
    [theMenu addItemWithTitle:@"About" action:@selector(bringToFront:) keyEquivalent:@""];
    [theMenu addItemWithTitle:@"Visit Website" action:@selector(visit_website:) keyEquivalent:@""];
//    [theMenu addItemWithTitle:@"Check for updates..." action:nil keyEquivalent:@""];
    [theMenu addItem:[NSMenuItem separatorItem]]; // A thin grey line
    [theMenu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
    
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    statusItem = [statusBar statusItemWithLength:NSVariableStatusItemLength];
    
    NSImage *myimage = [NSImage imageNamed:@"icon.png"];
    
    BOOL oldBusted = (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_9);
    if (!oldBusted)
    {
        // 10.10 or higher, so setTemplate: is safe
        [myimage setTemplate:YES];
    }
    
    statusItem.image = myimage;
//    statusItem.alternateImage = [NSImage imageNamed:@"dark.png"];
    
//    [statusItem setToolTip:@"This is our tool tip text"];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:theMenu];
}

- (IBAction)check_for_updates:(id)sender {
    system("echo hello");
}

- (IBAction)open_cdock:(id)sender {
    system("open -b org.w0lf.cDock");
}

- (IBAction)restart_agent:(id)sender {
    system("killall Dock; killall \"SIMBL Agent\"; killall \"cDock Agent\"; open -b org.w0lf.cDockAgent");
}

- (IBAction)restart_finder:(id)sender {
    system("if [[ $(lsof -c Finder | grep MacOS/XtraFinder) ]]; then killall Finder; open -b com.trankynam.XtraFinder; elif [[ $(lsof -c Finder | grep MacOS/TotalFinder) ]]; then killall Finder; open -b com.binaryage.totalfinder.agent; else killall Finder; fi; sleep 1; osascript -e 'tell application \"Dock\" to inject SIMBL into Snow Leopard'");
}

- (IBAction)restart_dock:(id)sender {
    system("killall Dock; sleep 1; osascript -e 'tell application \"Dock\" to inject SIMBL into Snow Leopard'");
}

- (IBAction)visit_website:(id)sender {
    system("open http://w0lfschild.github.io/pages/cdock.html");
}

-(IBAction)bringToFront:(id)sender{
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanel:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
}

@end
