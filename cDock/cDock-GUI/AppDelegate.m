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

@interface swagNumFormatter : NSNumberFormatter

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString **)newString errorDescription:(NSString **) error;

@end

@implementation swagNumFormatter

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString **)newString errorDescription:(NSString **) error {
    // Make sure we clear newString and error to ensure old values aren't being used
    if (newString) { *newString = nil; }
    if (error)     { *error = nil; }
    
//    NSLog(@"STRING: %@", partialString);
    
    NSCharacterSet *allItems = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    if (![[partialString stringByTrimmingCharactersInSet:allItems] isEqualToString:@""]) {
        return NO;
    }
    
    BOOL hasString = false;
    if ([[NSProcessInfo processInfo] operatingSystemVersion].minorVersion > 9) {
        if ([partialString containsString:@"."])
            hasString = true;
    } else {
        NSRange range = [partialString rangeOfString:@"."];
        if(range.location != NSNotFound)
            hasString = true;
    }
    
    if (hasString) {
        if ([partialString length] > 6) {
            return NO;
        } else {
            // No leading number
            if ([partialString characterAtIndex:0] == '.')
                return NO;
            
            NSArray *lines = [partialString componentsSeparatedByString: @"."];
            
            // Limit integers to three places
            if ([lines[0] length] > 3)
                return NO;
            
            // Limit decimal places to two places
            if ([lines[1] length] > 2)
                return NO;
            
            // More than one decimal
            if (lines.count > 2)
                return NO;
        }
    } else {
        if ([partialString length] > 3) {
            return NO;
        }
    }
    
    return YES;
}

@end

@implementation AppDelegate

- (NSString*) runCommand:(NSString*)commandToRun
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

- (void) runScript:(NSString*)scriptName
{
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    
    NSArray *arguments;
    NSString* newpath = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] privateFrameworksPath], scriptName];
    NSLog(@"shell script path: %@",newpath);
    arguments = [NSArray arrayWithObjects:newpath, nil];
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"script returned:\n%@", string);
}

