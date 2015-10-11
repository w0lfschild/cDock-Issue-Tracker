//
//  AppDelegate.m
//  cDock GUI
//
//  Created by Wolfgang Baird on 09.09.2015.
//  Copyright © 2015 Wolfgang Baird. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@end

BOOL timedelay = true;
BOOL showTooltips = false;
BOOL enableTheming = true;
NSDate *methodStart;

NSString* runCommand(NSString * commandToRun) {
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

@implementation AppDelegate

- (void)dockNotification:(CFMutableDictionaryRef)dict {
    CFNotificationCenterRef center = CFNotificationCenterGetDistributedCenter(); //CFNotificationCenterGetLocalCenter();
    CFNotificationCenterPostNotification(center, CFSTR("MyNotification"), NULL, dict, TRUE);
    CFRelease(dict);
}

- (void)apply_WELL:(NSString *)well withWELL:(NSColorWell *)item {
    [pref setObject:[NSNumber numberWithFloat:item.color.redComponent * 255] forKey:[NSString stringWithFormat:@"cd_%@BGR", well]];
    [pref setObject:[NSNumber numberWithFloat:item.color.greenComponent * 255] forKey:[NSString stringWithFormat:@"cd_%@BGG", well]];
    [pref setObject:[NSNumber numberWithFloat:item.color.blueComponent * 255] forKey:[NSString stringWithFormat:@"cd_%@BGB", well]];
    [pref setObject:[NSNumber numberWithFloat:item.color.alphaComponent * 100] forKey:[NSString stringWithFormat:@"cd_%@BGA", well]];
}

- (void)addLoginItem {
    dispatch_queue_t myQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(myQueue, ^{
        NSMutableDictionary *SIMBLPrefs = [NSMutableDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/net.culater.SIMBL_Agent.plist"]];
        [SIMBLPrefs setObject:[NSArray arrayWithObjects:@"com.skype.skype", @"com.FilterForge.FilterForge4", @"com.apple.logic10", nil] forKey:@"SIMBLApplicationIdentifierBlacklist"];
        [SIMBLPrefs writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/net.culater.SIMBL_Agent.plist"] atomically:YES];
        
        // Lets stick to the classics. Same method as cDock uses...
        NSString *nullString;
        NSString *loginAgent = [[NSBundle mainBundle] pathForResource:@"cDock-Agent" ofType:@"app"];
        nullString = runCommand(@"osascript -e \"tell application \\\"System Events\\\" to delete login items \\\"cDock-Agent\\\"\"");
        NSString *addAgent = [NSString stringWithFormat:@"osascript -e \"tell application \\\"System Events\\\" to make new login item at end of login items with properties {path:\\\"%@\\\", hidden:false}\"", loginAgent];
        nullString = runCommand(addAgent);
    });
}

- (void)dirCheck:(NSString *)directory {
    BOOL isDir;
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:directory isDirectory:&isDir])
        if(![fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL])
            NSLog(@"Error: Create folder failed %@", directory);
}

- (void)launch_helper {
//    int my_pid = [[NSProcessInfo processInfo] processIdentifier];
//    NSLog(@"%d _swag", my_pid);
    NSString *nullString = [NSString stringWithFormat:@"for item in $(ps aux | grep [c]Dock..gent | tr -s ' ' | cut -d ' ' -f 2); do echo $item; done"];
    nullString = runCommand(nullString);
    NSArray *myWords = [nullString componentsSeparatedByString:@"\n"];
    for (NSNumber *anid in myWords)
    {
        NSString *killer = [NSString stringWithFormat:@"kill %@", anid];
        if (![killer isEqualToString:@"kill "])
            runCommand(killer);
    }
    //system('for item in $(ps aux | grep "cDock" | tr -s ' ' | cut -d ' ' -f 2); do kill "$item"; done')
    NSString *path = [[NSBundle mainBundle] pathForResource:@"cDock-Agent" ofType:@"app"];
    [[NSWorkspace sharedWorkspace] launchApplication:path];
}

- (IBAction)applyDockChanges:(id)sender {
    prefd = [self _getDockPlist];
    
    // Recents tile
    if (_dock_REC.state == NSOnState)
    {
        NSString *find = @"recents-tile";
        NSString *text = [NSString stringWithFormat:@"%@", [prefd objectForKey:@"persistent-others"]];
        NSInteger strCount = [text length] - [[text stringByReplacingOccurrencesOfString:find withString:@""] length];
        strCount /= [find length];
        
        if (strCount == 0)
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
    
    
    NSString *find = @"spacer-tile";
    NSString *text = [NSString stringWithFormat:@"%@", [prefd objectForKey:@"persistent-apps"]];
    NSInteger strCount = [text length] - [[text stringByReplacingOccurrencesOfString:find withString:@""] length];
    strCount /= [find length];
    
    // App spacers
    NSInteger _adjust = (int)_dock_appSpacers.floatValue - strCount;
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
    
    text = [NSString stringWithFormat:@"%@", [prefd objectForKey:@"persistent-others"]];
    strCount = [text length] - [[text stringByReplacingOccurrencesOfString:find withString:@""] length];
    strCount /= [find length];
    
    // Doc spacers
    _adjust = (int)_dock_docSpacers.floatValue - strCount;
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
    
    [prefd setObject:[NSNumber numberWithBool:[_dock_SOAA state]] forKey:@"static-only"];
    [prefd setObject:[NSNumber numberWithBool:[_dock_DHI state]] forKey:@"showhidden"];
    [prefd setObject:[NSNumber numberWithBool:[_dock_LDC state]] forKey:@"contents-immutable"];
    [prefd setObject:[NSNumber numberWithBool:[_dock_MOH state]] forKey:@"mouse-over-hilite-stack"];
    [prefd setObject:[NSNumber numberWithBool:[_dock_SAM state]] forKey:@"single-app"];
    
    [prefd setObject:[NSNumber numberWithBool:[_dock_NB state]] forKey:@"no-bouncing"];
    [prefd setObject:[NSNumber numberWithBool:(1 - [_dock_NB state])] forKey:@"launchanim"];
    
    [prefd setObject:[NSNumber numberWithFloat:[_dock_tilesize floatValue]] forKey:@"tilesize"];
    
    if (_dock_magnification.floatValue == 0.0) {
        [prefd setObject:[NSNumber numberWithBool:false] forKey:@"magnification"];
        [prefd setObject:[NSNumber numberWithFloat:0] forKey:@"largesize"];
    }
    else
    {
        [prefd setObject:[NSNumber numberWithBool:true] forKey:@"magnification"];
        [prefd setObject:[NSNumber numberWithFloat:[_dock_magnification floatValue]] forKey:@"largesize"];
    }
    
    if (_dock_autohide.floatValue == 0.0) {
        [prefd setObject:[NSNumber numberWithBool:false] forKey:@"autohide"];
        [prefd setObject:[NSNumber numberWithFloat:3.0] forKey:@"autohide-time-modifier"];
    }
    else
    {
        [prefd setObject:[NSNumber numberWithBool:true] forKey:@"autohide"];
        [prefd setObject:[NSNumber numberWithFloat:3.0 - [_dock_autohide floatValue]] forKey:@"autohide-time-modifier"];
    }
    
    [prefd writeToFile:@"/tmp/dock.plist" atomically:YES];
    system("defaults import com.apple.dock /tmp/dock.plist");
    system("killall Dock; sleep 2; osascript -e 'tell application \"Dock\" to inject SIMBL into Snow Leopard'");

}

- (IBAction)applyChanges:(id)sender {
    if (timedelay)
    {
        timedelay = false;
        
        if (![prefCD valueForKey:@"cd_enabled"])
        {
            if (enableTheming)
            {
                [prefCD setObject:[NSNumber numberWithBool:true] forKey:@"cd_enabled"];
                NSMutableDictionary *tmp = prefCD;
                [tmp writeToFile:plist_cDock atomically:YES];
            } else {
                enableTheming = true;
            }
        }
        
        pref = self._getThemePlist;
        
        [pref setObject:[NSNumber numberWithInt:(int)_cd_darkMode.indexOfSelectedItem] forKey:@"cd_darkMode"];
        
        [pref setObject:[NSNumber numberWithBool:[_cd_fullWidth state]] forKey:@"cd_fullWidth"];
        [pref setObject:[NSNumber numberWithBool:[_cd_hideLabels state]] forKey:@"cd_hideLabels"];
        
        [pref setObject:[NSNumber numberWithBool:[_dockBG state]] forKey:@"cd_dockBG"];
        [pref setObject:[NSNumber numberWithBool:[_labelBG state]] forKey:@"cd_labelBG"];
        
        [pref setObject:[NSNumber numberWithBool:[_cd_is3D state]] forKey:@"cd_is3D"];
        [pref setObject:[NSNumber numberWithBool:[_cd_pictureBackground state]] forKey:@"cd_pictureBG"];
        
        [pref setObject:[NSNumber numberWithBool:[_cd_customIndicator state]] forKey:@"cd_customIndicator"];
        [pref setObject:[NSNumber numberWithBool:[_cd_indicatorBG state]] forKey:@"cd_colorIndicator"];
        [pref setObject:[NSNumber numberWithBool:[_shadowBG state]] forKey:@"cd_iconShadow"];
        [pref setObject:[NSNumber numberWithInt:10] forKey:@"cd_iconShadowBGS"];
        
        [pref setObject:[NSNumber numberWithBool:[_cd_iconReflection state]] forKey:@"cd_iconReflection"];
        [pref setObject:[NSNumber numberWithBool:[_cd_darkenMouseOver state]] forKey:@"cd_darkenMouseOver"];
        
        [pref setObject:[NSNumber numberWithBool:[_cd_showFrost state]] forKey:@"cd_showFrost"];
        [pref setObject:[NSNumber numberWithBool:[_cd_showSeparator state]] forKey:@"cd_showSeparator"];
        [pref setObject:[NSNumber numberWithBool:[_cd_showGlass state]] forKey:@"cd_showGlass"];
        
        [self apply_WELL:@"dock" withWELL:_dockWELL];
        [self apply_WELL:@"label" withWELL:_labelWELL];
        [self apply_WELL:@"indicator" withWELL:_indicatorWELL];
        [self apply_WELL:@"iconShadow" withWELL:_shadowWELL];
        [self apply_WELL:@"border" withWELL:_borderWELL];
        [self apply_WELL:@"separator" withWELL:_separatorWELL];
        
        [pref setObject:[NSNumber numberWithBool:[_separatorBG state]] forKey:@"cd_separatorBG"];
        
        [pref setObject:[NSNumber numberWithBool:[_borderBG state]] forKey:@"cd_borderBG"];
        [pref setObject:[NSNumber numberWithInt:(int)[_cd_borderSize floatValue]] forKey:@"cd_borderSize"];
        
        [pref setObject:[NSNumber numberWithInt:(int)[_cd_cornerRadius floatValue]] forKey:@"cd_cornerRadius"];
        
        [pref setObject:[NSNumber numberWithBool:[_cd_sizeIndicator state]] forKey:@"cd_sizeIndicator"];
        [pref setObject:[NSNumber numberWithInt:(int)[_cd_indicatorHeight floatValue]] forKey:@"cd_indicatorHeight"];
        [pref setObject:[NSNumber numberWithInt:(int)[_cd_indicatorWidth floatValue]] forKey:@"cd_indicatorWidth"];
        
        if (_cd_pictureBackground.state == NSOnState) {
            [pref setObject:[NSNumber numberWithFloat:_cd_backgroundAlpha.floatValue] forKey:@"cd_dockBGA"];
        }
        
        NSMutableDictionary *tmpPlist = pref;
        [tmpPlist writeToFile:plist_Theme atomically:YES];
        
        CFDictionaryKeyCallBacks keyCallbacks = {0, NULL, NULL, CFCopyDescription, CFEqual, NULL};
        CFDictionaryValueCallBacks valueCallbacks  = {0, NULL, NULL, CFCopyDescription, CFEqual};
        CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 1,
                                                                      &keyCallbacks, &valueCallbacks);
        
        CFDictionaryAddValue(dictionary, CFSTR("dock"), CFSTR("1"));
        
        if (_shadowBG.state == NSOnState || _cd_iconReflection.state == NSOnState || _cd_indicatorBG.state == NSOnState || _cd_sizeIndicator.state == NSOnState)
        {
            CFDictionaryAddValue(dictionary, CFSTR("shadow"), CFSTR("1"));
        }
        
        if (_cd_indicatorBG.state == NSOnState || _cd_sizeIndicator.state == NSOnState)
        {
            CFDictionaryAddValue(dictionary, CFSTR("indicators"), CFSTR("1"));
        }
        
        [self dockNotification:dictionary];
        
        // Max dock refresh speed
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.025 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            timedelay = true;
        });
    }
}

