//
//  ViewController.h
//  ModckPreferences
//
//  Created by Mustafa Gezen on 19.07.2015.
//  Copyright © 2015 Mustafa Gezen. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ViewController : NSViewController

@property (weak) IBOutlet NSButton *fullWidthDock;
@property (weak) IBOutlet NSButton *hideLabels;

@property (weak) IBOutlet NSButton *changeDockBG;
@property (weak) IBOutlet NSTextField *dockBGR;
@property (weak) IBOutlet NSTextField *dockBGG;
@property (weak) IBOutlet NSTextField *dockBGB;
@property (weak) IBOutlet NSTextField *dockBGA;
@property (weak) IBOutlet NSColorWell *dockWELL;

@property (weak) IBOutlet NSButton *labelBG;
@property (weak) IBOutlet NSTextField *labelBGR;
@property (weak) IBOutlet NSTextField *labelBGG;
@property (weak) IBOutlet NSTextField *labelBGB;
@property (weak) IBOutlet NSTextField *labelBGA;
@property (weak) IBOutlet NSColorWell *labelWELL;

@property (weak) IBOutlet NSColorWell *shadowWELL;

@property (weak) IBOutlet NSButton *darken_OMO;
@property (weak) IBOutlet NSButton *stay_FROSTY;
@property (weak) IBOutlet NSButton *GLASSED;
@property (weak) IBOutlet NSButton *dock_SEP;

@property (weak) IBOutlet NSButton *dock_SOAA;
@property (weak) IBOutlet NSButton *dock_DHI;
@property (weak) IBOutlet NSButton *dock_LDC;
@property (weak) IBOutlet NSButton *dock_MOH;
@property (weak) IBOutlet NSButton *dock_NB;
@property (weak) IBOutlet NSButton *dock_SAM;
@property (weak) IBOutlet NSButton *dock_REC;

@end

NSMutableDictionary *pref;
NSMutableDictionary *prefd;