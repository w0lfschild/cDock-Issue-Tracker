//
//  ViewController.m
//  cdPreferences
//
//  Created by Mustafa Gezen on 19.07.2015.
//  Copyright © 2015 Mustafa Gezen. All rights reserved.
//

#import "ViewController.h"
@import AppKit;

# define thmeName [[NSMutableDictionary dictionaryWithContentsOfFile:thmePath] objectForKey:@"cd_theme"]
# define pref____ [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/cDock/themes/"] stringByAppendingPathComponent:thmeName]
# define themfldr [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/cDock/themes/"]

# define thmePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/org.w0lf.cDock.plist"]
# define prefDock [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.apple.dock.plist"]
# define prefPath [[pref____ stringByAppendingPathComponent:thmeName ] stringByAppendingString:@".plist"]

BOOL timedelay = true;

void apply_WELL(NSMutableDictionary *prefs, NSString *well, NSColorWell *item) {
    [prefs setObject:[NSNumber numberWithFloat:item.color.redComponent * 255] forKey:[NSString stringWithFormat:@"cd_%@BGR", well]];
    [prefs setObject:[NSNumber numberWithFloat:item.color.greenComponent * 255] forKey:[NSString stringWithFormat:@"cd_%@BGG", well]];
    [prefs setObject:[NSNumber numberWithFloat:item.color.blueComponent * 255] forKey:[NSString stringWithFormat:@"cd_%@BGB", well]];
    [prefs setObject:[NSNumber numberWithFloat:item.color.alphaComponent * 100] forKey:[NSString stringWithFormat:@"cd_%@BGA", well]];
}

void theme_didChange(ViewController *t)
{
    [prefCD setObject:t.cd_theme.selectedItem.title forKey:@"cd_theme"];
    
    NSMutableDictionary *tmpPlist0 = prefCD;
    [tmpPlist0 writeToFile:thmePath atomically:YES];
}

NSString* runCommand(NSString * commandToRun)
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
//    NSLog(@"run command:%@", commandToRun);
    [task setArguments:arguments];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return output;
}