- (void)checkUpdates:(NSInteger)autoInstall {
    dispatch_queue_t myQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(myQueue, ^{
        // Insert code to be executed on another thread here
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"updates/wUpdater.app/Contents/MacOS/wUpdater" ofType:@""];
        NSString *relURL = runCommand(@"curl -s https://api.github.com/repos/w0lfschild/cDock2/releases/latest | grep 'browser_' | cut -d\\\" -f4");
        if ([relURL isEqualToString:@""])
        {
            // Default release if we get nil from the above
            relURL = @"https://raw.githubusercontent.com/w0lfschild/cDock2/master/release/release.zip";
        }
        NSLog(@"%@", relURL);
        relURL = [relURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSArray *args = [NSArray arrayWithObjects:@"c", [[NSBundle mainBundle] bundlePath], @"org.w0lf.cDock-GUI",
                         [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]],
                         @"https://raw.githubusercontent.com/w0lfschild/cDock2/master/release/version.txt",
                         @"https://raw.githubusercontent.com/w0lfschild/cDock2/master/release/versionInfo.txt",
                         relURL,
                         [NSString stringWithFormat:@"%d", (int)autoInstall], nil];
        
        [NSTask launchedTaskWithLaunchPath:path arguments:args];
        NSLog(@"Checking for updates...");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Insert code to be executed on the main thread here
        });
    });
}

