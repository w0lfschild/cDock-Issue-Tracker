//
//  AppDelegate.h
//  cDock GUI
//
//  Created by Wolfgang Baird on 09.09.2015.
//  Copyright © 2015 Wolfgang Baird. All rights reserved.
//

@import Foundation;
@import AppKit;
@import ServiceManagement;

#import <DevMateKit/DevMateKit.h>
#import "PFMoveApplication.h"
#import "StartAtLoginController.h"

# define appSupport  [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject]
# define usrLibrary  [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject]
# define themeName   [[NSMutableDictionary dictionaryWithContentsOfFile:plist_cDock] objectForKey:@"cd_theme"]
# define themeFldr   [appSupport stringByAppendingPathComponent:@"cDock/themes/"]
# define curThemFldr [appSupport stringByAppendingFormat:@"/cDock/themes/%@/", themeName]
# define plist_Theme [appSupport stringByAppendingFormat:@"/cDock/themes/%@/%@.plist", themeName, themeName]
# define plist_cDock [usrLibrary stringByAppendingPathComponent:@"Preferences/org.w0lf.cDock.plist"]
# define plist_Dock  [usrLibrary stringByAppendingPathComponent:@"Preferences/com.apple.dock.plist"]

//# define plist_Theme []

@interface NSToolTipManager : NSObject
{
    double toolTipDelay;
}
+ (id)sharedToolTipManager;
- (void)setInitialToolTipDelay:(double)arg1;
@end

@interface AppDelegate : NSObject <NSApplicationDelegate>

// Windows
@property NSWindow *window;

// Sparkle updater
@property (weak) IBOutlet SUUpdater *myUpdater;

@property IBOutlet NSTextField *appName;
@property IBOutlet NSTextField *appVersion;
@property IBOutlet NSTextField *appCopyright;

// Tab buttons
@property (weak) IBOutlet NSButton *viewTheming;
@property (weak) IBOutlet NSButton *viewDock;
@property (weak) IBOutlet NSButton *viewAbout;
@property (weak) IBOutlet NSButton *viewPreferences;
@property (weak) IBOutlet NSButton *reportbutton;
@property (weak) IBOutlet NSButton *donatebutton;

// Image buttons
@property (weak) IBOutlet NSButton *pop_paypal;
@property (weak) IBOutlet NSButton *pop_email;
@property (weak) IBOutlet NSButton *pop_github;
@property (weak) IBOutlet NSButton *pop_translate;

// Views
@property (weak) IBOutlet NSView *tabMain;
@property (weak) IBOutlet NSView *themeView;
@property (weak) IBOutlet NSView *dockView;
@property (weak) IBOutlet NSView *prefView;
@property (weak) IBOutlet NSView *aboutView;
@property (weak) IBOutlet NSView *simblView;
@property (weak) IBOutlet NSView *rootlView;

// cDock about
@property (weak) IBOutlet NSButton      *showChanges;
@property (weak) IBOutlet NSButton      *showEULA;
@property (weak) IBOutlet NSButton      *showCredits;

// cDock preferences
@property (weak) IBOutlet NSButton      *reset_Dock;
@property (weak) IBOutlet NSButton      *disable_cDock;
@property (weak) IBOutlet NSButton      *cdock_hideDonate;
@property (weak) IBOutlet NSButton      *cdock_rememberWindow;
@property (weak) IBOutlet NSButton      *cdock_isVibrant;
@property (weak) IBOutlet NSButton      *cdock_fastTooltips;
@property (weak) IBOutlet NSPopUpButton *cdock_updates;
@property (weak) IBOutlet NSPopUpButton *cdock_updates_interval;
@property        IBOutlet NSTextView    *cdock_changeLog;

