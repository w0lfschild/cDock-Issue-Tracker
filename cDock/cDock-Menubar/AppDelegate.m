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
long osx_minor = 0;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    osx_minor = [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion;
    
    self.aboutWindowController = [[PFAboutWindowController alloc] init];
    
    theMenu = [[NSMenu alloc] initWithTitle:@""];
    [theMenu setAutoenablesItems:NO];
    
    [theMenu addItemWithTitle:@"Refresh Dock" action:@selector(refresh_dock:) keyEquivalent:@""];
    [theMenu addItem:[NSMenuItem separatorItem]]; // A thin grey line
    [theMenu addItemWithTitle:@"Restart Dock" action:@selector(restart_dock:) keyEquivalent:@""];
    [theMenu addItemWithTitle:@"Restart Finder" action:@selector(restart_finder:) keyEquivalent:@""];
    [theMenu addItemWithTitle:@"Restart Agent" action:@selector(restart_agent:) keyEquivalent:@""];
    [theMenu addItem:[NSMenuItem separatorItem]]; // A thin grey line
    [theMenu addItemWithTitle:@"Open cDock" action:@selector(open_cdock:) keyEquivalent:@""];
    [theMenu addItem:[NSMenuItem separatorItem]]; // A thin grey line
//    [theMenu addItemWithTitle:@"About" action:@selector(orderFrontStandardAboutPanel:) keyEquivalent:@""];
    [theMenu addItemWithTitle:@"About" action:@selector(aboutWindow:) keyEquivalent:@""];
    [theMenu addItemWithTitle:@"Donate" action:@selector(donate:) keyEquivalent:@""];
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

- (IBAction)aboutWindow:(id)sender
{
    if (osx_minor == 9)
    {
        [ [NSApplication sharedApplication] performSelector:@selector(orderFrontStandardAboutPanel:) ];
    }
    else
    {
        [ self showAboutWindow ];
    }
}

- (void)showAboutWindow
{
    [self.aboutWindowController setAppURL:[[NSURL alloc] initWithString:@"https://github.com/w0lfschild/cDock"]];
    [self.aboutWindowController setAppName:@"cDock"];
    [self.aboutWindowController setAppCopyright:[[NSAttributedString alloc] initWithString:@"Copyright (c) 2015 Wolfgang Baird"
                                                                                attributes:@{
                                                                                             NSForegroundColorAttributeName : [NSColor tertiaryLabelColor],
                                                                                             NSFontAttributeName  : [NSFont fontWithName:@"HelveticaNeue" size:11]}]];
    [self.aboutWindowController setAppVersion:@"Version 9.5"];
    [self.aboutWindowController setWindowShouldHaveShadow:YES];
    [self.aboutWindowController showCredits:nil];
    [[NSRunningApplication currentApplication] activateWithOptions:(NSApplicationActivateAllWindows | NSApplicationActivateIgnoringOtherApps)];
    [self.aboutWindowController showWindow:nil];
}

- (IBAction)refresh_dock:(id)sender {
    CFNotificationCenterRef center = CFNotificationCenterGetDistributedCenter(); //CFNotificationCenterGetLocalCenter();
    
    // post a notification
    CFDictionaryKeyCallBacks keyCallbacks = {0, NULL, NULL, CFCopyDescription, CFEqual, NULL};
    CFDictionaryValueCallBacks valueCallbacks  = {0, NULL, NULL, CFCopyDescription, CFEqual};
    CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 1,
                                                                  &keyCallbacks, &valueCallbacks);
    CFDictionaryAddValue(dictionary, CFSTR("TestKey"), CFSTR("Reload"));
    
    //    CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("AppleInterfaceThemeChangedNotification"), (void *)0x1, NULL, YES);
    CFNotificationCenterPostNotification(center, CFSTR("MyNotification"), NULL, dictionary, TRUE);
    CFRelease(dictionary);
}

- (IBAction)donate:(id)sender {
    system("open http://goo.gl/vF92sf");
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
    system("open http://w0lfschild.github.io/cdock.html");
}

-(IBAction)bringToFront:(id)sender{
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanel:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
}

@end