- (void)setupTheme {
    // cDock Theme Preferences
    if (![[NSFileManager defaultManager] fileExistsAtPath:plist_Theme]) {
        pref = [[NSMutableDictionary alloc] init];
        
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
        
        NSMutableDictionary *tmpPlist = pref;
        [tmpPlist writeToFile:plist_Theme atomically:YES];
    }
    
    // cDock Application Preferences
    if (![[NSFileManager defaultManager] fileExistsAtPath:plist_cDock]) {
        prefCD = [[NSMutableDictionary alloc] init];
        
        [prefCD setObject:@"None" forKey:@"cd_theme"];
        [prefCD setObject:[NSNumber numberWithBool:false] forKey:@"cd_enabled"];
        [prefCD setObject:[NSNumber numberWithBool:true] forKey:@"autoCheck"];
        [prefCD setObject:[NSNumber numberWithBool:false] forKey:@"autoInstall"];
        
        NSMutableDictionary *tmpPlist = prefCD;
        [tmpPlist writeToFile:plist_cDock atomically:YES];
    }
    
    
    // Dock settings
    prefd = [self _getDockPlist];
    
    [_dock_SOAA setState:[[prefd objectForKey:@"static-only"] integerValue]];
    [_dock_DHI setState:[[prefd objectForKey:@"showhidden"] integerValue]];
    [_dock_LDC setState:[[prefd objectForKey:@"contents-immutable"] integerValue]];
    [_dock_MOH setState:[[prefd objectForKey:@"mouse-over-hilite-stack"] integerValue]];
    [_dock_SAM setState:[[prefd objectForKey:@"single-app"] integerValue]];
    [_dock_NB setState:[[prefd objectForKey:@"no-bouncing"] integerValue]];
    [_dock_magnification setFloatValue:[[prefd objectForKey:@"largesize"] integerValue]];
    [_dock_tilesize setFloatValue:[[prefd objectForKey:@"tilesize"] integerValue]];
    
    if ([prefd objectForKey:@"autohide-time-modifier"])
        [_dock_autohide setFloatValue:3.0 - [[prefd objectForKey:@"autohide-time-modifier"] floatValue]];
    
    NSString *find = @"spacer-tile";
    
    NSString *text = [NSString stringWithFormat:@"%@", [prefd objectForKey:@"persistent-apps"]];
    NSInteger strCount = [text length] - [[text stringByReplacingOccurrencesOfString:find withString:@""] length];
    strCount /= [find length];
    [_dock_appSpacers setFloatValue:strCount];
    
    text = [NSString stringWithFormat:@"%@", [prefd objectForKey:@"persistent-others"]];
    strCount = [text length] - [[text stringByReplacingOccurrencesOfString:find withString:@""] length];
    strCount /= [find length];
    [_dock_docSpacers setFloatValue:strCount];
    
    NSDictionary *parentDictionary = [prefd objectForKey:@"persistent-others"];
    NSString *string = [NSString stringWithFormat:@"%@", parentDictionary];
    BOOL keyExists = false;
    if ([string rangeOfString:@"recents-tile"].location != NSNotFound)
        keyExists = true;
    
    [_dock_REC setState:@(keyExists).integerValue];
    
    // cDock settings
    NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:plist_Theme];
    pref = [plist mutableCopy];
    
    long darkMode = [[pref objectForKey:@"cd_darkMode"] integerValue];
    if (darkMode >= 0.0 && darkMode <= 3.0) {
        [_cd_darkMode selectItemAtIndex:(int)darkMode];
    }
    
    NSMutableArray* dirs = [[NSMutableArray alloc] init];
    [dirs addObjectsFromArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:themeFldr error:Nil]];
    
    if ([dirs containsObject:@".DS_Store"]) {
        [dirs removeObject:@".DS_Store"];
    }
    
    [_cd_theme removeAllItems];
    [_cd_theme addItemWithTitle:@"None" ];
    [_cd_theme addItemsWithTitles:dirs ];
    
    NSMutableDictionary *plist0 = [self _getcDockPlist];
    prefCD = plist0;
    
    [ _cdock_isVibrant setState:[[prefCD objectForKey:@"blurView"] integerValue]];
    if ([[NSProcessInfo processInfo] operatingSystemVersion].minorVersion < 10)
        [_cdock_isVibrant setEnabled:false];
    
    [ _auto_checkUpdates setState:[[prefCD objectForKey:@"autoCheck"] integerValue]];
    [ _auto_installUpdates setState:[[prefCD objectForKey:@"autoInstall"] integerValue]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:plist_Theme])
    {
        //        NSLog(@"Exists: %@", plist_Theme);
        [ _cd_theme selectItemWithTitle:themeName];
    }
    else
    {
        //        NSLog(@"Not Found: %@", plist_Theme);
        [ _cd_theme selectItemWithTitle:@"None"];
    }
    
    [_cd_sizeIndicator setState:[[pref objectForKey:@"cd_sizeIndicator"] integerValue]];
    [_cd_indicatorHeight setFloatValue:[[pref objectForKey:@"cd_indicatorHeight"] integerValue]];
    [_cd_indicatorWidth setFloatValue:[[pref objectForKey:@"cd_indicatorWidth"] integerValue]];
    
    [_cd_customIndicator setState:[[pref objectForKey:@"cd_customIndicator"] integerValue]];
    [_cd_is3D setState:[[pref objectForKey:@"cd_is3D"] integerValue]];
    [_cd_pictureBackground setState:[[pref objectForKey:@"cd_pictureBG"] integerValue]];
    
    [_cd_iconReflection setState:[[pref objectForKey:@"cd_iconReflection"] integerValue]];
    [_cd_darkenMouseOver setState:[[pref objectForKey:@"cd_darkenMouseOver"] integerValue]];
    [_cd_showFrost setState:[[pref objectForKey:@"cd_showFrost"] integerValue]];
    [_cd_showGlass setState:[[pref objectForKey:@"cd_showGlass"] integerValue]];
    [_cd_showSeparator setState:[[pref objectForKey:@"cd_showSeparator"] integerValue]];
    
    [_cd_fullWidth setState:[[pref objectForKey:@"cd_fullWidth"] integerValue]];
    [_cd_hideLabels setState:[[pref objectForKey:@"cd_hideLabels"] integerValue]];
    
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
    
    [_separatorBG setState:[[pref objectForKey:@"cd_separatorBG"] integerValue]];
    [_separatorWELL setColor:[NSColor colorWithRed:[[pref objectForKey:@"cd_separatorBGR"] floatValue]/255.0 green:[[pref objectForKey:@"cd_separatorBGG"] floatValue]/255 blue:[[pref objectForKey:@"cd_separatorBGB"] floatValue]/255.0 alpha:[[pref objectForKey:@"cd_separatorBGA"] floatValue]/100.0]];
    
    [_cd_cornerRadius setFloatValue:[[pref objectForKey:@"cd_cornerRadius"] integerValue]];
    
    [_cd_backgroundAlpha setFloatValue:[[pref objectForKey:@"cd_dockBGA"] floatValue]];
    
    [_borderWELL setHidden:true];
    [_dockWELL setHidden:true];
    [_labelWELL setHidden:true];
    [_indicatorWELL setHidden:true];
    [_shadowWELL setHidden:true];
    [_separatorWELL setHidden:true];
    
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
    if ([_separatorBG state] == NSOnState)
        [_separatorWELL setHidden:false];
}