- (BOOL) runProcessAsAdministrator:(NSString*)scriptPath
                     withArguments:(NSArray *)arguments
                            output:(NSString **)output
                  errorDescription:(NSString **)errorDescription {
    
    NSString * allArgs = [arguments componentsJoinedByString:@" "];
    NSString * fullScript = [NSString stringWithFormat:@"'%@' %@", scriptPath, allArgs];
    
    NSDictionary *errorInfo = [NSDictionary new];
    NSString *script =  [NSString stringWithFormat:@"do shell script \"%@\" with administrator privileges", fullScript];
    
    NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
    NSAppleEventDescriptor * eventResult = [appleScript executeAndReturnError:&errorInfo];
    
    // Check errorInfo
    if (! eventResult)
    {
        // Describe common errors
        *errorDescription = nil;
        if ([errorInfo valueForKey:NSAppleScriptErrorNumber])
        {
            NSNumber * errorNumber = (NSNumber *)[errorInfo valueForKey:NSAppleScriptErrorNumber];
            if ([errorNumber intValue] == -128)
                *errorDescription = @"The administrator password is required to do this.";
        }
        
        // Set error message from provided message
        if (*errorDescription == nil)
        {
            if ([errorInfo valueForKey:NSAppleScriptErrorMessage])
                *errorDescription =  (NSString *)[errorInfo valueForKey:NSAppleScriptErrorMessage];
        }
        
        return NO;
    }
    else
    {
        // Set output to the AppleScript's output
        *output = [eventResult stringValue];
        
        return YES;
    }
}

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
        NSString *loginAgent = [[NSBundle mainBundle] pathForResource:@"cDockHelper" ofType:@"app"];
        nullString = [self runCommand:@"osascript -e \"tell application \\\"System Events\\\" to delete login items \\\"cDock-Agent\\\"\""];
        nullString = [self runCommand:@"osascript -e \"tell application \\\"System Events\\\" to delete login items \\\"cDockHelper\\\"\""];
        NSString *addAgent = [NSString stringWithFormat:@"osascript -e \"tell application \\\"System Events\\\" to make new login item at end of login items with properties {path:\\\"%@\\\", hidden:false}\"", loginAgent];
        nullString = [self runCommand:addAgent];
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
    nullString = [self runCommand:nullString];
    NSArray *myWords = [nullString componentsSeparatedByString:@"\n"];
    for (NSNumber *anid in myWords)
    {
        NSString *killer = [NSString stringWithFormat:@"kill %@", anid];
        if (![killer isEqualToString:@"kill "])
            [self runCommand:killer];
    }
    system("killall cDockHelper");
    //system('for item in $(ps aux | grep "cDock" | tr -s ' ' | cut -d ' ' -f 2); do kill "$item"; done')
    NSString *path = [[NSBundle mainBundle] pathForResource:@"cDockHelper" ofType:@"app"];
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
    
    NSArray *orientations = [NSArray arrayWithObjects:@"left", @"bottom", @"right", nil];
    NSArray *mineffects = [NSArray arrayWithObjects:@"genie", @"scale", @"suck", nil];
    
    [prefd setObject:[NSNumber numberWithBool:[_dock_SOAA state]] forKey:@"static-only"];
    [prefd setObject:[NSNumber numberWithBool:[_dock_DHI state]] forKey:@"showhidden"];
    [prefd setObject:[NSNumber numberWithBool:[_dock_LDC state]] forKey:@"contents-immutable"];
    [prefd setObject:[NSNumber numberWithBool:[_dock_MOH state]] forKey:@"mouse-over-hilite-stack"];
    [prefd setObject:[NSNumber numberWithBool:[_dock_SAM state]] forKey:@"single-app"];
    [prefd setObject:[NSNumber numberWithBool:[_dock_ANB state]] forKey:@"no-bouncing"];
    [prefd setObject:[NSNumber numberWithBool:[_dock_AOB state]] forKey:@"launchanim"];
    [prefd setObject:[NSNumber numberWithBool:[_dock_SAI state]] forKey:@"show-process-indicators"];
    [prefd setObject:[NSNumber numberWithBool:[_dock_MWI state]] forKey:@"minimize-to-application"];
    [prefd setObject:[NSNumber numberWithBool:[_dock_STO state]] forKey:@"scroll-to-open"];
    [prefd setObject:[NSNumber numberWithBool:[_dock_magnification state]] forKey:@"magnification"];
    [prefd setObject:[NSNumber numberWithBool:[_dock_autohide state]] forKey:@"autohide"];
    [prefd setObject:[NSNumber numberWithFloat:[_dock_tilesize floatValue]] forKey:@"tilesize"];
    [prefd setObject:[NSNumber numberWithFloat:[_dock_magnification_value floatValue]] forKey:@"largesize"];
    [prefd setObject:[NSNumber numberWithFloat:3.0 - [_dock_autohide_value floatValue]] forKey:@"autohide-time-modifier"];
    [prefd setObject:[orientations objectAtIndex:[_dock_POS indexOfSelectedItem]] forKey:@"orientation"];
    [prefd setObject:[mineffects objectAtIndex:[_dock_MU indexOfSelectedItem]] forKey:@"mineffect"];
    
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
        
        [pref setObject:[NSNumber numberWithBool:[_cd_separatorfullHeight state]] forKey:@"cd_separatorfullHeight"];
        
        [pref setObject:[NSNumber numberWithBool:[_cd_fullWidth state]] forKey:@"cd_fullWidth"];
        [pref setObject:[NSNumber numberWithBool:![_cd_hideLabels state]] forKey:@"cd_hideLabels"];
        
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