void apply_spacers(ViewController *t)
{
    prefd = [NSMutableDictionary dictionaryWithContentsOfFile:prefDock];
    
    if (t.dock_REC.state == NSOnState)
    {
        NSString *check = runCommand([NSString stringWithFormat:@"/usr/libexec/PlistBuddy -c \"Print persistent-others:\" \"%@\" | grep -a recents-tile | wc -l", prefDock]);
        if ([check containsString:@"0"])
        {
            NSMutableDictionary *subInfo = [[NSMutableDictionary alloc] init];
            [subInfo setValue:@"1" forKey:@"list-type"];
            
            NSMutableDictionary *recTile = [[NSMutableDictionary alloc] init];
            [recTile setValue:@"recents-tile" forKey:@"tile-type"];
            [recTile setValue:subInfo forKeyPath:@"tile-data"];
            
            NSMutableArray *arr = [prefd valueForKey:@"persistent-others"];
            [ arr addObject:recTile];
        }
    }
    else
    {
        NSMutableArray *arr = [prefd valueForKey:@"persistent-others"];
        for (int a = 0; a < arr.count; a++) {
            NSMutableDictionary *dic = [arr objectAtIndex:a];
            if ([[dic valueForKey:@"tile-type"] isEqualToString:@"recents-tile"])
            {
                [arr removeObjectAtIndex:a];
                break;
            }
        }
    }
    
    NSMutableDictionary *subInfo = [[NSMutableDictionary alloc] init];
    [subInfo setValue:@"" forKey:@"file-label"];
    
    NSMutableDictionary *spacerTile = [[NSMutableDictionary alloc] init];
    [spacerTile setValue:@"spacer-tile" forKey:@"tile-type"];
    [spacerTile setValue:subInfo forKeyPath:@"tile-data"];
    
    // App spacers
    int _acount = (int)[runCommand([NSString stringWithFormat:@"/usr/libexec/PlistBuddy -c \"Print persistent-apps:\" \"%@\" | grep -a \"spacer-tile\" | wc -l | tr -d ' '", prefDock]) integerValue];
    int _adjust = (int)t.dock_appSpacers.floatValue - _acount;
    if ( _adjust > 0 )
    {
        NSMutableArray *arr = [prefd valueForKey:@"persistent-apps"];
        for (int a = 0; a < _adjust ; a++)
            [ arr addObject:spacerTile ];
    }
    if ( _adjust < 0 )
    {
        NSMutableArray *arr = [prefd valueForKey:@"persistent-apps"];
        int _appCount = (int)arr.count;
        for (int a = _appCount - 1; a >= 0 ; a--)
        {
            if ( _adjust < 0 )
            {
                NSMutableDictionary *dic = [arr objectAtIndex:a];
                if ([[dic valueForKey:@"tile-type"] isEqualToString:@"spacer-tile"])
                {
                    [ arr removeObjectAtIndex:a ];
                    _adjust += 1;
                }
            }
        }
    }
    
    // Doc spacers
    _acount = (int)[runCommand([NSString stringWithFormat:@"/usr/libexec/PlistBuddy -c \"Print persistent-others:\" \"%@\" | grep -a \"spacer-tile\" | wc -l | tr -d ' '", prefDock]) integerValue];
    _adjust = (int)t.dock_docSpacers.floatValue - _acount;
    if ( _adjust > 0 )
    {
        NSMutableArray *arr = [prefd valueForKey:@"persistent-others"];
        for (int a = 0; a < _adjust ; a++)
            [ arr addObject:spacerTile ];
    }
    if ( _adjust < 0 )
    {
        NSMutableArray *arr = [prefd valueForKey:@"persistent-others"];
        int _appCount = (int)arr.count;
        for (int a = _appCount - 1; a >= 0 ; a--)
        {
            if ( _adjust < 0 )
            {
                NSMutableDictionary *dic = [arr objectAtIndex:a];
                if ([[dic valueForKey:@"tile-type"] isEqualToString:@"spacer-tile"])
                {
                    [ arr removeObjectAtIndex:a ];
                    _adjust += 1;
                }
            }
        }
    }
}