- (void)setupActions {
    // Theme view actions
    [_cd_darkMode setAction:@selector(changeDarkMode:)];
    
    [_cd_hideLabels setAction:@selector(applyChanges:)];
    [_cd_darkenMouseOver setAction:@selector(applyChanges:)];
    [_cd_fullWidth setAction:@selector(applyChanges:)];
    [_cd_showFrost setAction:@selector(applyChanges:)];
    [_cd_showGlass setAction:@selector(applyChanges:)];
    [_cd_showSeparator setAction:@selector(applyChanges:)];
    [_cd_iconReflection setAction:@selector(changeReflection:)];
    
    [_cd_sizeIndicator setAction:@selector(applyChanges:)];
    [_cd_customIndicator setAction:@selector(changeIndicators:)];
    [_cd_pictureBackground setAction:@selector(changePictureBackground:)];
    [_cd_is3D setAction:@selector(change3D:)];
    
    [_cd_backgroundAlpha setAction:@selector(applyChanges:)];
    [_cd_indicatorWidth setAction:@selector(applyChanges:)];
    [_cd_indicatorHeight setAction:@selector(applyChanges:)];
    
    [_dockBG setAction:@selector(changeDockBG:)];
    [_borderBG setAction:@selector(changeBorderBG:)];
    [_labelBG setAction:@selector(changeLabelBG:)];
    [_shadowBG setAction:@selector(changeShadowBG:)];
    [_cd_indicatorBG setAction:@selector(changeIndicatorBG:)];
    [_separatorBG setAction:@selector(changeSeparatorBG:)];
    
    [_dockWELL setAction:@selector(applyChanges:)];
    [_borderWELL setAction:@selector(applyChanges:)];
    [_labelWELL setAction:@selector(applyChanges:)];
    [_shadowWELL setAction:@selector(applyChanges:)];
    [_indicatorWELL setAction:@selector(applyChanges:)];
    [_separatorWELL setAction:@selector(applyChanges:)];
    
    [_cd_cornerRadius setAction:@selector(applyChanges:)];
    [_cd_borderSize setAction:@selector(applyChanges:)];
    
    // Dock settings actions

    
    // Preferences actions
    [_reset_Dock setAction:@selector(resetDock:)];
    [_disable_cDock setAction:@selector(disableTheming:)];
    [_auto_checkUpdates setAction:@selector(autoUpdateChange:)];
    [_auto_installUpdates setAction:@selector(autoInstallChange:)];
    
    
    // SIMBL actions
    [_cd_installSIMBL setAction:@selector(simblInstall:)];
}