- (void)setupTheme {
    // cDock Theme Preferences
    if (![[NSFileManager defaultManager] fileExistsAtPath:plist_Theme])
    {
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
    if (![[NSFileManager defaultManager] fileExistsAtPath:plist_cDock])
    {
        prefCD = [[NSMutableDictionary alloc] init];
        [prefCD setObject:@"None" forKey:@"cd_theme"];
        [prefCD setObject:[NSNumber numberWithBool:false] forKey:@"cd_enabled"];
        [prefCD setObject:[NSNumber numberWithBool:true] forKey:@"autoCheck"];
        [prefCD setObject:[NSNumber numberWithBool:false] forKey:@"autoInstall"];
        NSMutableDictionary *tmpPlist = prefCD;
        [tmpPlist writeToFile:plist_cDock atomically:YES];
    }
    
    [[_cdock_changeLog textStorage] setAttributedString:[[NSAttributedString alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"changelog" ofType:@"rtf"] documentAttributes:nil]];
    
    // Dock settings
    prefd = [self _getDockPlist];
    
    swagNumFormatter *_customFormatter = [[swagNumFormatter alloc] init];
    [_dock_autohide_value setFormatter:_customFormatter];
    [_dock_magnification_value setFormatter:_customFormatter];
    [_dock_appSpacers setFormatter:_customFormatter];
    [_dock_docSpacers setFormatter:_customFormatter];
    [_dock_tilesize setFormatter:_customFormatter];
    
    NSArray *orientations = [NSArray arrayWithObjects:@"left", @"bottom", @"right", nil];
    NSArray *mineffects = [NSArray arrayWithObjects:@"genie", @"scale", @"suck", nil];
    
    [_dock_SOAA setState:[[prefd objectForKey:@"static-only"] integerValue]];
    [_dock_DHI setState:[[prefd objectForKey:@"showhidden"] integerValue]];
    [_dock_LDC setState:[[prefd objectForKey:@"contents-immutable"] integerValue]];
    [_dock_MOH setState:[[prefd objectForKey:@"mouse-over-hilite-stack"] integerValue]];
    [_dock_SAM setState:[[prefd objectForKey:@"single-app"] integerValue]];
    [_dock_ANB setState:[[prefd objectForKey:@"no-bouncing"] integerValue]];
    [_dock_autohide setState:[[prefd objectForKey:@"autohide"] integerValue]];
    [_dock_magnification setState:[[prefd objectForKey:@"magnification"] integerValue]];
    [_dock_magnification_value setFloatValue:[[prefd objectForKey:@"largesize"] integerValue]];
    [_dock_tilesize setFloatValue:[[prefd objectForKey:@"tilesize"] integerValue]];
    [_dock_AOB setState:[[prefd objectForKey:@"launchanim"] integerValue]];
    [_dock_SAI setState:[[prefd objectForKey:@"show-process-indicators"] integerValue]];
    [_dock_MWI setState:[[prefd objectForKey:@"minimize-to-application"] integerValue]];
    [_dock_STO setState:[[prefd objectForKey:@"scroll-to-open"] integerValue]];
    [_dock_POS selectItemAtIndex:[orientations indexOfObject:[prefd objectForKey:@"orientation"]]];
    [_dock_MU selectItemAtIndex:[mineffects indexOfObject:[prefd objectForKey:@"mineffect"]]];
    [_dock_autohide_value setFloatValue:3.0 - [[prefd objectForKey:@"autohide-time-modifier"] floatValue]];
    
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
    if (darkMode >= 0.0 && darkMode <= 3.0)
        [_cd_darkMode selectItemAtIndex:(int)darkMode];
    
    NSMutableArray* dirs = [[NSMutableArray alloc] init];
    [dirs addObjectsFromArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:themeFldr error:Nil]];
    if ([dirs containsObject:@".DS_Store"])
        [dirs removeObject:@".DS_Store"];
    
    [_cd_themePicker removeAllItems];
    [_cd_themePicker addItemWithTitle:@"None" ];
    [_cd_themePicker addItemsWithTitles:dirs ];
    
    NSMutableDictionary *plist0 = [self _getcDockPlist];
    prefCD = plist0;
    
    [ _cdock_isVibrant setState:[[prefCD objectForKey:@"blurView"] integerValue]];
    if ([[NSProcessInfo processInfo] operatingSystemVersion].minorVersion < 10)
        [_cdock_isVibrant setEnabled:false];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SUAutomaticallyUpdate"]) {
        [_cdock_updates selectItemAtIndex:2];
        [_myUpdater checkForUpdatesInBackground];
    } else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SUEnableAutomaticChecks"]) {
        [_cdock_updates selectItemAtIndex:1];
        [_myUpdater checkForUpdatesInBackground];
    } else {
        [_cdock_updates selectItemAtIndex:0];
    }
    
    [_cdock_updates_interval selectItemWithTag:[[[NSUserDefaults standardUserDefaults] objectForKey:@"SUScheduledCheckInterval"] integerValue]];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CDRememberWindow"])
    {
        [_cdock_rememberWindow setState:NSOnState];
        [_window setFrameAutosaveName:@"MainWindow"];
    } else {
        [_cdock_rememberWindow setState:NSOffState];
    }
    
    if ([[NSProcessInfo processInfo] operatingSystemVersion].minorVersion < 10)
    {
        [[_donatebutton cell] setBackgroundColor:[NSColor colorWithCalibratedRed:0.438f green:0.121f blue:0.199f alpha:1.000f]];
    } else {
       [_donatebutton.layer setBackgroundColor:[NSColor colorWithCalibratedRed:0.438f green:0.121f blue:0.199f alpha:0.258f].CGColor];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CDHideDonate"]) {
        [_cdock_hideDonate setState:NSOnState];
        [_pop_paypal setHidden:true];
        [_pop_translate setHidden:true];
    } else {
        [_cdock_hideDonate setState:NSOffState];
        [_pop_paypal setHidden:false];
        [_pop_translate setHidden:false];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CDToolTips"]) {
        [_cdock_fastTooltips setState:NSOnState];
    } else {
        [_cdock_fastTooltips setState:NSOffState];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:plist_Theme])
    {
        //        NSLog(@"Exists: %@", plist_Theme);
        [ _cd_themePicker selectItemWithTitle:themeName];
    }
    else
    {
        //        NSLog(@"Not Found: %@", plist_Theme);
        [ _cd_themePicker selectItemWithTitle:@"None"];
    }

    [_cd_separatorfullHeight setState:[[pref objectForKey:@"cd_separatorfullHeight"] integerValue]];
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
    [_cd_hideLabels setState:![[pref objectForKey:@"cd_hideLabels"] boolValue]];
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
    [_reset_Dock setAction:@selector(resetDock:)];
    [_disable_cDock setAction:@selector(disableTheming:)];
    [_cd_installSIMBL setAction:@selector(simblInstall:)];
}

