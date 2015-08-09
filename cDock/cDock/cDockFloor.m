//
//  cDockFloor.m
//

#import "Preferences.h"
#import "fishhook.h"
#import "ZKSwizzle.h"
#import <dlfcn.h>
@import AppKit;

# define dockPath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.apple.dock.plist"]
# define thmePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/org.w0lf.cDock.plist"]
# define thmeName [[NSMutableDictionary dictionaryWithContentsOfFile:thmePath] objectForKey:@"cd_theme"]
# define prefPath [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/cDock/themes/"] stringByAppendingPathComponent:thmeName]
# define prefFile [[prefPath stringByAppendingPathComponent:thmeName ] stringByAppendingString:@".plist"]

NSInteger orient = 0;
long osx_minor = 0;

@interface Tile : NSObject
- (void)setSelected:(BOOL)arg1;
- (void)setLabel:(id)arg1 stripAppSuffix:(_Bool)arg2;
@end

@interface _CDDOCKFloorLayer : CALayer
@end

void _setupPrefs() {
    if (![[NSFileManager defaultManager] fileExistsAtPath:thmePath]) {
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        
        [newDict setObject:[NSNumber numberWithBool:false] forKey:@"cd_enabled"];
        [newDict setObject:@"default" forKey:@"cd_theme"];
        
        [newDict writeToFile:thmePath atomically:NO];
    }
    
    // Make sure hide-mirror = true for 10.9 but just do it on all versions anyways
    if ([[NSFileManager defaultManager] fileExistsAtPath:dockPath]) {
        NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:dockPath];
        if ([[ plist objectForKey:@"hide-mirror"] boolValue] == false) {
            system("defaults write com.apple.dock hide-mirror -bool TRUE");
            plist = [NSMutableDictionary dictionaryWithContentsOfFile:dockPath];
            if ([[ plist objectForKey:@"hide-mirror"] boolValue] == true) {
                system("killall -KILL Dock; sleep 1; osascript -e \"tell application \"Dock\" to inject SIMBL into Snow Leopard\"");
            }
        }
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:prefFile]) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:prefPath]) {
            NSError * error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath: prefPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:&error];
        }
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        
        // There are so many of these I need to add here....
        
        // Stuff
        [newDict setObject:[NSNumber numberWithBool:false] forKey:@"cd_fullWidth"];
        [newDict setObject:[NSNumber numberWithBool:false] forKey:@"cd_hideLabels"];
        [newDict setObject:[NSNumber numberWithBool:false] forKey:@"cd_darkenMouseOver"];
        [newDict setObject:[NSNumber numberWithBool:false] forKey:@"cd_customIndicator"];
        [newDict setObject:[NSNumber numberWithBool:false] forKey:@"cd_iconReflection"];
        [newDict setObject:[NSNumber numberWithBool:false] forKey:@"cd_isTransparent"];
        [newDict setObject:[NSNumber numberWithInt:0] forKey:@"cd_darkMode"];
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_cornerRadius"];
        
        // Default layers
        [newDict setObject:[NSNumber numberWithBool:true] forKey:@"cd_showFrost"];
        [newDict setObject:[NSNumber numberWithBool:true] forKey:@"cd_showGlass"];
        [newDict setObject:[NSNumber numberWithBool:true] forKey:@"cd_showSeparator"];
        
        // Icon shadows
        [newDict setObject:[NSNumber numberWithBool:false] forKey:@"cd_iconShadow"];
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_iconShadowBGR"];
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_iconShadowBGG"];
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_iconShadowBGB"];
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_iconShadowBGA"];  // Alpha
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_iconShadowBGS"];  // Size
        
        // Dock background coloring
        [newDict setObject:[NSNumber numberWithBool:false] forKey:@"cd_dockBG"];
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_dockBGR"];
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_dockBGG"];
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_dockBGB"];
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_dockBGA"];
        
        // Label background coloring
        [newDict setObject:[NSNumber numberWithBool:false] forKey:@"cd_labelBG"];
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_labelBGR"];
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_labelBGG"];
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_labelBGB"];
        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_labelBGA"];
        
        [newDict writeToFile:prefFile atomically:NO];
    }
}