- (void)setupWindow {
    if ([[NSProcessInfo processInfo] operatingSystemVersion].minorVersion < 10)
    {
        _window.centerTrafficLightButtons = false;
        _window.showsBaselineSeparator = false;
        _window.titleBarHeight = 0.0;
    } else {
        [_window setTitlebarAppearsTransparent:true];
//        if ([_window respondsToSelector:@selector(_setTexturedBackground:)])
//            [_window performSelector:@selector(_setTexturedBackground:) withObject:[NSNumber numberWithBool:false]];
    }
    
    if ([[prefCD valueForKey:@"blurView"] boolValue])
    {
        Class vibrantClass=NSClassFromString(@"NSVisualEffectView");
        if (vibrantClass)
        {
            NSVisualEffectView *vibrant=[[vibrantClass alloc] initWithFrame:[[_window contentView] bounds]];
            [vibrant setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
            [vibrant setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
            [[_window contentView] addSubview:vibrant positioned:NSWindowBelow relativeTo:nil];
        }
    }
    
    [_window setBackgroundColor:[NSColor whiteColor]];
    [_window setMovableByWindowBackground:YES];
}

- (NSMutableDictionary *)_getDockPlist {
//    return [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.apple.dock"]];
    return [NSMutableDictionary dictionaryWithContentsOfFile:plist_Dock];
}

- (NSMutableDictionary *)_getThemePlist {
    return [NSMutableDictionary dictionaryWithContentsOfFile:plist_Theme];
}

- (NSMutableDictionary *)_getcDockPlist {
    return [NSMutableDictionary dictionaryWithContentsOfFile:plist_cDock];
}

- (instancetype)init {
    methodStart = [NSDate date];
    
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
    //    NSLog(@"%ld", _window.styleMask);
    
    prefCD = [self _getcDockPlist];
    [prefCD setObject:[NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]] forKey:@"version"];
    [prefCD writeToFile:plist_cDock atomically:YES];
    
    // Setup window
    [self setupWindow];
    
    // Setup color panel
    NSColorPanel *copo = [NSColorPanel sharedColorPanel];
    [copo setShowsAlpha:YES];
    [copo setShowsResizeIndicator:YES];
    [copo setOpaque:YES];
    [copo setShowsToolbarButton:YES];
    [copo setTitle:@"cDock 2"];
    
    [self tooltipToggle:nil];
    
    // Directory check
    [self dirCheck:themeFldr];
    [self dirCheck:@"/Library/Application Support/SIMBL/Plugins/"];
    
    // Install the bundle
    NSError *error = nil;
    NSString *srcPath = [[NSBundle mainBundle] pathForResource:@"cDock" ofType:@"bundle"];
    NSString *dstPath = @"/Library/Application Support/SIMBL/Plugins/cDock.bundle";
    
    NSString *srcBndl = [[NSBundle mainBundle] pathForResource:@"cDock.bundle/Contents/Info" ofType:@"plist"];
    NSString *dstBndl = @"/Library/Application Support/SIMBL/Plugins/cDock.bundle/Contents/Info.plist";
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dstBndl]){
        NSString *srcVer = [[[NSMutableDictionary alloc] initWithContentsOfFile:srcBndl] objectForKey:@"CFBundleVersion"];
        NSString *dstVer = [[[NSMutableDictionary alloc] initWithContentsOfFile:dstBndl] objectForKey:@"CFBundleVersion"];
        if (![srcVer isEqual:dstVer] && ![srcPath isEqualToString:@""])
        {
            NSLog(@"\nSource: %@\nDestination: %@", srcVer, dstVer);
            [[NSFileManager defaultManager] removeItemAtPath:@"/tmp/cDock.bundle" error:&error];
            [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:@"/tmp/cDock.bundle" error:&error];
            [[NSFileManager defaultManager] replaceItemAtURL:[NSURL fileURLWithPath:dstPath] withItemAtURL:[NSURL fileURLWithPath:@"/tmp/cDock.bundle"] backupItemName:nil options:NSFileManagerItemReplacementUsingNewMetadataOnly resultingItemURL:nil error:&error];
            
//            [[NSFileManager defaultManager] removeItemAtPath:dstPath error:&error];
//            [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:dstPath error:&error];
            system("killall Dock; sleep 1; osascript -e 'tell application \"Dock\" to inject SIMBL into Snow Leopard'");
        }
    } else {
        [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:dstPath error:&error];
        system("killall Dock; sleep 1; osascript -e 'tell application \"Dock\" to inject SIMBL into Snow Leopard'");
    }
    
    // Install the themes
    NSString *thmPath = [[NSBundle mainBundle] pathForResource:@"themes" ofType:@""];
    NSMutableArray* dirs = [[NSMutableArray alloc] init];
    [dirs addObjectsFromArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:thmPath error:Nil]];
    
    for (NSString *theme in dirs) {
        NSString *pattyCAKE = [themeFldr stringByAppendingPathComponent:theme];
        if (![[NSFileManager defaultManager] fileExistsAtPath:pattyCAKE])
        {
            srcPath = [NSString stringWithFormat:@"%@/%@", thmPath, theme];
            [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:pattyCAKE error:&error];
        }
    }
    
    // Add login item
    [self addLoginItem];
    
    // Setup themeview
    [self setupTheme];
    
    // Setup actions
    [self setupActions];
    
    // Check for updates
    if ([[prefCD objectForKey:@"autoCheck"] boolValue])
        [self checkUpdates:[[prefCD objectForKey:@"autoInstall"] integerValue]];
    
    [_pop_info setImage:[NSImage imageNamed:NSImageNameInfo]];
    [[_pop_info cell] setImageScaling:NSImageScaleProportionallyUpOrDown];
    
    [_pop_paypal setImage:[NSImage imageNamed:@"heart2.png"]];
    [[_pop_paypal cell] setImageScaling:NSImageScaleProportionallyUpOrDown];
    [_pop_paypal setAction:@selector(donate:)];
    
    [_pop_github setImage:[NSImage imageNamed:@"github.png"]];
    [[_pop_github cell] setImageScaling:NSImageScaleProportionallyUpOrDown];
    [_pop_github setAction:@selector(visit_github:)];
    
    [_pop_email setImage:[NSImage imageNamed:NSImageNameUserAccounts]];
    [[_pop_email cell] setImageScaling:NSImageScaleProportionallyUpOrDown];
    [_pop_email setAction:@selector(send_email:)];
    
    // Setup tabview
    long osx_version = [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion;
    NSString *rootless = nil;
    NSTabViewItem *editTab = [_tabView tabViewItemAtIndex:0];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:@"/System/Library/ScriptingAdditions/SIMBL.osax"])
    {        
        if (osx_version >= 11)
        {
            // Rootless check
            rootless = runCommand(@"touch /System/test 2>&1");
            if ([rootless containsString:@"Operation not permitted"])
            {
                // Add rootless tab
                [editTab setView:_rootlView];
            }
            else
            {
                // Add SIMBL tab
                [editTab setView:_simblView];
            }
        }
        else
        {
            // Add SIMBL tab
            [editTab setView:_simblView];
        }
    }
    else
    {
        // Launch dock agent
        [self launch_helper];
        
        // Add theme tab
        [editTab setView:_themeView];
    }
    [_tabView selectTabViewItemAtIndex:0];
    
    // Resize buttons
    // For translations and tooltips
    for (NSButton *btn in [_themeView subviews])
    {
        if (btn.class != NSClassFromString(@"NSPopUpButton"))
                if ([btn respondsToSelector:@selector(sizeToFit)])
                    [btn sizeToFit];
    }
    
    self.aboutWindowController = [[PFAboutWindowController alloc] init];
    
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"executionTime = %f", executionTime);
    
    [[NSRunningApplication currentApplication] activateWithOptions:(NSApplicationActivateAllWindows | NSApplicationActivateIgnoringOtherApps)];
    
    // Offer to the move the Application if necessary.
    // Note that if the user chooses to move the application,
    // this call will never return. Therefore you can suppress
    // any first run UI by putting it after this call.
    PFMoveToApplicationsFolderIfNecessary();
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}