void apply_ALL(ViewController *t)
{
    if (timedelay)
    {
        timedelay = false;
        
        [prefd setObject:[NSNumber numberWithBool:[t.dock_SOAA state]] forKey:@"static-only"];
        [prefd setObject:[NSNumber numberWithBool:[t.dock_DHI state]] forKey:@"showhidden"];
        [prefd setObject:[NSNumber numberWithBool:[t.dock_LDC state]] forKey:@"contents-immutable"];
        [prefd setObject:[NSNumber numberWithBool:[t.dock_MOH state]] forKey:@"mouse-over-hilite-stack"];
        [prefd setObject:[NSNumber numberWithBool:[t.dock_SAM state]] forKey:@"single-app"];
        [prefd setObject:[NSNumber numberWithBool:[t.dock_NB state]] forKey:@"no-bouncing"];
        
        [prefd setObject:[NSNumber numberWithFloat:[t.dock_tilesize floatValue]] forKey:@"tilesize"];
        
        if (t.dock_magnification.floatValue == 0.0) {
            [prefd setObject:[NSNumber numberWithBool:false] forKey:@"magnification"];
            [prefd setObject:[NSNumber numberWithFloat:0] forKey:@"largesize"];
        }
        else
        {
            [prefd setObject:[NSNumber numberWithBool:true] forKey:@"magnification"];
            [prefd setObject:[NSNumber numberWithFloat:[t.dock_magnification floatValue]] forKey:@"largesize"];
        }
        
        if (t.dock_autohide.floatValue == 0.0) {
            [prefd setObject:[NSNumber numberWithBool:false] forKey:@"autohide"];
            [prefd setObject:[NSNumber numberWithFloat:3.0] forKey:@"autohide-time-modifier"];
        }
        else
        {
            [prefd setObject:[NSNumber numberWithBool:true] forKey:@"autohide"];
            [prefd setObject:[NSNumber numberWithFloat:3.0 - [t.dock_autohide floatValue]] forKey:@"autohide-time-modifier"];
        }
        
        NSMutableDictionary *tmpPlist1 = prefd;
        [tmpPlist1 writeToFile:prefDock atomically:YES];
        
        [pref setObject:[NSNumber numberWithInt:(int)t.cd_darkMode.indexOfSelectedItem] forKey:@"cd_darkMode"];
        
        [pref setObject:[NSNumber numberWithBool:[t.fullWidthDock state]] forKey:@"cd_fullWidth"];
        [pref setObject:[NSNumber numberWithBool:[t.hideLabels state]] forKey:@"cd_hideLabels"];
        
        [pref setObject:[NSNumber numberWithBool:[t.dockBG state]] forKey:@"cd_dockBG"];
        [pref setObject:[NSNumber numberWithBool:[t.labelBG state]] forKey:@"cd_labelBG"];
        
        [pref setObject:[NSNumber numberWithBool:[t.dock_is3D state]] forKey:@"cd_is3D"];
        [pref setObject:[NSNumber numberWithBool:[t.dock_pictureBackground state]] forKey:@"cd_pictureBG"];
        
        [pref setObject:[NSNumber numberWithBool:[t.cd_customIndicator state]] forKey:@"cd_customIndicator"];
        [pref setObject:[NSNumber numberWithBool:[t.cd_indicatorBG state]] forKey:@"cd_colorIndicator"];
        [pref setObject:[NSNumber numberWithBool:[t.shadowBG state]] forKey:@"cd_iconShadow"];
        
        [pref setObject:[NSNumber numberWithBool:[t.cd_iconReflection state]] forKey:@"cd_iconReflection"];
        [pref setObject:[NSNumber numberWithBool:[t.darken_OMO state]] forKey:@"cd_darkenMouseOver"];
        
        [pref setObject:[NSNumber numberWithBool:[t.stay_FROSTY state]] forKey:@"cd_showFrost"];
        [pref setObject:[NSNumber numberWithBool:[t.dock_SEP state]] forKey:@"cd_showSeparator"];
        [pref setObject:[NSNumber numberWithBool:[t.GLASSED state]] forKey:@"cd_showGlass"];
        
        apply_WELL(pref, @"dock", t.dockWELL);
        apply_WELL(pref, @"label", t.labelWELL);
        apply_WELL(pref, @"indicator", t.indicatorWELL);
        apply_WELL(pref, @"iconShadow", t.shadowWELL);
        apply_WELL(pref, @"border", t.borderWELL);
        
        [pref setObject:[NSNumber numberWithBool:[t.borderBG state]] forKey:@"cd_borderBG"];
        [pref setObject:[NSNumber numberWithInt:(int)[t.cd_borderSize floatValue]] forKey:@"cd_borderSize"];
        
        [pref setObject:[NSNumber numberWithInt:(int)[t.cd_cornerRadius floatValue]] forKey:@"cd_cornerRadius"];
        
        [pref setObject:[NSNumber numberWithBool:[t.cd_sizeIndicator state]] forKey:@"cd_sizeIndicator"];
        [pref setObject:[NSNumber numberWithInt:(int)[t.cd_indicatorHeight floatValue]] forKey:@"cd_indicatorHeight"];
        [pref setObject:[NSNumber numberWithInt:(int)[t.cd_indicatorWidth floatValue]] forKey:@"cd_indicatorWidth"];
        
        if (t.dock_pictureBackground.state == NSOnState) {
            [pref setObject:[NSNumber numberWithFloat:t.cd_backgroundAlpha.floatValue] forKey:@"cd_dockBGA"];
        }
        
        NSMutableDictionary *tmpPlist = pref;
        [tmpPlist writeToFile:prefPath atomically:YES];
        
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
    
        
        // Max dock refresh speed
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            timedelay = true;
        });
    }
}

