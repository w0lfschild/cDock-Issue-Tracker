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

void apply_WELL(NSMutableDictionary *prefs, NSString *well, NSColorWell *item) {
    [prefs setObject:[NSNumber numberWithFloat:item.color.redComponent * 255] forKey:[NSString stringWithFormat:@"cd_%@BGR", well]];
    [prefs setObject:[NSNumber numberWithFloat:item.color.greenComponent * 255] forKey:[NSString stringWithFormat:@"cd_%@BGG", well]];
    [prefs setObject:[NSNumber numberWithFloat:item.color.blueComponent * 255] forKey:[NSString stringWithFormat:@"cd_%@BGB", well]];
    [prefs setObject:[NSNumber numberWithFloat:item.color.alphaComponent * 100] forKey:[NSString stringWithFormat:@"cd_%@BGA", well]];
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
    
    [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
    
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
        
        [pref setObject:[NSNumber numberWithBool:false] forKey:@"cd_colorIndicator"];
        [pref setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_indicatorBGR"];
        [pref setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_indicatorBGG"];
        [pref setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_indicatorBGB"];
        [pref setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_indicatorBGA"];
        
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
    [_dock_MOH setState:[[prefd objectForKey:@"mouse-over-hilite-stack"] integerValue]];
    [_dock_SAM setState:[[prefd objectForKey:@"single-app"] integerValue]];
    [_dock_NB setState:[[prefd objectForKey:@"no-bouncing"] integerValue]];
    
    NSDictionary *parentDictionary = [plist1 objectForKey:@"persistent-others"];
    NSString *string = [NSString stringWithFormat:@"%@", parentDictionary];
    BOOL keyExists = false;
    if ([string rangeOfString:@"recents-tile"].location != NSNotFound)
        keyExists = true;
    
    [_dock_REC setState:@(keyExists).integerValue];
    
	NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:prefPath];
	pref = [plist mutableCopy];
	
    [_dockIconReflections setState:[[pref objectForKey:@"cd_iconReflection"] integerValue]];
    [_darken_OMO setState:[[pref objectForKey:@"cd_darkenMouseOver"] integerValue]];
    [_stay_FROSTY setState:[[pref objectForKey:@"cd_showFrost"] integerValue]];
    [_GLASSED setState:[[pref objectForKey:@"cd_showGlass"] integerValue]];
    [_dock_SEP setState:[[pref objectForKey:@"cd_showSeparator"] integerValue]];
    
	[_fullWidthDock setState:[[pref objectForKey:@"cd_fullWidth"] integerValue]];
	[_hideLabels setState:[[pref objectForKey:@"cd_hideLabels"] integerValue]];
    
    [_shadowBG setState:[[pref objectForKey:@"cd_iconShadow"] integerValue]];
    [_shadowWELL setColor:[NSColor colorWithRed:[[pref objectForKey:@"cd_shadowBGR"] floatValue]/255.0 green:[[pref objectForKey:@"cd_shadowBGG"] floatValue]/255 blue:[[pref objectForKey:@"cd_shadowBGB"] floatValue]/255.0 alpha:[[pref objectForKey:@"cd_shadowBGA"] floatValue]/100.0]];
    
    [_indicatorBG setState:[[pref objectForKey:@"cd_colorIndicator"] integerValue]];
    [_indicatorWELL setColor:[NSColor colorWithRed:[[pref objectForKey:@"cd_indicatorBGR"] floatValue]/255.0 green:[[pref objectForKey:@"cd_indicatorBGG"] floatValue]/255 blue:[[pref objectForKey:@"cd_indicatorBGB"] floatValue]/255.0 alpha:[[pref objectForKey:@"cd_indicatorBGA"] floatValue]/100.0]];
    
	[_dockBG setState:[[pref objectForKey:@"cd_dockBG"] integerValue]];
    [_dockWELL setColor:[NSColor colorWithRed:[[pref objectForKey:@"cd_dockBGR"] floatValue]/255.0 green:[[pref objectForKey:@"cd_dockBGG"] floatValue]/255 blue:[[pref objectForKey:@"cd_dockBGB"] floatValue]/255.0 alpha:[[pref objectForKey:@"cd_dockBGA"] floatValue]/100.0]];
    
    [_labelBG setState:[[pref objectForKey:@"cd_labelBG"] integerValue]];
    [_labelWELL setColor:[NSColor colorWithRed:[[pref objectForKey:@"cd_labelBGR"] floatValue]/255.0 green:[[pref objectForKey:@"cd_labelBGG"] floatValue]/255 blue:[[pref objectForKey:@"cd_labelBGB"] floatValue]/255.0 alpha:[[pref objectForKey:@"cd_labelBGA"] floatValue]/100.0]];
	
	if ([_dockBG state] == NSOnState)
        [_dockWELL setHidden:false];
	if ([_labelBG state] == NSOnState)
        [_labelWELL setHidden:false];
    if ([_indicatorBG state] == NSOnState)
        [_indicatorWELL setHidden:false];
    if ([_shadowBG state] == NSOnState)
        [_shadowWELL setHidden:false];
}

- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];
}

- (IBAction)changeIndicatorBG:(id)sender {
    if ([sender state] == NSOnState) {
        [_indicatorWELL setHidden:false];
    } else if ([sender state] == NSOffState) {
        [_indicatorWELL setHidden:true];
    }
}

- (IBAction)changeShadowBG:(id)sender {
    if ([sender state] == NSOnState) {
        [_shadowWELL setHidden:false];
    } else if ([sender state] == NSOffState) {
        [_shadowWELL setHidden:true];
    }
}

- (IBAction)changeLabelBG:(id)sender {
	if ([sender state] == NSOnState) {
        [_labelWELL setHidden:false];
	} else if ([sender state] == NSOffState) {
        [_labelWELL setHidden:true];
	}
}

- (IBAction)changeDockBG:(id)sender {
	if ([sender state] == NSOnState) {
        [_dockWELL setHidden:false];
	} else if ([sender state] == NSOffState) {
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
    
	[pref setObject:[NSNumber numberWithBool:[_dockBG state]] forKey:@"cd_dockBG"];
	[pref setObject:[NSNumber numberWithBool:[_labelBG state]] forKey:@"cd_labelBG"];
    [pref setObject:[NSNumber numberWithBool:[_indicatorBG state]] forKey:@"cd_colorIndicator"];
    [pref setObject:[NSNumber numberWithBool:[_shadowBG state]] forKey:@"cd_iconShadow"];
    
    [pref setObject:[NSNumber numberWithBool:[_dockIconReflections state]] forKey:@"cd_iconReflection"];
    [pref setObject:[NSNumber numberWithBool:[_darken_OMO state]] forKey:@"cd_darkenMouseOver"];
    
    [pref setObject:[NSNumber numberWithBool:[_stay_FROSTY state]] forKey:@"cd_showFrost"];
    [pref setObject:[NSNumber numberWithBool:[_dock_SEP state]] forKey:@"cd_showSeparator"];
    [pref setObject:[NSNumber numberWithBool:[_GLASSED state]] forKey:@"cd_showGlass"];
    
    apply_WELL(pref, @"dock", _dockWELL);
    apply_WELL(pref, @"label", _labelWELL);
    apply_WELL(pref, @"indicator", _indicatorWELL);
    apply_WELL(pref, @"shadow", _shadowWELL);
    
	NSMutableDictionary *tmpPlist = pref;
	[tmpPlist writeToFile:prefPath atomically:YES];
	system("killall Dock; sleep 1; osascript -e 'tell application \"Dock\" to inject SIMBL into Snow Leopard'");
}

@end