- (IBAction)autoUpdateChange:(id)sender {
    prefCD = self._getcDockPlist;
    [prefCD setObject:[NSNumber numberWithBool:[self.auto_checkUpdates state]] forKey:@"autoCheck"];
    [prefCD writeToFile:plist_cDock atomically:YES];
    if (self.auto_checkUpdates.state == NSOnState)
        [self checkUpdates:[[prefCD objectForKey:@"autoInstall"] integerValue]];
}

- (IBAction)autoInstallChange:(id)sender {
    prefCD = self._getcDockPlist;
    [prefCD setObject:[NSNumber numberWithBool:[self.auto_installUpdates state]] forKey:@"autoInstall"];
    [prefCD writeToFile:plist_cDock atomically:YES];
}

- (IBAction)change_theme:(id)sender {
    CFDictionaryKeyCallBacks keyCallbacks = {0, NULL, NULL, CFCopyDescription, CFEqual, NULL};
    CFDictionaryValueCallBacks valueCallbacks  = {0, NULL, NULL, CFCopyDescription, CFEqual};
    
    CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 1,
                                                                  &keyCallbacks, &valueCallbacks);
    CFDictionaryAddValue(dictionary, CFSTR("dock"), CFSTR("1"));
    CFDictionaryAddValue(dictionary, CFSTR("images"), CFSTR("1"));
    CFDictionaryAddValue(dictionary, CFSTR("indicators"), CFSTR("1"));
    CFDictionaryAddValue(dictionary, CFSTR("shadow"), CFSTR("1"));
    [self dockNotification:dictionary];
    
    prefCD = self._getcDockPlist;
    [prefCD setObject:[NSNumber numberWithBool:true] forKey:@"cd_enabled"];
    [prefCD setObject:_cd_theme.selectedItem.title forKey:@"cd_theme"];
    NSMutableDictionary *tmpPlist0 = prefCD;
    [tmpPlist0 writeToFile:plist_cDock atomically:YES];
    
    [self setupTheme];
    [self applyChanges:nil];
}

- (IBAction)tooltipToggle:(id)sender {
    NSToolTipManager *test = [NSToolTipManager sharedToolTipManager];
    if (showTooltips)
    {
        showTooltips = false;
        [test setInitialToolTipDelay:0.1];
    } else {
        showTooltips = true;
        [test setInitialToolTipDelay:5];
    }
}

- (IBAction)showAboutWindow:(id)sender {
    if (_aboutWindowController == nil)
        _aboutWindowController = [[PFAboutWindowController alloc] init];
    
    [self.aboutWindowController setAppURL:[[NSURL alloc] initWithString:@"https://github.com/w0lfschild/cDock2"]];
    [self.aboutWindowController setAppName:@"cDock 2"];
    [self.aboutWindowController setWindowShouldHaveShadow:YES];
    
//    if ([[prefCD valueForKey:@"blurView"] boolValue])
//    {
//        Class vibrantClass=NSClassFromString(@"NSVisualEffectView");
//        if (vibrantClass)
//        {
//            NSVisualEffectView *vibrant=[[vibrantClass alloc] initWithFrame:[_aboutWindowController.window.contentView bounds]];
//            [vibrant setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
//            [vibrant setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
//            [[_aboutWindowController.window contentView] addSubview:vibrant positioned:NSWindowBelow relativeTo:nil];
//        }
//    }
    
    [self.aboutWindowController showWindow:nil];
    [[NSRunningApplication currentApplication] activateWithOptions:(NSApplicationActivateAllWindows | NSApplicationActivateIgnoringOtherApps)];
}

- (IBAction)showPreferences:(id)sender {
//    [_aboutWindowController close];
    [ _tabView selectTabViewItemAtIndex:2 ];
    [[NSRunningApplication currentApplication] activateWithOptions:(NSApplicationActivateAllWindows | NSApplicationActivateIgnoringOtherApps)];
}

- (IBAction)showPopover:(id)sender {
    [_poppy showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMinXEdge];
}

- (IBAction)simblInstall:(id)sender {
    NSArray *apps = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"org.w0lf.cDockAgent"];
    if (apps.count)
    {
        [(NSRunningApplication *)[apps objectAtIndex:0] terminate];
    }
    [self launch_helper];
    dispatch_queue_t myQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(myQueue, ^{
        // Insert code to be executed on another thread here
        while (![[NSFileManager defaultManager] fileExistsAtPath:@"/System/Library/ScriptingAdditions/SIMBL.osax"])
        {
            usleep(1000000);
//            NSLog(@"Slept 1 second");
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // Insert code to be executed on the main thread here
            [self launch_helper];
            NSTabViewItem *editTab = [_tabView tabViewItemAtIndex:0];
            [editTab setView:_themeView];
            system("killall Dock; sleep 1; osascript -e 'tell application \"Dock\" to inject SIMBL into Snow Leopard'");
            NSLog(@"SIMBL Installed");
        });
    });
}

- (IBAction)disableTheming:(id)sender {
    [prefCD setObject:[NSNumber numberWithBool:false] forKey:@"cd_enabled"];
    [prefCD setObject:@"None" forKey:@"cd_theme"];
    NSMutableDictionary *tmp = prefCD;
    [tmp writeToFile:plist_cDock atomically:YES];
    [self setupTheme];
    system("killall Dock; sleep 2; osascript -e 'tell application \"Dock\" to inject SIMBL into Snow Leopard'");
}