- (void)setupWindow {
    if ([[NSProcessInfo processInfo] operatingSystemVersion].minorVersion < 10)
    {
//        _window.centerTrafficLightButtons = false;
//        _window.showsBaselineSeparator = false;
//        _window.titleBarHeight = 0.0;
    } else {
        [_window setTitlebarAppearsTransparent:true];
        _window.styleMask |= NSFullSizeContentViewWindowMask;
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
    
    [[_pop_paypal cell] setImageScaling:NSImageScaleProportionallyUpOrDown];
    [_pop_paypal setAction:@selector(donate:)];
    [[_pop_translate cell] setImageScaling:NSImageScaleProportionallyUpOrDown];
    [_pop_translate setAction:@selector(translate:)];
    [[_pop_github cell] setImageScaling:NSImageScaleProportionallyUpOrDown];
    [_pop_github setAction:@selector(visit_github:)];
    [_pop_email setImage:[NSImage imageNamed:NSImageNameUserAccounts]];
    [[_pop_email cell] setImageScaling:NSImageScaleProportionallyUpOrDown];
    [_pop_email setAction:@selector(send_email:)];
    
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    [_appName setStringValue:[infoDict objectForKey:@"CFBundleExecutable"]];
    [_appVersion setStringValue:[NSString stringWithFormat:@"Version %@ (%@)", [infoDict objectForKey:@"CFBundleShortVersionString"], [infoDict objectForKey:@"CFBundleVersion"]]];
    [_appCopyright setStringValue:@"Copyright © 2015 - 2016 Wolfgang Baird"];

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
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CDToolTips"])
    {
        NSToolTipManager *test = [NSToolTipManager sharedToolTipManager];
        [test setInitialToolTipDelay:0.1];
    } else {
        NSToolTipManager *test = [NSToolTipManager sharedToolTipManager];
        [test setInitialToolTipDelay:2.0];
    }
    
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
    
    [self setupThemes];     // Install themes
    [self addLoginItem];    // Add login item
    [self setupTheme];      // Setup themeview
    [self setupActions];    // Setup actions
    
    // Update things
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"SUHasLaunchedBefore"])
    {
        [_myUpdater setAutomaticallyChecksForUpdates:true];
        [_myUpdater setAutomaticallyDownloadsUpdates:true];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SUEnableAutomaticChecks"])
    {
        NSLog(@"Checking for updates...");
        [_myUpdater checkForUpdatesInBackground];
    }

    // Setup tabview
    long osx_version = [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion;
    NSString *rootless = nil;
    NSTabViewItem *editTab = [_tabView tabViewItemAtIndex:0];
    [[_tabView tabViewItemAtIndex:1] setView:_dockView];
    [[_tabView tabViewItemAtIndex:2] setView:_prefView];
    [[_tabView tabViewItemAtIndex:3] setView:_aboutView];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:@"/System/Library/ScriptingAdditions/SIMBL.osax"])
    {        
        if (osx_version >= 11)
        {
            // Rootless check
            rootless = [self runCommand:@"touch /System/test 2>&1"];
            if ([rootless containsString:@"Operation not permitted"])
            {
                [editTab setView:_rootlView];   // Add rootless tab
            }
            else
            {
                [editTab setView:_simblView];   // Add SIMBL tab
            }
        }
        else
        {
            [editTab setView:_simblView];       // Add SIMBL tab
        }
    }
    else
    {
        [self launch_helper];                   // Launch dock agent
        [editTab setView:_themeView];           // Add theme tab
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"CDStartTab"]) {
        NSArray *tabs = [[NSArray alloc] initWithObjects:_viewTab0, _viewTab1, _viewTab2, _viewTab3, nil];
        [self selectView:[tabs objectAtIndex:[[[NSUserDefaults standardUserDefaults] objectForKey:@"CDStartTab"] integerValue]]];
    } else {
        [self selectView:_viewTab0];
    }
