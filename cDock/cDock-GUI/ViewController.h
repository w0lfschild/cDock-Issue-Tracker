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
@property (weak) IBOutlet NSButton *cd_iconReflection;

@property (weak) IBOutlet NSButton *dockBG;
@property (weak) IBOutlet NSColorWell *dockWELL;

@property (weak) IBOutlet NSButton *borderBG;
@property (weak) IBOutlet NSColorWell *borderWELL;
@property (weak) IBOutlet NSSlider *cd_borderSize;

@property (weak) IBOutlet NSButton *labelBG;
@property (weak) IBOutlet NSColorWell *labelWELL;

@property (weak) IBOutlet NSButton *shadowBG;
@property (weak) IBOutlet NSColorWell *shadowWELL;

@property (weak) IBOutlet NSButton *darken_OMO;
@property (weak) IBOutlet NSButton *stay_FROSTY;
@property (weak) IBOutlet NSButton *GLASSED;
@property (weak) IBOutlet NSButton *dock_SEP;

@property (weak) IBOutlet NSSlider *cd_cornerRadius;

// Indicators
@property (weak) IBOutlet NSButton *cd_customIndicator;
@property (weak) IBOutlet NSButton *cd_indicatorBG;
@property (weak) IBOutlet NSButton *cd_sizeIndicator;
@property (weak) IBOutlet NSSlider *cd_indicatorWidth;
@property (weak) IBOutlet NSSlider *cd_indicatorHeight;
@property (weak) IBOutlet NSColorWell *indicatorWELL;

@property (weak) IBOutlet NSButton *dock_is3D;
@property (weak) IBOutlet NSButton *dock_pictureBackground;

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