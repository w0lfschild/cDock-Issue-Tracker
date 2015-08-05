//
//  ViewController.m
//  cdPreferences
//
//  Created by Mustafa Gezen on 19.07.2015.
//  Copyright © 2015 Mustafa Gezen. All rights reserved.
//

#import "ViewController.h"

# define thmePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/org.w0lf.cDock.plist"]
# define thmeName [[NSMutableDictionary dictionaryWithContentsOfFile:thmePath] objectForKey:@"cd_theme"]
# define pref____ [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/cDock/themes/"] stringByAppendingPathComponent:thmeName]

# define prefDock [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.apple.dock.plist"]
# define prefPath [[pref____ stringByAppendingPathComponent:thmeName ] stringByAppendingString:@".plist"]

void isValidInt(NSTextField *item) {
    if ((![item integerValue] && [item integerValue] != 0) || [[item stringValue] length] > 3)
        [item setIntegerValue:255];
}


@implementation ViewController

- (NSMutableDictionary *)_dockPrefs {
    return [NSMutableDictionary dictionaryWithContentsOfFile:prefDock];
}

- (NSMutableDictionary *)_cPrefs {
    return [NSMutableDictionary dictionaryWithContentsOfFile:prefPath];
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    // cDock Preferences
	if (![[NSFileManager defaultManager] fileExistsAtPath:prefPath]) {
		NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
		
        [pref setObject:[NSNumber numberWithBool:false] forKey:@"cd_fullWidth"];
		[pref setObject:[NSNumber numberWithBool:false] forKey:@"cd_hideLabels"];
        [pref setObject:[NSNumber numberWithBool:false] forKey:@"cd_customIndicator"];
        [pref setObject:[NSNumber numberWithBool:false] forKey:@"cd_darkenMouseOver"];
        [pref setObject:[NSNumber numberWithBool:false] forKey:@"cd_iconReflection"];
        
        [pref setObject:[NSNumber numberWithBool:true] forKey:@"cd_showFrost"];
        [pref setObject:[NSNumber numberWithBool:true] forKey:@"cd_showGlass"];
        [pref setObject:[NSNumber numberWithBool:true] forKey:@"cd_showSeparator"];
		
        [pref setObject:[NSNumber numberWithBool:false] forKey:@"cd_iconShadow"];
        [pref setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_iconShadowBGS"];
        [pref setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_iconShadowBGR"];
        [pref setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_iconShadowBGG"];
        [pref setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_iconShadowBGB"];
        [pref setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_iconShadowBGA"];
        
        [pref setObject:[NSNumber numberWithBool:false] forKey:@"cd_dockBG"];
		[pref setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_dockBGR"];
		[pref setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_dockBGG"];
		[pref setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_dockBGB"];
        [pref setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_dockBGA"];
		
        [pref setObject:[NSNumber numberWithBool:false] forKey:@"cd_labelBG"];
		[pref setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_labelBGR"];
		[pref setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_labelBGG"];
		[pref setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_labelBGB"];
        [pref setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_labelBGA"];
		
        [newDict writeToFile:prefPath atomically:NO];
	}
	
    // Dock preferences
    if (![[NSFileManager defaultManager] fileExistsAtPath:prefDock]) {
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        [pref setObject:[NSNumber numberWithBool:false] forKey:@"static-only"];             // Show Only Active Applications
        [pref setObject:[NSNumber numberWithBool:false] forKey:@"showhidden"];              // Dim hidden items
        [pref setObject:[NSNumber numberWithBool:false] forKey:@"contents-immutable"];      // Lock dock contents
        [pref setObject:[NSNumber numberWithBool:false] forKey:@"largesize"];               // Maximum Magnification Level
        [pref setObject:[NSNumber numberWithBool:false] forKey:@"magnification"];           // Magnification enabled status
        [pref setObject:[NSNumber numberWithBool:false] forKey:@"mouse-over-hilite-stack"]; // Mouse over highlight
        [pref setObject:[NSNumber numberWithBool:false] forKey:@"single-app"];              // Single app mode
        [pref setObject:[NSNumber numberWithBool:false] forKey:@"no-bouncing"];             // App bounce for notifications
        [pref setObject:[NSNumber numberWithBool:false] forKey:@"autohide-delay"];          // Delay for dock hiding
        [pref setObject:[NSNumber numberWithBool:false] forKey:@"autohide-time-modifier"];  // Speed modifier for dock hiding
        [pref setObject:[NSNumber numberWithBool:false] forKey:@"autohide"];                // Autohide the dock
        
        // Mavericks only
        [prefd setObject:[NSNumber numberWithBool:false] forKey:@"pinning"];                 // Dock Position
        [prefd setObject:[NSNumber numberWithBool:false] forKey:@"use-new-list-stack"];      // Improved list view
        [newDict writeToFile:prefDock atomically:NO];
    }
    
    NSMutableDictionary *plist1 = self._dockPrefs;
    prefd = plist1;
    
    [_dock_SOAA setState:[[prefd objectForKey:@"static-only"] integerValue]];
    [_dock_DHI setState:[[prefd objectForKey:@"showhidden"] integerValue]];
    [_dock_LDC setState:[[prefd objectForKey:@"contents-immutable"] integerValue]];
//    [_dock_MML setState:[[prefd objectForKey:@"static-only"] integerValue]];
//    [_dock_MES setState:[[prefd objectForKey:@"static-only"] integerValue]];
    [_dock_MOH setState:[[prefd objectForKey:@"mouse-over-hilite-stack"] integerValue]];
    [_dock_SAM setState:[[prefd objectForKey:@"single-app"] integerValue]];
    [_dock_NB setState:[[prefd objectForKey:@"no-bouncing"] integerValue]];
//    [_dock_DHI setState:[[prefd objectForKey:@"autohide-delay"] integerValue]];
//    [_dock_DHI setState:[[prefd objectForKey:@"autohide-time-modifier"] integerValue]];
//    [_dock_DHI setState:[[prefd objectForKey:@"autohide"] integerValue]];
    
    NSDictionary *parentDictionary = [plist1 objectForKey:@"persistent-others"];
    NSString *string = [NSString stringWithFormat:@"%@", parentDictionary];
    BOOL keyExists = false;
    if ([string rangeOfString:@"recents-tile"].location != NSNotFound)
        keyExists = true;
    
    [_dock_REC setState:@(keyExists).integerValue];
    
	NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:prefPath];
	pref = [plist mutableCopy];
	
    [_darken_OMO setState:[[pref objectForKey:@"cd_darken_OMO"] integerValue]];
    [_stay_FROSTY setState:[[pref objectForKey:@"cd_showFrost"] integerValue]];
    [_GLASSED setState:[[pref objectForKey:@"cd_showGlass"] integerValue]];
    [_dock_SEP setState:[[pref objectForKey:@"cd_showSeparator"] integerValue]];
    
	[_fullWidthDock setState:[[pref objectForKey:@"cd_fullWidth"] integerValue]];
	[_hideLabels setState:[[pref objectForKey:@"cd_hideLabels"] integerValue]];
    
	[_changeDockBG setState:[[pref objectForKey:@"cd_dockBG"] integerValue]];
	[_dockBGR setFloatValue:[[pref objectForKey:@"cd_dockBGR"] floatValue]];
	[_dockBGG setFloatValue:[[pref objectForKey:@"cd_dockBGG"] floatValue]];
	[_dockBGB setFloatValue:[[pref objectForKey:@"cd_dockBGB"] floatValue]];
    [_dockBGA setFloatValue:[[pref objectForKey:@"cd_dockBGA"] floatValue]];
    
    [_dockWELL setColor:[NSColor colorWithRed:[[pref objectForKey:@"cd_dockBGR"] floatValue]/255.0 green:[[pref objectForKey:@"cd_dockBGG"] floatValue]/255 blue:[[pref objectForKey:@"cd_dockBGB"] floatValue]/255.0 alpha:1]];
    
    [_labelBG setState:[[pref objectForKey:@"cd_labelBG"] integerValue]];
    [_labelBGR setFloatValue:[[pref objectForKey:@"cd_labelBGR"] floatValue]];
	[_labelBGG setFloatValue:[[pref objectForKey:@"cd_labelBGG"] floatValue]];
	[_labelBGB setFloatValue:[[pref objectForKey:@"cd_labelBGB"] floatValue]];
    [_labelBGA setFloatValue:[[pref objectForKey:@"cd_labelBGA"] floatValue]];
    
    [_labelWELL setColor:[NSColor colorWithRed:[[pref objectForKey:@"cd_labelBGR"] floatValue]/255.0 green:[[pref objectForKey:@"cd_labelBGG"] floatValue]/255 blue:[[pref objectForKey:@"cd_labelBGB"] floatValue]/255.0 alpha:1]];
	
	if ([_changeDockBG state] == NSOnState) {
		[_dockBGR setHidden:false];
		[_dockBGG setHidden:false];
		[_dockBGB setHidden:false];
        [_dockBGA setHidden:false];
        [_dockWELL setHidden:false];
	}
	
	if ([_labelBG state] == NSOnState) {
		[_labelBGR setHidden:false];
		[_labelBGG setHidden:false];
		[_labelBGB setHidden:false];
        [_labelBGA setHidden:false];
        [_labelWELL setHidden:false];
	}
}

- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];
}

- (IBAction)changeDOCKColor:(id)sender {
    [_dockBGR setIntegerValue:_dockWELL.color.redComponent * 255 ];
    [_dockBGG setIntegerValue:_dockWELL.color.greenComponent * 255 ];
    [_dockBGB setIntegerValue:_dockWELL.color.blueComponent * 255 ];
//    [_dockBGA setHidden:false];
}

- (IBAction)changeLABELColor:(id)sender {
    [_labelBGR setIntegerValue:_labelWELL.color.redComponent * 255 ];
    [_labelBGG setIntegerValue:_labelWELL.color.greenComponent * 255 ];
    [_labelBGB setIntegerValue:_labelWELL.color.blueComponent * 255 ];
    //    [_labelBGA setHidden:false];
}

- (IBAction)changeSHADOWColor:(id)sender {
//    [_labelBGR setIntegerValue:_labelWELL.color.redComponent * 255 ];
//    [_labelBGG setIntegerValue:_labelWELL.color.greenComponent * 255 ];
//    [_labelBGB setIntegerValue:_labelWELL.color.blueComponent * 255 ];
    //    [_labelBGA setHidden:false];
}

- (IBAction)changeLabelBG:(id)sender {
	if ([sender state] == NSOnState) {
		[_labelBGR setHidden:false];
		[_labelBGG setHidden:false];
		[_labelBGB setHidden:false];
        [_labelBGA setHidden:false];
        [_labelWELL setHidden:false];
	} else if ([sender state] == NSOffState) {
		[_labelBGR setHidden:true];
		[_labelBGG setHidden:true];
		[_labelBGB setHidden:true];
        [_labelBGA setHidden:true];
        [_labelWELL setHidden:true];
	}
}

- (IBAction)changeDockBG:(id)sender {
	if ([sender state] == NSOnState) {
		[_dockBGR setHidden:false];
		[_dockBGG setHidden:false];
		[_dockBGB setHidden:false];
        [_dockBGA setHidden:false];
        [_dockWELL setHidden:false];
	} else if ([sender state] == NSOffState) {
		[_dockBGR setHidden:true];
		[_dockBGG setHidden:true];
		[_dockBGB setHidden:true];
        [_dockBGA setHidden:true];
        [_dockWELL setHidden:true];
    }
}

- (IBAction)applyPressed:(id)sender {
    prefd = self._dockPrefs;
    
    [prefd setObject:[NSNumber numberWithBool:[_dock_SOAA state]] forKey:@"static-only"];
    [prefd setObject:[NSNumber numberWithBool:[_dock_DHI state]] forKey:@"showhidden"];
    [prefd setObject:[NSNumber numberWithBool:[_dock_LDC state]] forKey:@"contents-immutable"];
    [prefd setObject:[NSNumber numberWithBool:[_dock_MOH state]] forKey:@"mouse-over-hilite-stack"];
    [prefd setObject:[NSNumber numberWithBool:[_dock_SAM state]] forKey:@"single-app"];
    [prefd setObject:[NSNumber numberWithBool:[_dock_NB state]] forKey:@"no-bouncing"];
    
    NSMutableDictionary *tmpPlist1 = prefd;
    [tmpPlist1 writeToFile:prefDock atomically:YES];

	[pref setObject:[NSNumber numberWithBool:[_fullWidthDock state]] forKey:@"cd_fullWidth"];
	[pref setObject:[NSNumber numberWithBool:[_hideLabels state]] forKey:@"cd_hideLabels"];
	[pref setObject:[NSNumber numberWithBool:[_changeDockBG state]] forKey:@"cd_dockBG"];
	[pref setObject:[NSNumber numberWithBool:[_labelBG state]] forKey:@"cd_labelBG"];
    [pref setObject:[NSNumber numberWithBool:[_darken_OMO state]] forKey:@"cd_darken_OMO"];
    [pref setObject:[NSNumber numberWithBool:[_stay_FROSTY state]] forKey:@"cd_showFrost"];
    [pref setObject:[NSNumber numberWithBool:[_dock_SEP state]] forKey:@"cd_showSeparator"];
    [pref setObject:[NSNumber numberWithBool:[_GLASSED state]] forKey:@"cd_showGlass"];
    
    isValidInt(_dockBGR);
    
//	if ((![_dockBGR integerValue] && [_dockBGR integerValue] != 0) || [[_dockBGR stringValue] length] > 3)
//		[_dockBGR setIntegerValue:255];
	
	if ((![_dockBGG integerValue] && [_dockBGG integerValue] != 0) || [[_dockBGG stringValue] length] > 3)
		[_dockBGG setIntegerValue:255];
	
	if ((![_dockBGB integerValue] && [_dockBGB integerValue] != 0) || [[_dockBGB stringValue] length] > 3)
		[_dockBGB setIntegerValue:255];
    
    if ((![_dockBGA integerValue] && [_dockBGA integerValue] != 0) || [[_dockBGA stringValue] length] > 3)
        [_dockBGB setIntegerValue:100];
	
	if ((![_labelBGR integerValue] && [_labelBGR integerValue] != 0) || [[_labelBGR stringValue] length] > 3)
		[_labelBGR setIntegerValue:255];
	
	if ((![_labelBGG integerValue] && [_labelBGG integerValue] != 0) || [[_labelBGG stringValue] length] > 3)
		[_labelBGG setIntegerValue:255];
	
	if ((![_labelBGB integerValue] && [_labelBGB integerValue] != 0) || [[_labelBGB stringValue] length] > 3)
		[_labelBGB setIntegerValue:255];
    
    if ((![_labelBGA integerValue] && [_labelBGA integerValue] != 0) || [[_labelBGA stringValue] length] > 3)
        [_labelBGA setIntegerValue:100];
	
	[pref setObject:[NSNumber numberWithFloat:[_dockBGR floatValue]] forKey:@"cd_dockBGR"];
	[pref setObject:[NSNumber numberWithFloat:[_dockBGG floatValue]] forKey:@"cd_dockBGG"];
	[pref setObject:[NSNumber numberWithFloat:[_dockBGB floatValue]] forKey:@"cd_dockBGB"];
    [pref setObject:[NSNumber numberWithFloat:[_dockBGA floatValue]] forKey:@"cd_dockBGA"];
	
	[pref setObject:[NSNumber numberWithFloat:[_labelBGR floatValue]] forKey:@"cd_labelBGR"];
	[pref setObject:[NSNumber numberWithFloat:[_labelBGG floatValue]] forKey:@"cd_labelBGG"];
	[pref setObject:[NSNumber numberWithFloat:[_labelBGB floatValue]] forKey:@"cd_labelBGB"];
    [pref setObject:[NSNumber numberWithFloat:[_labelBGA floatValue]] forKey:@"cd_labelBGA"];
	
	NSMutableDictionary *tmpPlist = pref;
	[tmpPlist writeToFile:prefPath atomically:YES];
	system("killall Dock; sleep 1; osascript -e 'tell application \"Dock\" to inject SIMBL into Snow Leopard'");
}

@end