//    [_tabView selectTabViewItemAtIndex:0];
    
    // Resize buttons for translations and tooltips
    for (NSButton *btn in [_themeView subviews])
    {
        if (btn.class != NSClassFromString(@"NSPopUpButton"))
                if ([btn respondsToSelector:@selector(sizeToFit)])
                    [btn sizeToFit];
    }
    
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"executionTime = %f", executionTime);
    
    [[NSRunningApplication currentApplication] activateWithOptions:(NSApplicationActivateAllWindows | NSApplicationActivateIgnoringOtherApps)];
    PFMoveToApplicationsFolderIfNecessary();    // Offer to the move the Application if necessary.
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CDRememberWindow"])
        [_window saveFrameUsingName:@"MainWindow"];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}

- (void)setupThemes {
    NSString* srcPath = @"";
    NSError* error;
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
}

- (void)sendNotification {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"Hello, World!";
    notification.informativeText = [NSString stringWithFormat:@"details details details"];
    notification.soundName = NSUserNotificationDefaultSoundName;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (IBAction)changeAutoUpdates:(id)sender {
    int selected = (int)[(NSPopUpButton*)sender indexOfSelectedItem];
    if (selected == 0)
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:false] forKey:@"SUEnableAutomaticChecks"];
    if (selected == 1)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true] forKey:@"SUEnableAutomaticChecks"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:false] forKey:@"SUAutomaticallyUpdate"];
    }
    if (selected == 2)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true] forKey:@"SUEnableAutomaticChecks"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true] forKey:@"SUAutomaticallyUpdate"];
    }
}