@implementation ViewController

- (NSMutableDictionary *)_dockPrefs {
    return [NSMutableDictionary dictionaryWithContentsOfFile:prefDock];
}

- (NSMutableDictionary *)_cPrefs {
    return [NSMutableDictionary dictionaryWithContentsOfFile:prefPath];
}

- (NSMutableDictionary *)_cDPrefs {
    return [NSMutableDictionary dictionaryWithContentsOfFile:thmePath];
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
    
    

    
    // Dock settings
    NSMutableDictionary *plist1 = self._dockPrefs;
    prefd = plist1;
    
    [_dock_SOAA setState:[[prefd objectForKey:@"static-only"] integerValue]];
    [_dock_DHI setState:[[prefd objectForKey:@"showhidden"] integerValue]];
    [_dock_LDC setState:[[prefd objectForKey:@"contents-immutable"] integerValue]];
    [_dock_MOH setState:[[prefd objectForKey:@"mouse-over-hilite-stack"] integerValue]];
    [_dock_SAM setState:[[prefd objectForKey:@"single-app"] integerValue]];
    [_dock_NB setState:[[prefd objectForKey:@"no-bouncing"] integerValue]];
    
    [_dock_magnification setFloatValue:[[prefd objectForKey:@"largesize"] integerValue]];
    [_dock_tilesize setFloatValue:[[prefd objectForKey:@"tilesize"] integerValue]];
    [_dock_autohide setFloatValue:3.0 - [[prefd objectForKey:@"autohide-time-modifier"] floatValue]];
    
    NSString *run = [NSString stringWithFormat:@"/usr/libexec/PlistBuddy -c \"Print persistent-apps:\" \"%@\" | grep -a \"spacer-tile\" | wc -l | tr -d ' '", prefDock];
    NSString *app_spacer = runCommand(run);
    [_dock_appSpacers setFloatValue:[app_spacer integerValue]];
    
    run = [NSString stringWithFormat:@"/usr/libexec/PlistBuddy -c \"Print persistent-others:\" \"%@\" | grep -a \"spacer-tile\" | wc -l | tr -d ' '", prefDock];
    NSString *doc_spacer = runCommand(run);
    [_dock_docSpacers setFloatValue:[doc_spacer integerValue]];
    
    NSDictionary *parentDictionary = [plist1 objectForKey:@"persistent-others"];
    NSString *string = [NSString stringWithFormat:@"%@", parentDictionary];
    BOOL keyExists = false;
    if ([string rangeOfString:@"recents-tile"].location != NSNotFound)
        keyExists = true;
    
    [_dock_REC setState:@(keyExists).integerValue];
    
    
    
    
    // cDock settings
    NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:prefPath];
    pref = [plist mutableCopy];
    
    long darkMode = [[pref objectForKey:@"cd_darkMode"] integerValue];
    if (darkMode >= 0.0 && darkMode <= 3.0) {
        [_cd_darkMode selectItemAtIndex:(int)darkMode];
    }
    
    NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:themfldr error:Nil];
    [_cd_theme removeAllItems];
    [ _cd_theme addItemWithTitle:@"None" ];
    [ _cd_theme addItemsWithTitles:dirs ];
    [ _cd_theme removeItemWithTitle:@".DS_Store" ];
    
    NSMutableDictionary *plist0 = self._cDPrefs;
    prefCD = plist0;
    
    [ _cd_theme selectItemWithTitle:thmeName];
    
    [_cd_sizeIndicator setState:[[pref objectForKey:@"cd_sizeIndicator"] integerValue]];
    [_cd_indicatorHeight setFloatValue:[[pref objectForKey:@"cd_indicatorHeight"] integerValue]];
    [_cd_indicatorWidth setFloatValue:[[pref objectForKey:@"cd_indicatorWidth"] integerValue]];
    
    [_cd_customIndicator setState:[[pref objectForKey:@"cd_customIndicator"] integerValue]];
    [_dock_is3D setState:[[pref objectForKey:@"cd_is3D"] integerValue]];
    [_dock_pictureBackground setState:[[pref objectForKey:@"cd_pictureBG"] integerValue]];
    
    [_cd_iconReflection setState:[[pref objectForKey:@"cd_iconReflection"] integerValue]];
    [_darken_OMO setState:[[pref objectForKey:@"cd_darkenMouseOver"] integerValue]];
    [_stay_FROSTY setState:[[pref objectForKey:@"cd_showFrost"] integerValue]];
    [_GLASSED setState:[[pref objectForKey:@"cd_showGlass"] integerValue]];
    [_dock_SEP setState:[[pref objectForKey:@"cd_showSeparator"] integerValue]];
    
    [_fullWidthDock setState:[[pref objectForKey:@"cd_fullWidth"] integerValue]];
    [_hideLabels setState:[[pref objectForKey:@"cd_hideLabels"] integerValue]];
    
    [_shadowBG setState:[[pref objectForKey:@"cd_iconShadow"] integerValue]];
    [_shadowWELL setColor:[NSColor colorWithRed:[[pref objectForKey:@"cd_iconshadowBGR"] floatValue]/255.0 green:[[pref objectForKey:@"cd_iconShadowBGG"] floatValue]/255 blue:[[pref objectForKey:@"cd_iconShadowBGB"] floatValue]/255.0 alpha:[[pref objectForKey:@"cd_iconShadowBGA"] floatValue]/100.0]];
    
    [_cd_indicatorBG setState:[[pref objectForKey:@"cd_colorIndicator"] integerValue]];
    [_indicatorWELL setColor:[NSColor colorWithRed:[[pref objectForKey:@"cd_indicatorBGR"] floatValue]/255.0 green:[[pref objectForKey:@"cd_indicatorBGG"] floatValue]/255 blue:[[pref objectForKey:@"cd_indicatorBGB"] floatValue]/255.0 alpha:[[pref objectForKey:@"cd_indicatorBGA"] floatValue]/100.0]];
    
    [_dockBG setState:[[pref objectForKey:@"cd_dockBG"] integerValue]];
    [_dockWELL setColor:[NSColor colorWithRed:[[pref objectForKey:@"cd_dockBGR"] floatValue]/255.0 green:[[pref objectForKey:@"cd_dockBGG"] floatValue]/255 blue:[[pref objectForKey:@"cd_dockBGB"] floatValue]/255.0 alpha:[[pref objectForKey:@"cd_dockBGA"] floatValue]/100.0]];
    
    [_labelBG setState:[[pref objectForKey:@"cd_labelBG"] integerValue]];
    [_labelWELL setColor:[NSColor colorWithRed:[[pref objectForKey:@"cd_labelBGR"] floatValue]/255.0 green:[[pref objectForKey:@"cd_labelBGG"] floatValue]/255 blue:[[pref objectForKey:@"cd_labelBGB"] floatValue]/255.0 alpha:[[pref objectForKey:@"cd_labelBGA"] floatValue]/100.0]];
    
    [_cd_borderSize setFloatValue:[[pref objectForKey:@"cd_borderSize"] integerValue]];
    [_borderBG setState:[[pref objectForKey:@"cd_borderBG"] integerValue]];
    [_borderWELL setColor:[NSColor colorWithRed:[[pref objectForKey:@"cd_borderBGR"] floatValue]/255.0 green:[[pref objectForKey:@"cd_borderBGG"] floatValue]/255 blue:[[pref objectForKey:@"cd_borderBGB"] floatValue]/255.0 alpha:[[pref objectForKey:@"cd_borderBGA"] floatValue]/100.0]];
    
    [_cd_cornerRadius setFloatValue:[[pref objectForKey:@"cd_cornerRadius"] integerValue]];
    
    [_cd_backgroundAlpha setFloatValue:[[pref objectForKey:@"cd_dockBGA"] floatValue]];
    
    [_borderWELL setHidden:true];
    [_dockWELL setHidden:true];
    [_labelWELL setHidden:true];
    [_indicatorWELL setHidden:true];
    [_shadowWELL setHidden:true];
    
    if ([_borderBG state] == NSOnState)
        [_borderWELL setHidden:false];
    if ([_dockBG state] == NSOnState)
        [_dockWELL setHidden:false];
    if ([_labelBG state] == NSOnState)
        [_labelWELL setHidden:false];
    if ([_cd_indicatorBG state] == NSOnState)
        [_indicatorWELL setHidden:false];
    if ([_shadowBG state] == NSOnState)
        [_shadowWELL setHidden:false];
}

- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];
}

- (IBAction)_valuechangeApply:(id)sender {
    apply_ALL(self);
}

- (IBAction)change_theme:(id)sender {
    theme_didChange(self);
    self.viewDidLoad;
    apply_ALL(self);
}

- (IBAction)change3D:(id)sender {
    
    if ([sender state] == NSOnState) {
        
        [_stay_FROSTY setState:0];
        [_GLASSED setState:0];
        [_dockBG setState:0];
        [_dock_pictureBackground setState:1];
        [_dockWELL setHidden:true];
        
    }
    
    apply_ALL(self);
}

- (IBAction)changePictureBackground:(id)sender {
    
    if ([sender state] == NSOnState) {

        [_GLASSED setState:0];
        [_dockBG setState:0];
        [_dockWELL setHidden:true];
        
    }
    
    if ([sender state] == NSOffState) {
        [_dock_is3D setState:0];
    }
    
    apply_ALL(self);
}

- (IBAction)changeIndicatorBG:(id)sender {
    if ([sender state] == NSOnState) {
        [_indicatorWELL setHidden:false];
    } else if ([sender state] == NSOffState) {
        [_indicatorWELL setHidden:true];
    }
    apply_ALL(self);
}

- (IBAction)changeShadowBG:(id)sender {
    if ([sender state] == NSOnState) {
        [_shadowWELL setHidden:false];
    } else if ([sender state] == NSOffState) {
        [_shadowWELL setHidden:true];
    }
    apply_ALL(self);
}