// Fix for icon shadows / reflection layer not intializing on their own...
void _loadShadows(CALayer* layer) {
    static dispatch_once_t once;
    dispatch_once(&once, ^ {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        SEL aSel = @selector(layoutSublayers);
        NSArray *tileLayers = layer.superlayer.sublayers;
        for (CALayer *item in tileLayers)
            if (item.class == NSClassFromString(@"DOCKTileLayer")) {
                if ([item respondsToSelector:aSel])
                    [item performSelector:aSel];
            }
        NSLog(@"Shadows and reflections initialized...");
        });
    });
}

// OS X 10.9 Mavericks implementation
void _TenNine(CALayer* layer) {
    if (![[[Preferences sharedInstance2] objectForKey:@"cd_enabled"] boolValue])
        return;
    
    _loadShadows(layer);
    
    object_getInstanceVariable(layer, "_orientation", (void **)&orient);
    
    if (orient == 0) {
        // Remove system icon reflection implementation
        SEL aSel = NSSelectorFromString(@"removeShadowAndReflectionLayers");
        NSArray *tileLayers = [layer.superlayer.sublayers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(id evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject respondsToSelector:aSel];
        }]];
        [tileLayers makeObjectsPerformSelector:aSel];
    }
    
    // Hook some layers
    CALayer *_separatorLayer = ZKHookIvar(layer, CALayer *, "_separatorLayer");
    CALayer *_glass = ZKHookIvar(layer, CALayer *, "_glassLayer");
    
    // Just because
    CALayer *_superLayer = layer;
    
    // Custom layers
    CALayer *_backgroundLayer = nil;
    CALayer *_borderLayer = nil;
    
    // Look for custom layers
    for (CALayer *item in (NSMutableArray *)_superLayer.sublayers)
    {
        if ([item.name isEqual:@"_backgroundLayer"])
            _backgroundLayer = item;
        if ([item.name isEqual:@"_borderLayer"])
            _borderLayer = item;
    }
    
    // initialize border layer
    if (_borderLayer == nil)
    {
        _borderLayer = [[CALayer alloc] init];
        [ _borderLayer setName:(@"_borderLayer")];
        [ _superLayer addSublayer:_borderLayer ];
    }
    
    // initialize background layer
    if (_backgroundLayer == nil)
    {
        _backgroundLayer = [[CALayer alloc] init];
        [ _backgroundLayer setName:(@"_backgroundLayer")];
        [ _superLayer addSublayer:_backgroundLayer ];
    }
    
    float brdSize = [[[Preferences sharedInstance] objectForKey:@"cd_borderSize"] floatValue];
    float cornerSize = [[[Preferences sharedInstance] objectForKey:@"cd_cornerRadius"] floatValue];
    float alpha = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGA"] floatValue];
    CGRect rect = _superLayer.bounds;
    
    // Picture background
    if ([[[Preferences sharedInstance] objectForKey:@"cd_pictureBG"] boolValue]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *picFile = nil;
        
        // Check orientation
        if (orient == 0)
        {
            picFile = [NSString stringWithFormat:@"%@/background.png", prefPath];
        }
        else
        {
            picFile = [NSString stringWithFormat:@"%@/background1.png", prefPath];
        }
        
        // If custom background exists apply
        if ([fileManager fileExistsAtPath:picFile])
        {
            // we should initialize this image somewhere else and only 1 time
            if ([[[Preferences sharedInstance] objectForKey:@"cd_pictureTile"] boolValue]) {
                [ _backgroundLayer setBackgroundColor:[[NSColor colorWithPatternImage:[[[NSImage alloc] initWithContentsOfFile:picFile] autorelease]] CGColor] ];
            } else {
                _backgroundLayer.contents = [[[NSImage alloc] initWithContentsOfFile:picFile] autorelease];
            }
            [ _superLayer setSublayers:[NSArray arrayWithObjects: _backgroundLayer, _separatorLayer, nil] ];
        }
    }
    
    // Color background
    if ([[[Preferences sharedInstance] objectForKey:@"cd_dockBG"] boolValue]) {
        float red = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGR"] floatValue];
        float green = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGG"] floatValue];
        float blue = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGB"] floatValue];
        NSColor *goodColor = [NSColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
        [_backgroundLayer setBackgroundColor:[goodColor CGColor]];
    }
    
    // Full width dock
    if ([[[Preferences sharedInstance] objectForKey:@"cd_fullWidth"] boolValue]) {
        // Best to avoid += or -= used to keep incrementally grow forever
        if (orient == 0) {
            rect.size.width = [[NSScreen mainScreen] frame].size.width * 2;
            rect.origin.x = -([[NSScreen mainScreen] frame].size.width / 2);
        } else {
            rect.size.height = [[NSScreen mainScreen] frame].size.height * 2;
            rect.origin.y = -([[NSScreen mainScreen] frame].size.height);
        }
    }
    
    // Resize
    if (orient == 0) {
        rect.size.height = rect.size.height * 1.65;
        if (rect.size.height < 40)
            rect.size.height = rect.size.height * .9;
    }
    
    // Border layer
    if (brdSize > 0) {
        CGRect newFrame = _backgroundLayer.frame;
        newFrame.origin.x -= brdSize;
        newFrame.size.width += brdSize * 2;
        newFrame.origin.y -= brdSize;
        newFrame.size.height += brdSize * 2;
        float red = [[[Preferences sharedInstance] objectForKey:@"cd_borderBGR"] floatValue];
        float green = [[[Preferences sharedInstance] objectForKey:@"cd_borderBGG"] floatValue];
        float blue = [[[Preferences sharedInstance] objectForKey:@"cd_borderBGB"] floatValue];
        [ _borderLayer setFrame:newFrame];
        [ _borderLayer setBackgroundColor:[[NSColor clearColor] CGColor]];
        [ _borderLayer setBorderColor:[[NSColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0] CGColor]];
        [ _borderLayer setOpacity:[[[Preferences sharedInstance] objectForKey:@"cd_borderBGA"] floatValue]];
        [ _borderLayer setBorderWidth:brdSize];
        [ _borderLayer setHidden:false];
    }

    // rounded corners
    if (cornerSize > (float)0) {
        // Not sure if there is some exact math but this mitigates the gap between the corner of the background layers and the border layer showing
        if (brdSize > 0) {
            if (brdSize < 2) brdSize = 2;
            [ _backgroundLayer setCornerRadius:cornerSize / brdSize ];
        } else {
            [ _backgroundLayer setCornerRadius:cornerSize ];
        }
        
        [ _borderLayer setCornerRadius:cornerSize ];
        
        if (orient == 0) {
            rect.size.height += cornerSize;
            rect.origin.y -= cornerSize;
        } else {
            rect.size.width += cornerSize;
        }
        if (orient == 1) {
            rect.origin.x -= cornerSize;
        }
    }
    
    [ _backgroundLayer setFrame:rect ];
    [ _backgroundLayer setOpacity:(alpha / 100.0)];
    
    // Custom separtor this does not work well
    if ([[[Preferences sharedInstance] objectForKey:@"cd_dockSeparator"] boolValue]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *picFile = [NSString stringWithFormat:@"%@/separator.png", prefPath];
        if ([fileManager fileExistsAtPath:picFile])
        {
            rect = _separatorLayer.frame;
            rect.origin.y *= -0.1;
            rect.size.height = [_superLayer frame].size.height * 0.8 - cornerSize;
            rect.size.width = [_superLayer frame].size.width / 100;
            rect.size.height *= 2;
            _separatorLayer.frame = rect;
            NSString *picFile = [NSString stringWithFormat:@"%@/separator.png", prefPath];
            _separatorLayer.opacity = 1;
            _separatorLayer.contents = [[[NSImage alloc] initWithContentsOfFile:picFile] autorelease];
//            _separatorLayer.backgroundColor = [[NSColor colorWithRed:255 green:0 blue:0 alpha:1] CGColor];
//            _separatorLayer.minificationFilter = nil;
//            NSLog(@"%@", _separatorLayer.debugDescription);
        }
    }
    
    // Hide layers
    if (![[[Preferences sharedInstance] objectForKey:@"cd_showGlass"] boolValue])
        _glass.hidden = true;
    if (![[[Preferences sharedInstance] objectForKey:@"cd_showSeparator"] boolValue])
        _separatorLayer.hidden = true;
    if ([[[Preferences sharedInstance] objectForKey:@"cd_isTransparent"] boolValue])
        [ _superLayer setSublayers:[NSArray arrayWithObjects:_separatorLayer, nil] ];
}