- (IBAction)resetDock:(id)sender {
    NSLog(@"%@", plist_Dock);
    
//    NSError *error = nil;
//    [[NSFileManager defaultManager] removeItemAtPath:plist_Dock error:&error];
    
//    runCommand([NSString stringWithFormat:@"defaults delete com.apple.dock.plist"]);
    
//    if (error)
//        [NSAlert alertWithError:error];
    
    system("defaults delete com.apple.dock.plist; killall Dock; sleep 2; osascript -e 'tell application \"Dock\" to inject SIMBL into Snow Leopard'");
    [self setupTheme];
}

- (IBAction)changeDarkMode:(id)sender {
    [self applyChanges:nil];
    
    CFDictionaryKeyCallBacks keyCallbacks = {0, NULL, NULL, CFCopyDescription, CFEqual, NULL};
    CFDictionaryValueCallBacks valueCallbacks  = {0, NULL, NULL, CFCopyDescription, CFEqual};
    CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &keyCallbacks, &valueCallbacks);
    CFDictionaryAddValue(dictionary, CFSTR("dock"), CFSTR("1"));
    CFDictionaryAddValue(dictionary, CFSTR("indicators"), CFSTR("1"));
    [self dockNotification:dictionary];
}

- (IBAction)changeReflection:(id)sender {
    if (_cd_iconReflection.state == 0)
    {
        CFDictionaryKeyCallBacks keyCallbacks = {0, NULL, NULL, CFCopyDescription, CFEqual, NULL};
        CFDictionaryValueCallBacks valueCallbacks  = {0, NULL, NULL, CFCopyDescription, CFEqual};
        
        CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 1,
                                                                      &keyCallbacks, &valueCallbacks);
        CFDictionaryAddValue(dictionary, CFSTR("dock"), CFSTR("1"));
        CFDictionaryAddValue(dictionary, CFSTR("shadow"), CFSTR("1"));
        CFDictionaryAddValue(dictionary, CFSTR("indicators"), CFSTR("1"));
        [self dockNotification:dictionary];

    }
    [self applyChanges:nil];
}

- (IBAction)changeIndicators:(id)sender {
    
    if (_cd_customIndicator.state == 1)
    {
        [_cd_indicatorBG setState:0];
        [_indicatorWELL setHidden:true];
    }
    
    CFDictionaryKeyCallBacks keyCallbacks = {0, NULL, NULL, CFCopyDescription, CFEqual, NULL};
    CFDictionaryValueCallBacks valueCallbacks  = {0, NULL, NULL, CFCopyDescription, CFEqual};
    
    CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 1,
                                                                  &keyCallbacks, &valueCallbacks);
    CFDictionaryAddValue(dictionary, CFSTR("dock"), CFSTR("1"));
    CFDictionaryAddValue(dictionary, CFSTR("indicators"), CFSTR("1"));
    [self dockNotification:dictionary];
    [self applyChanges:nil];
}

- (IBAction)change3D:(id)sender {
    
    if ([sender state] == NSOnState) {
        
        [_cd_showFrost setState:0];
        [_cd_showGlass setState:0];
        [_dockBG setState:0];
        [_cd_pictureBackground setState:1];
        [_dockWELL setHidden:true];
        
    }
    
   [self applyChanges:nil];
}

- (IBAction)changePictureBackground:(id)sender {
    
    if ([sender state] == NSOnState) {
        
        [_cd_showGlass setState:0];
        [_dockBG setState:0];
        [_dockWELL setHidden:true];
        
    }
    
    if ([sender state] == NSOffState) {
        [_cd_is3D setState:0];
    }
    
    [self applyChanges:nil];
}

- (IBAction)changeIndicatorBG:(id)sender {
    if ([sender state] == NSOnState) {
        [_indicatorWELL setHidden:false];
        [_cd_customIndicator setState:0];
    } else if ([sender state] == NSOffState) {
        [_indicatorWELL setHidden:true];
    }
    
    CFDictionaryKeyCallBacks keyCallbacks = {0, NULL, NULL, CFCopyDescription, CFEqual, NULL};
    CFDictionaryValueCallBacks valueCallbacks  = {0, NULL, NULL, CFCopyDescription, CFEqual};
    CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &keyCallbacks, &valueCallbacks);
    CFDictionaryAddValue(dictionary, CFSTR("indicators"), CFSTR("1"));
    [self dockNotification:dictionary];
    [self applyChanges:nil];
}

- (IBAction)changeShadowBG:(id)sender {
    if ([sender state] == NSOnState) {
        [_shadowWELL setHidden:false];
    } else if ([sender state] == NSOffState) {
        
        CFDictionaryKeyCallBacks keyCallbacks = {0, NULL, NULL, CFCopyDescription, CFEqual, NULL};
        CFDictionaryValueCallBacks valueCallbacks  = {0, NULL, NULL, CFCopyDescription, CFEqual};
        CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &keyCallbacks, &valueCallbacks);
        CFDictionaryAddValue(dictionary, CFSTR("shadow"), CFSTR("1"));
        [self dockNotification:dictionary];
        
        [_shadowWELL setHidden:true];
    }
    [self applyChanges:nil];
}

- (IBAction)changeLabelBG:(id)sender {
    if ([sender state] == NSOnState) {
        [_labelWELL setHidden:false];
    } else if ([sender state] == NSOffState) {
        [_labelWELL setHidden:true];
    }
    [self applyChanges:nil];
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
    [self applyChanges:nil];
}

- (IBAction)changeSeparatorBG:(id)sender {
    if ([sender state] == NSOnState) {
        [_separatorWELL setHidden:false];
    } else if ([sender state] == NSOffState) {
        [_separatorWELL setHidden:true];
    }
    [self applyChanges:nil];
}

- (IBAction)changeDockBG:(id)sender {
    if ([sender state] == NSOnState) {
        [_dockWELL setHidden:false];
    } else if ([sender state] == NSOffState) {
        [_dockWELL setHidden:true];
    }
    [self applyChanges:nil];
}

- (IBAction)donate:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://goo.gl/vF92sf"]];
}

- (IBAction)visit_github:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/w0lfschild"]];
}

- (IBAction)show_themes:(id)sender {
    NSURL *folderURL = [NSURL fileURLWithPath: themeFldr];
    [[NSWorkspace sharedWorkspace] openURL: folderURL];
}