- (IBAction)changeLabelBG:(id)sender {
	if ([sender state] == NSOnState) {
        [_labelWELL setHidden:false];
	} else if ([sender state] == NSOffState) {
        [_labelWELL setHidden:true];
	}
    apply_ALL(self);
}

- (IBAction)changeBorderBG:(id)sender {
    if ([sender state] == NSOnState) {
        [_borderWELL setHidden:false];
        if ([_cd_borderSize floatValue] < 1.0)
            [_cd_borderSize setFloatValue:1.0];
    } else if ([sender state] == NSOffState) {
        [_cd_borderSize setFloatValue:0.0];
        [_borderWELL setHidden:true];
    }
    apply_ALL(self);
}

- (IBAction)showPreferences:(id)sender {
    [ _tabView selectTabViewItemAtIndex:2 ];
}


- (IBAction)changeDockBG:(id)sender {
	if ([sender state] == NSOnState) {
        [_dockWELL setHidden:false];
	} else if ([sender state] == NSOffState) {
        [_dockWELL setHidden:true];
    }
    apply_ALL(self);
}

- (IBAction)applyPressed:(id)sender {
    timedelay = true;
    apply_spacers(self);
    apply_ALL(self);
    system("killall Dock; sleep 1; osascript -e 'tell application \"Dock\" to inject SIMBL into Snow Leopard'");
}

@end