@interface initialize : CALayer
@end
@implementation initialize

+ (void)load {
    
    // Create prefs if they don't exist
    _setupPrefs();
    
    // Read system version
    osx_minor = [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion;
    
    // Swizzle based on OSX version
    if (osx_minor == 11)
        ZKSwizzle(_CDDOCKFloorLayer, Dock.FloorLayer);
    if (osx_minor == 10)
        ZKSwizzle(_CDDOCKFloorLayer, DOCKFloorLayer);
    if (osx_minor == 9) {
        ZKSwizzle(_CDMAVFloor, DOCKGlassFloorLayer);
        ZKSwizzle(_CDMAVSide, DOCKSideGlassFloorLayer);
    }
    
    // Something tells me I could do this without fishhook if I already have ZKSwizzle
    // But I don't really know what's going on here
    if (osx_minor > 9) {
        orig_CFPreferencesCopyAppValue = dlsym(RTLD_DEFAULT, "CFPreferencesCopyAppValue");
        rebind_symbols((struct rebinding[1]){{"CFPreferencesCopyAppValue", hax_CFPreferencesCopyAppValue}}, 1);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("AppleInterfaceThemeChangedNotification"), (void *)0x1, NULL, YES);
        });
    }
    
    NSLog(@"OS X 10.%li, cDock loaded...", osx_minor);
}