- (IBAction)createTheme:(id)sender {
    NSSavePanel* svgDlg = [NSSavePanel savePanel];
    [svgDlg setTitle:@"Create cDock Theme"];
    [svgDlg setPrompt:@"Create"];
    [svgDlg setAllowedFileTypes:[[NSArray alloc] initWithObjects:@"plist", nil]];
    [svgDlg setDirectoryURL:[NSURL fileURLWithPath:themeFldr]];
    [svgDlg setExtensionHidden:true];
    [svgDlg setShowsTagField:false];
    
    if ([svgDlg runModal] == NSOKButton) {
        // Got it, use the panel.URL field for something
        NSLog(@"%@", [svgDlg nameFieldStringValue]);
        NSLog(@"%@", [svgDlg URL]);
        
        NSError *error;
        NSString *thmPath = [[NSBundle mainBundle] pathForResource:@"themes" ofType:@""];
        NSString *text = [[svgDlg nameFieldStringValue] stringByReplacingOccurrencesOfString:@".plist" withString:@""];
        NSString *pattyCAKE = [themeFldr stringByAppendingPathComponent:text];
        
        NSString *mv1 = [themeFldr stringByAppendingFormat:@"/%@/Default.plist", text];
        NSString *mv2 = [themeFldr stringByAppendingFormat:@"/%@/%@.plist", text, text];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:pattyCAKE])
        {
            NSString *srcPath = [thmPath stringByAppendingPathComponent:@"Default"];
            [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:pattyCAKE error:&error];
            [[NSFileManager defaultManager] moveItemAtPath:mv1 toPath:mv2 error:&error];
            
            CFDictionaryKeyCallBacks keyCallbacks = {0, NULL, NULL, CFCopyDescription, CFEqual, NULL};
            CFDictionaryValueCallBacks valueCallbacks  = {0, NULL, NULL, CFCopyDescription, CFEqual};
            
            CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 1,
                                                                          &keyCallbacks, &valueCallbacks);
            CFDictionaryAddValue(dictionary, CFSTR("dock"), CFSTR("1"));
            CFDictionaryAddValue(dictionary, CFSTR("images"), CFSTR("1"));
            CFDictionaryAddValue(dictionary, CFSTR("indicators"), CFSTR("1"));
            CFDictionaryAddValue(dictionary, CFSTR("shadow"), CFSTR("1"));
            [self dockNotification:dictionary];
            
            prefCD = [self _getcDockPlist];
            [prefCD setObject:[NSNumber numberWithBool:true] forKey:@"cd_enabled"];
            [prefCD setObject:text forKey:@"cd_theme"];
            NSMutableDictionary *tmpPlist0 = prefCD;
            [tmpPlist0 writeToFile:plist_cDock atomically:YES];
            
            [self setupTheme];
            [self applyChanges:nil];
        }
    } else {
        // Cancel was pressed...
    }
}

- (IBAction)importTheme:(id)sender {
    NSOpenPanel* opnDlg = [NSOpenPanel openPanel];
    [opnDlg setTitle:@"Import cDock Theme"];
    [opnDlg setPrompt:@"Import"];
    [opnDlg setDirectoryURL:[NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES) firstObject]]];
    
    //Disable file selection
    [opnDlg setCanChooseFiles: false];
    
    //Enable folder selection
    [opnDlg setCanChooseDirectories: true];
    
    //Enable alias resolving
    [opnDlg setResolvesAliases: true];
    
    //Disable multiple selection
    [opnDlg setAllowsMultipleSelection: false];
    
    if ([opnDlg runModal] == NSOKButton) {
        // Got it, use the panel.URL field for something
        NSLog(@"%@", [opnDlg URL]);
        
        NSError *error;
        NSString* selTheme = opnDlg.URL.path;
        NSString* theFileName = [[selTheme lastPathComponent] stringByDeletingPathExtension];
        NSString* destTheme = [themeFldr stringByAppendingPathComponent:theFileName];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:destTheme])
        {
//            NSLog(@"\n%@\n%@", selTheme, theFileName);
            [[NSFileManager defaultManager] copyItemAtPath:selTheme toPath:destTheme error:&error];
//            NSLog(@"%@", error);
            
            CFDictionaryKeyCallBacks keyCallbacks = {0, NULL, NULL, CFCopyDescription, CFEqual, NULL};
            CFDictionaryValueCallBacks valueCallbacks  = {0, NULL, NULL, CFCopyDescription, CFEqual};
            
            CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 1,
                                                                          &keyCallbacks, &valueCallbacks);
            CFDictionaryAddValue(dictionary, CFSTR("dock"), CFSTR("1"));
            CFDictionaryAddValue(dictionary, CFSTR("images"), CFSTR("1"));
            CFDictionaryAddValue(dictionary, CFSTR("indicators"), CFSTR("1"));
            CFDictionaryAddValue(dictionary, CFSTR("shadow"), CFSTR("1"));
            [self dockNotification:dictionary];
            
            prefCD = [self _getcDockPlist];
            [prefCD setObject:[NSNumber numberWithBool:true] forKey:@"cd_enabled"];
            [prefCD setObject:theFileName forKey:@"cd_theme"];
            NSMutableDictionary *tmpPlist0 = prefCD;
            [tmpPlist0 writeToFile:plist_cDock atomically:YES];
            
            [self setupTheme];
            [self applyChanges:nil];
        }

    } else {
        // Cancel was pressed...
    }
}

- (IBAction)changeVibrancy:(id)sender {
    prefCD = self._getcDockPlist;
    [prefCD setObject:[NSNumber numberWithBool:[self.cdock_isVibrant state]] forKey:@"blurView"];
    [prefCD writeToFile:plist_cDock atomically:YES];
    
    Class vibrantClass=NSClassFromString(@"NSVisualEffectView");
    if (vibrantClass)
    {
        if ([[prefCD valueForKey:@"blurView"] boolValue])
        {
            NSVisualEffectView *vibrant=[[vibrantClass alloc] initWithFrame:[[_window contentView] bounds]];
            [vibrant setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
            [vibrant setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
            if (![_window.contentView.subviews containsObject:vibrant])
                [[_window contentView] addSubview:vibrant positioned:NSWindowBelow relativeTo:nil];
        } else {
            for (NSVisualEffectView *v in (NSMutableArray *)_window.contentView.subviews)
            {
                if ([v class] == vibrantClass) {
                    [v removeFromSuperview];
                    break;
                }
            }
        }
    }
}

- (IBAction)send_email:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:aguywithlonghair@gmail.com"]];
}

@end
