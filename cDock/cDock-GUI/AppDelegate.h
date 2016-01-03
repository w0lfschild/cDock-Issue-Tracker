//
//  AppDelegate.h
//  cDock GUI
//
//  Created by Wolfgang Baird on 09.09.2015.
//  Copyright © 2015 Wolfgang Baird. All rights reserved.
//

@import Foundation;
@import AppKit;
#import "WAYAppStoreWindow.h"
#import "PFAboutWindowController.h"
#import "PFMoveApplication.h"

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
@property PFAboutWindowController *aboutWindowController;
@property WAYAppStoreWindow *window;
@property (weak) IBOutlet NSPopover *poppy;

@property (weak) IBOutlet NSButton *pop_toggle;

@property (weak) IBOutlet NSButton *pop_info;
@property (weak) IBOutlet NSButton *pop_paypal;
@property (weak) IBOutlet NSButton *pop_email;
@property (weak) IBOutlet NSButton *pop_github;
@property (weak) IBOutlet NSButton *pop_translate;

// Views
@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSView *themeView;
@property (weak) IBOutlet NSView *simblView;
@property (weak) IBOutlet NSView *rootlView;
@property (weak) IBOutlet NSView *dockView;
@property (weak) IBOutlet NSView *prefView;


// cDock preferences
@property (weak) IBOutlet NSButton *reset_Dock;
@property (weak) IBOutlet NSButton *disable_cDock;
@property (weak) IBOutlet NSButton *auto_checkUpdates;
@property (weak) IBOutlet NSButton *auto_installUpdates;
@property (weak) IBOutlet NSButton *cdock_isVibrant;

@property IBOutlet NSTextView *changeLog;

// cDock settings
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
@property (weak) IBOutlet NSPopUpButton *cd_theme;

// Color pickers
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

// Indicators
@property (weak) IBOutlet NSButton *cd_customIndicator;
@property (weak) IBOutlet NSButton *cd_indicatorBG;
@property (weak) IBOutlet NSButton *cd_sizeIndicator;
@property (weak) IBOutlet NSSlider *cd_indicatorWidth;
@property (weak) IBOutlet NSSlider *cd_indicatorHeight;
@property (weak) IBOutlet NSColorWell *indicatorWELL;

// Image background
@property (weak) IBOutlet NSButton *cd_is3D;
@property (weak) IBOutlet NSSlider *cd_backgroundAlpha;
@property (weak) IBOutlet NSButton *cd_pictureBackground;

// Dock settings
@property (weak) IBOutlet NSButton *dock_SOAA;// show only active apps
@property (weak) IBOutlet NSButton *dock_DHI; // dim hidden items
@property (weak) IBOutlet NSButton *dock_LDC; // lock dock contents
@property (weak) IBOutlet NSButton *dock_MOH; // mouse over highlight
@property (weak) IBOutlet NSButton *dock_AOB; // app opening bounce
@property (weak) IBOutlet NSButton *dock_SAM; // single app mode
@property (weak) IBOutlet NSButton *dock_REC; // recents folder
@property (weak) IBOutlet NSButton *dock_MWI; // minimize window to icon
@property (weak) IBOutlet NSButton *dock_SAI; // show icon indicators
@property (weak) IBOutlet NSButton *dock_ANB; // app notification bounce
@property (weak) IBOutlet NSButton *dock_STO; // scroll to open

@property (weak) IBOutlet NSButton *dock_autohide;
@property (weak) IBOutlet NSButton *dock_magnification;

@property (weak) IBOutlet NSPopUpButton *dock_POS;
@property (weak) IBOutlet NSPopUpButton *dock_MU;

@property (weak) IBOutlet NSTextField *dock_autohide_value;
@property (weak) IBOutlet NSTextField *dock_magnification_value;
@property (weak) IBOutlet NSTextField *dock_tilesize;
@property (weak) IBOutlet NSTextField *dock_appSpacers;
@property (weak) IBOutlet NSTextField *dock_docSpacers;

@property (weak) IBOutlet NSButton *cd_installSIMBL;

@end

NSMutableDictionary *prefCD;
NSMutableDictionary *pref;
NSMutableDictionary *prefd;