// Force dock into dark or light mode
static id (*orig_CFPreferencesCopyAppValue)(CFStringRef key, CFStringRef applicationID);
id hax_CFPreferencesCopyAppValue(CFStringRef key, CFStringRef applicationID) {
//    NSLog(@"Key: %@, Original Value: %@", key, orig_CFPreferencesCopyAppValue(key, applicationID));
    if ([(__bridge NSString *)key isEqualToString:@"AppleInterfaceTheme"] || [(__bridge NSString *)key isEqualToString:@"AppleInterfaceStyle"]) {
        if ([[[Preferences sharedInstance] objectForKey:@"cd_darkMode"] intValue] == 1) {
            return @"Light";
        } else if ([[[Preferences sharedInstance] objectForKey:@"cd_darkMode"] intValue] == 2) {
            return @"Dark";
        } else if ([[[Preferences sharedInstance] objectForKey:@"cd_darkMode"] intValue] == 3) {
            if ([orig_CFPreferencesCopyAppValue(key, applicationID)  isEqual: @"Dark"]) {
                return @"Light";
            } else {
                return @"Dark";
            }
        } else {
            return orig_CFPreferencesCopyAppValue(key, applicationID);
        }
    } else {
        return orig_CFPreferencesCopyAppValue(key, applicationID);
    }
}
@end

@interface _CDMAVSide : CALayer
@end
@implementation _CDMAVSide
- (void)layoutSublayers {
    ZKOrig(void);
    _TenNine(self);
}
@end

@interface _CDMAVFloor : CALayer
@end
@implementation _CDMAVFloor
- (void)layoutSublayers {
    ZKOrig(void);
    _TenNine(self);
}
@end