- (IBAction)changeUpdateFrequency:(id)sender {
    int selected = (int)[(NSPopUpButton*)sender selectedTag];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:selected] forKey:@"SUScheduledCheckInterval"];
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
    [prefCD setObject:_cd_themePicker.selectedItem.title forKey:@"cd_theme"];
    NSMutableDictionary *tmpPlist0 = prefCD;
    [tmpPlist0 writeToFile:plist_cDock atomically:YES];
    
    [self setupTheme];
    [self applyChanges:nil];
}

- (IBAction)selectView:(id)sender {
    NSArray *tabs = [NSArray arrayWithObjects:_viewTab0, _viewTab1, _viewTab2, _viewTab3, nil];
    if ([tabs containsObject:sender])
        [_tabView selectTabViewItemAtIndex:[tabs indexOfObject:sender]];
    for (NSButton *g in tabs) {
        if ([[NSProcessInfo processInfo] operatingSystemVersion].minorVersion < 10) {
            if (![g isEqualTo:sender])
                [[g cell] setBackgroundColor:[NSColor whiteColor]];
            else
                [[g cell] setBackgroundColor:[NSColor colorWithCalibratedRed:0.121f green:0.4375f blue:0.1992f alpha:1.0000f]];
        } else {
            if (![g isEqualTo:sender])
                g.layer.backgroundColor = [NSColor clearColor].CGColor;
            else
                g.layer.backgroundColor =  [NSColor colorWithCalibratedRed:0.121f green:0.4375f blue:0.1992f alpha:0.2578f].CGColor;
        }
        
    }
}

- (IBAction)toggle_RememberWindow:(id)sender {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"CDRememberWindow"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true] forKey:@"CDRememberWindow"];
        [[_window windowController] setShouldCascadeWindows:NO];      // Tell the controller to not cascade its windows.
        [_window setFrameAutosaveName:[_window representedFilename]];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:false] forKey:@"CDRememberWindow"];
        [_window setFrameAutosaveName:@""];
    }
}

- (IBAction)toggle_Donate:(id)sender {
    NSButton *btn = sender;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[btn state]] forKey:@"CDHideDonate"];
    if ([btn state])
    {
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:1.0];
        [[_pop_paypal animator] setAlphaValue:0];
        [[_pop_paypal animator] setHidden:true];
        [NSAnimationContext endGrouping];
    } else {
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:1.0];
        [[_pop_paypal animator] setAlphaValue:1];
        [[_pop_paypal animator] setHidden:false];
        [NSAnimationContext endGrouping];
    }
}

- (IBAction)tooltipToggle:(id)sender {
    NSToolTipManager *test = [NSToolTipManager sharedToolTipManager];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"CDToolTips"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true] forKey:@"CDToolTips"];
        [test setInitialToolTipDelay:0.1];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:false] forKey:@"CDToolTips"];
        [test setInitialToolTipDelay:2];
    }
}

- (IBAction)showAboutWindow:(id)sender {
    [self selectView:_viewTab3];
}

- (IBAction)showPreferences:(id)sender {
    [self selectView:_viewTab2];
}

- (IBAction)simblInstall:(id)sender {
    NSArray *apps = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"org.w0lf.cDockHelper"];
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
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://goo.gl/DSyEFR"]];
}

- (IBAction)visit_website:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://w0lfschild.github.io/app_cDock.html"]];
}