/* cDock settings */
@property (weak) IBOutlet NSButton *cd_separatorfullHeight;
@property (weak) IBOutlet NSButton *cd_fullWidth;
@property (weak) IBOutlet NSButton *cd_hideLabels;
@property (weak) IBOutlet NSButton *cd_iconReflection;
@property (weak) IBOutlet NSButton *cd_darkenMouseOver;
@property (weak) IBOutlet NSButton *cd_showFrost;
@property (weak) IBOutlet NSButton *cd_showGlass;
@property (weak) IBOutlet NSButton *cd_showSeparator;
@property (weak) IBOutlet NSSlider *cd_cornerRadius;
@property (weak) IBOutlet NSSlider *cd_borderSize;
@property (weak) IBOutlet NSPopUpButton *cd_darkMode;
@property (weak) IBOutlet NSPopUpButton *cd_themePicker;
@property (weak) IBOutlet NSButton *dockBG;
@property (weak) IBOutlet NSColorWell *dockWELL;
@property (weak) IBOutlet NSButton *borderBG;
@property (weak) IBOutlet NSColorWell *borderWELL;
@property (weak) IBOutlet NSButton *labelBG;
@property (weak) IBOutlet NSColorWell *labelWELL;
@property (weak) IBOutlet NSButton *shadowBG;
@property (weak) IBOutlet NSColorWell *shadowWELL;
@property (weak) IBOutlet NSButton *separatorBG;
@property (weak) IBOutlet NSColorWell *separatorWELL;
@property (weak) IBOutlet NSButton *cd_customIndicator;
@property (weak) IBOutlet NSButton *cd_indicatorBG;
@property (weak) IBOutlet NSButton *cd_sizeIndicator;
@property (weak) IBOutlet NSSlider *cd_indicatorWidth;
@property (weak) IBOutlet NSSlider *cd_indicatorHeight;
@property (weak) IBOutlet NSColorWell *indicatorWELL;
@property (weak) IBOutlet NSButton *cd_is3D;
@property (weak) IBOutlet NSSlider *cd_backgroundAlpha;
@property (weak) IBOutlet NSButton *cd_pictureBackground;
/* cDock settings */

// Dock settings
@property (weak) IBOutlet NSButton *dock_SOAA;                      // dock show only active apps
@property (weak) IBOutlet NSButton *dock_DHI;                       // dock dim hidden items
@property (weak) IBOutlet NSButton *dock_LDC;                       // dock lock dock contents
@property (weak) IBOutlet NSButton *dock_MOH;                       // dock mouse over highlight
@property (weak) IBOutlet NSButton *dock_AOB;                       // dock app opening bounce
@property (weak) IBOutlet NSButton *dock_SAM;                       // dock single app mode
@property (weak) IBOutlet NSButton *dock_REC;                       // dock recents folder
@property (weak) IBOutlet NSButton *dock_MWI;                       // dock minimize window to icon
@property (weak) IBOutlet NSButton *dock_SAI;                       // dock show icon indicators
@property (weak) IBOutlet NSButton *dock_ANB;                       // dock app notification bounce
@property (weak) IBOutlet NSButton *dock_STO;                       // dock scroll to open
@property (weak) IBOutlet NSButton *dock_autohide;                  // dock autohide
@property (weak) IBOutlet NSButton *dock_magnification;             // dock magnification
@property (weak) IBOutlet NSPopUpButton *dock_POS;                  // dock position on screen
@property (weak) IBOutlet NSPopUpButton *dock_MU;                   // dock minimize using
@property (weak) IBOutlet NSTextField *dock_autohide_value;         // dock autohide value
@property (weak) IBOutlet NSTextField *dock_magnification_value;    // dock magnification value
@property (weak) IBOutlet NSTextField *dock_tilesize;               // dock tilesize
@property (weak) IBOutlet NSTextField *dock_appSpacers;             // dock application spacer count
@property (weak) IBOutlet NSTextField *dock_docSpacers;             // dock document spacer count

@property (weak) IBOutlet NSButton *cd_installSIMBL;

@end

NSMutableDictionary *prefCD;
NSMutableDictionary *pref;
NSMutableDictionary *prefd;