// OS X 10.10 Yosemite and 10.11 El Capitan implementation
@implementation _CDDOCKFloorLayer
- (void)layoutSublayers {
    ZKOrig(void);
    
    // Do nothing if not enabled
    if (![[[Preferences sharedInstance2] objectForKey:@"cd_enabled"] boolValue])
        return;
    
    // Fix for icon shadows / reflection layer not intializing on their own...
    _loadShadows(self);

    // Update dock orientation
    if (osx_minor == 11) {
        orient = ZKHookIvar(self, NSInteger, "orientation");
    } else {
        object_getInstanceVariable(self, "_orientation", (void **)&orient);
    }

    // Hook some layers
    CALayer *_materialLayer = ZKHookIvar(self, CALayer *, "_materialLayer");
    CALayer *_glassLayer = ZKHookIvar(self, CALayer *, "_glassLayer");
    CALayer *_separatorLayer = ZKHookIvar(self, CALayer *, "_separatorLayer");
    
    // Just for kicks
    CALayer *_superLayer = self;
    
    // Custom layers
    CALayer *_borderLayer = nil;
    CALayer *_backgroundLayer = nil;
    
    // Look for custom layers
    for (CALayer *item in (NSMutableArray *)_superLayer.sublayers)
    {
        if ([item.name isEqual:@"_borderLayer"])
            _borderLayer = item;
        if ([item.name isEqual:@"_backgroundLayer"])
            _backgroundLayer = item;
    }
    
    // initialize border layer
    if (_borderLayer == nil)
    {
        _borderLayer = [[CALayer alloc] init];
        [ _borderLayer setName:(@"_borderLayer")];
        [ _superLayer addSublayer:_borderLayer ];
    }
    
    // initialize background layer
    if (_backgroundLayer == nil)
    {
        _backgroundLayer = [[CALayer alloc] init];
        [ _backgroundLayer setHidden:false ];
        [ _backgroundLayer setName:(@"_backgroundLayer")];
        [ _superLayer addSublayer:_backgroundLayer ];
    }
    
    // Read corner radius
    float cornerSize = [[[Preferences sharedInstance] objectForKey:@"cd_cornerRadius"] floatValue];
    
    // Lets make the frost layer rectangular by default
    _materialLayer.cornerRadius = 0;
    _materialLayer.borderWidth = 0;

    // Picture background
    if ([[[Preferences sharedInstance] objectForKey:@"cd_pictureBG"] boolValue]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *picFile = nil;
        
        // Check orientation
        if (orient == 0)
        {
            picFile = [NSString stringWithFormat:@"%@/background.png", prefPath];
        }
        else
        {
            picFile = [NSString stringWithFormat:@"%@/background1.png", prefPath];
        }
        
        // If custom background exists apply
        if ([fileManager fileExistsAtPath:picFile])
        {
            if ([[[Preferences sharedInstance] objectForKey:@"cd_pictureTile"] boolValue])
            {
                [ _backgroundLayer setBackgroundColor:[[NSColor colorWithPatternImage:[[[NSImage alloc] initWithContentsOfFile:picFile] autorelease]] CGColor] ];
            }
            else
            {
                _backgroundLayer.contents = [[[NSImage alloc] initWithContentsOfFile:picFile] autorelease];
            }
            
            // Set self sublayers to _backgroundLayer and _serparatorLayer
            // Make sure _sepraratorLayer is on top
            [ _superLayer setSublayers:[NSArray arrayWithObjects:_backgroundLayer, _separatorLayer, nil] ];
        }
    }

    // Color background layer
    if ([[[Preferences sharedInstance] objectForKey:@"cd_dockBG"] boolValue]) {
        float red = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGR"] floatValue];
        float green = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGG"] floatValue];
        float blue = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGB"] floatValue];
        float alpha = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGA"] floatValue];
        NSColor *goodColor = [NSColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
        [_backgroundLayer setBackgroundColor:[goodColor CGColor]];
        [_backgroundLayer setOpacity:(alpha / 100.0)];
    }

    // Full width dock
    if ([[[Preferences sharedInstance] objectForKey:@"cd_fullWidth"] boolValue]) {
        CGRect rect = _superLayer.bounds;
        
        // Best to avoid += or -= used to keep incrementally grow forever
        if (orient == 0) {
            rect.size.width = [[NSScreen mainScreen] frame].size.width * 2;
            rect.origin.x = -([[NSScreen mainScreen] frame].size.width / 2);
        } else {
            rect.size.height = [[NSScreen mainScreen] frame].size.height * 2;
            rect.origin.y = -([[NSScreen mainScreen] frame].size.height);
        }
        
        [ _materialLayer setFrame: rect ];
//        [ _superLayer setFrame: rect ];
    }
    
    // Border layer
    float brdSize = [[[Preferences sharedInstance] objectForKey:@"cd_borderSize"] floatValue];
    if (brdSize > 0) {
        CGRect newFrame = _backgroundLayer.frame;
        newFrame.origin.x -= brdSize;
        newFrame.size.width += brdSize * 2;
        newFrame.origin.y -= brdSize;
        newFrame.size.height += brdSize * 2;
        float red = [[[Preferences sharedInstance] objectForKey:@"cd_borderBGR"] floatValue];
        float green = [[[Preferences sharedInstance] objectForKey:@"cd_borderBGG"] floatValue];
        float blue = [[[Preferences sharedInstance] objectForKey:@"cd_borderBGB"] floatValue];
        [ _borderLayer setFrame:newFrame];
        [ _borderLayer setBackgroundColor:[[NSColor clearColor] CGColor]];
        [ _borderLayer setBorderColor:[[NSColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0] CGColor]];
        [ _borderLayer setOpacity:([[[Preferences sharedInstance] objectForKey:@"cd_borderBGA"] floatValue] / 100.0)];
        [ _borderLayer setBorderWidth:brdSize];
        [ _borderLayer setHidden:false];
    }
    
    // rounded corners
    if (cornerSize > (float)0) {
        CGRect rect = _superLayer.bounds;
        
        // Not sure if there is some exact math but this mitigates the gap between the corner of the background layers and the border layer showing
        if (brdSize > 0) {
            if (brdSize < 2) brdSize = 2;
            [ _backgroundLayer setCornerRadius:cornerSize / brdSize ];
            [ _materialLayer setCornerRadius:cornerSize / brdSize ];
        } else {
            [ _backgroundLayer setCornerRadius:cornerSize ];
            [ _materialLayer setCornerRadius:cornerSize ];
        }
        
        [ _borderLayer setCornerRadius:cornerSize ];
        
        // Couldn't figure out how to adjust this layers corners so lets hide it
        _glassLayer.hidden = YES;
        
        if (orient == 0) {
            rect.size.height += cornerSize;
            rect.origin.y -= cornerSize;
        } else {
            rect.size.width += cornerSize;
        }
        if (orient == 1) {
            rect.origin.x -= cornerSize;
        }
        
        [ _materialLayer setFrame:rect ];
    }
    
    // background layer should have same frame as frost layer
    [ _backgroundLayer setFrame: _materialLayer.frame];
    
    // Pinning except the actual clickable tile areas don't move, not sure how to do that...
//        CGRect r1 = _superLayer.bounds;
//        rect = _superLayer.superlayer.frame;
//        rect.origin.x = -([[NSScreen mainScreen] frame].size.width - r1.size.width) / 2;
//        _superLayer.superlayer.frame = rect;
//        NSLog(@"%@",  _superLayer.superlayer.debugDescription);

    // Hide layers if we want to
    if (![[[Preferences sharedInstance] objectForKey:@"cd_showFrost"] boolValue])
        _materialLayer.hidden = YES;

    if (![[[Preferences sharedInstance] objectForKey:@"cd_showGlass"] boolValue]) {
        _glassLayer.hidden = YES;
    } else {
        if ([[[Preferences sharedInstance] objectForKey:@"cd_fullWidth"] boolValue])
            _glassLayer.hidden = YES;
        if ([[[Preferences sharedInstance] objectForKey:@"cd_dockBG"] boolValue])
            _glassLayer.hidden = YES;
    }

    if (![[[Preferences sharedInstance] objectForKey:@"cd_showSeparator"] boolValue])
        _separatorLayer.hidden = YES;

    // Setting sublayer to just the separator seems to work nice for this
    if ([[[Preferences sharedInstance] objectForKey:@"cd_isTransparent"] boolValue])
        [ _superLayer setSublayers:[NSArray arrayWithObjects:_separatorLayer, nil] ];
}
@end