- (IBAction)visit_github:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/w0lfschild"]];
}

- (IBAction)visit_source:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/w0lfschild/cDock2"]];
}

- (IBAction)show_themes:(id)sender {
    NSURL *folderURL = [NSURL fileURLWithPath: curThemFldr];
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

- (IBAction)deleteTheme:(id)sender {
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:curThemFldr error:&error];
    if (error.code != NSFileNoSuchFileError) {
        NSLog(@"%@", error);
    }
    [self setupTheme];
    [self applyChanges:nil];
}

- (IBAction)deleteThemeFolder:(id)sender {
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:themeFldr error:&error];
    if (error.code != NSFileNoSuchFileError) {
        NSLog(@"%@", error);
    }
    [self setupTheme];
    [self dirCheck:themeFldr];
    [self setupThemes];
    [self setupTheme];
    [self applyChanges:nil];
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
            if (![[_window.contentView subviews] containsObject:vibrant])
                [[_window contentView] addSubview:vibrant positioned:NSWindowBelow relativeTo:nil];
        } else {
            for (NSVisualEffectView *v in (NSMutableArray *)[_window.contentView subviews])
            {
                if ([v class] == vibrantClass) {
                    [v removeFromSuperview];
                    break;
                }
            }
        }
    }
}

- (IBAction)translate:(id)sender {
    NSString *myURL = [[NSBundle mainBundle] pathForResource:@"MyApp" ofType:@"strings"];
    [[NSWorkspace sharedWorkspace] openFile:myURL];
}

- (IBAction)send_email:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:aguywithlonghair@gmail.com"]];
}

- (IBAction)aboutInfo:(id)sender {
    if ([sender isEqualTo:_showChanges])
    {
        [_cdock_changeLog setEditable:true];
        [[_cdock_changeLog textStorage] setAttributedString:[[NSAttributedString alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"changelog" ofType:@"rtf"] documentAttributes:nil]];
        [_cdock_changeLog selectAll:self];
        [_cdock_changeLog alignLeft:nil];
        [_cdock_changeLog setSelectedRange:NSMakeRange(0,0)];
        [_cdock_changeLog setEditable:false];
        
        [NSAnimationContext beginGrouping];
        NSClipView* clipView = [[_cdock_changeLog enclosingScrollView] contentView];
        NSPoint newOrigin = [clipView bounds].origin;
        newOrigin.y = 0;
        [[clipView animator] setBoundsOrigin:newOrigin];
        [NSAnimationContext endGrouping];
    }
    if ([sender isEqualTo:_showCredits])
    {
        [_cdock_changeLog setEditable:true];
        [[_cdock_changeLog textStorage] setAttributedString:[[NSAttributedString alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"rtf"] documentAttributes:nil]];
        [_cdock_changeLog selectAll:self];
        [_cdock_changeLog alignCenter:nil];
        [_cdock_changeLog setSelectedRange:NSMakeRange(0,0)];
        [_cdock_changeLog setEditable:false];
    }
    if ([sender isEqualTo:_showEULA])
    {
        [[_cdock_changeLog textStorage] setAttributedString:[[NSAttributedString alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"EULA" ofType:@"rtf"] documentAttributes:nil]];
        
        [NSAnimationContext beginGrouping];
        NSClipView* clipView = [[_cdock_changeLog enclosingScrollView] contentView];
        NSPoint newOrigin = [clipView bounds].origin;
        newOrigin.y = 0;
        [[clipView animator] setBoundsOrigin:newOrigin];
        [NSAnimationContext endGrouping];
    }
}

- (IBAction)toggleStartTab:(id)sender {
    NSPopUpButton *btn = sender;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:[btn indexOfSelectedItem]] forKey:@"CDStartTab"];
}

- (IBAction)restartDock:(id)sender {
    system("killall Dock; sleep 2; osascript -e 'tell application \"Dock\" to inject SIMBL into Snow Leopard'");
}

@end
