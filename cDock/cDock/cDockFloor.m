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
                system("killall -KILL Dock; sleep 1; osascript -e 'tell application \"Dock\" to inject SIMBL into Snow Leopard'");
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
        
        //        Dock background frame adjustments x pos, y pos, width, height
        //        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_increaseX"];
        //        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_increaseY"];
        //        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_increaseW"];
        //        [newDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"cd_increaseH"];
        
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
    
    CALayer *_separatorLayer = ZKHookIvar(layer, CALayer *, "_separatorLayer");
    CALayer *_glass = ZKHookIvar(layer, CALayer *, "_glassLayer");
    CALayer *_superLayer = layer;
    CALayer *_rl = [[CALayer alloc] init];
    
    [ _rl setName:(@"_rl")];
    
    if (![[[Preferences sharedInstance] objectForKey:@"cd_showGlass"] boolValue])
        _glass.contents = nil;
    
    float alpha = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGA"] floatValue];
    CGRect rect = _superLayer.bounds;
    
    if ([[[Preferences sharedInstance] objectForKey:@"cd_pictureBG"] boolValue]) {
        NSString *picFile = nil;
        if (orient == 0) {
            picFile = [NSString stringWithFormat:@"%@/background.png", prefPath];
        } else {
            picFile = [NSString stringWithFormat:@"%@/background1.png", prefPath];
        }
        
        // We should only do this if file exists !
        if ([[[Preferences sharedInstance] objectForKey:@"cd_pictureTile"] boolValue]) {
            [ _rl setBackgroundColor:[[NSColor colorWithPatternImage:[[[NSImage alloc] initWithContentsOfFile:picFile] autorelease]] CGColor] ];
        } else {
            _rl.contents = [[[NSImage alloc] initWithContentsOfFile:picFile] autorelease];
        }
        [ _superLayer setSublayers:[NSArray arrayWithObjects:_separatorLayer, nil] ];
    }
    
    if ([[[Preferences sharedInstance] objectForKey:@"cd_dockBG"] boolValue]) {
        float red = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGR"] floatValue];
        float green = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGG"] floatValue];
        float blue = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGB"] floatValue];
        NSColor *goodColor = [NSColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
        [_rl setBackgroundColor:[goodColor CGColor]];
    }
    
    if ([[[Preferences sharedInstance] objectForKey:@"cd_fullWidth"] boolValue]) {
        if (orient == 0) {
            rect.size.width = [[NSScreen mainScreen] frame].size.width * 2;
            rect.origin.x -= [[NSScreen mainScreen] frame].size.width;
        } else {
            rect.size.height = [[NSScreen mainScreen] frame].size.height * 2;
            rect.origin.y -= [[NSScreen mainScreen] frame].size.height;
        }
    }
    
    // Resize
    if (orient == 0)
        rect.size.height = rect.size.height * 1.65;
    float cornerSize = [[[Preferences sharedInstance] objectForKey:@"cd_cornerRadius"] floatValue];
    if (cornerSize > (float)0) {
        [ _rl setCornerRadius:cornerSize ];
        if (orient == 0) {
            rect.size.height += cornerSize;
            rect.origin.y -= cornerSize;
        } else {
            rect.size.width += cornerSize;
            if (orient == 1)
                rect.origin.x -= cornerSize;
        }
    }
    [ _rl setFrame:rect ];
    [ _rl setOpacity:(alpha / 100.0)];
    
    if ([[[Preferences sharedInstance] objectForKey:@"cd_dockSeparator"] boolValue]) {
        rect = _separatorLayer.frame;
        rect.origin.y *= -0.1;
        rect.size.height = [_superLayer frame].size.height * 0.8 - cornerSize;
        rect.size.width = [_superLayer frame].size.width / 100;
        rect.size.height *= 2;
        _separatorLayer.frame = rect;
        NSString *picFile = [NSString stringWithFormat:@"%@/separator.png", prefPath];
        _separatorLayer.opacity = 1;
        _separatorLayer.contents = [[[NSImage alloc] initWithContentsOfFile:picFile] autorelease];
        //        _separatorLayer.backgroundColor = [[NSColor colorWithRed:255 green:0 blue:0 alpha:1] CGColor];
        //        _separatorLayer.minificationFilter = nil;
        //        NSLog(@"%@", _separatorLayer.debugDescription);
    }
    
    NSMutableArray *mutableArray = (NSMutableArray *)layer.sublayers;
    for (CALayer *item in mutableArray) {
        if ([item.name  isEqual:@"_rl"]) {
            [item removeFromSuperlayer];
            break;
        }
    }
    [ _superLayer addSublayer:_rl ];
    
    if (![[[Preferences sharedInstance] objectForKey:@"cd_showSeparator"] boolValue])
        _separatorLayer.hidden = YES;
    if ([[[Preferences sharedInstance] objectForKey:@"cd_isTransparent"] boolValue])
        [ _superLayer setSublayers:[NSArray arrayWithObjects:_separatorLayer, nil] ];
}

@interface initialize : NSObject
@end
@implementation initialize

+ (void)load {
    _setupPrefs();
    
    osx_minor = [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion;
    if (osx_minor == 11)
        ZKSwizzle(_CDDOCKFloorLayer, _TtC4Dock10FloorLayer);
    if (osx_minor == 10)
        ZKSwizzle(_CDDOCKFloorLayer, DOCKFloorLayer);
    if (osx_minor == 9) {
        ZKSwizzle(_CDMAVFloor, DOCKGlassFloorLayer);
        ZKSwizzle(_CDMAVSide, DOCKSideGlassFloorLayer);
    }
    
    // Something tells me I could do this without fishhook if I already have opee/zkwizzle
    // Then again I don't really know what's going on here
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
    if ([(__bridge NSString *)key isEqualToString:@"AppleInterfaceTheme"] || [(__bridge NSString *)key isEqualToString:@"AppleInterfaceStyle"]) {
//        NSLog(@"Test");
        if ([[[Preferences sharedInstance] objectForKey:@"cd_darkMode"] intValue] == 1) {
            return @"Light";
        } else if ([[[Preferences sharedInstance] objectForKey:@"cd_darkMode"] intValue] == 2) {
            return @"Dark";
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

@interface _CDDOCKFloorLayer : CALayer
@end
@implementation _CDDOCKFloorLayer
- (void)layoutSublayers {
    ZKOrig(void);
    
    // Do nothing
    if (![[[Preferences sharedInstance2] objectForKey:@"cd_enabled"] boolValue])
        return;
    
    // Fix for icon shadows / reflection layer not intializing on their own...
    _loadShadows(self);

    // Get dock orientation
    if (osx_minor == 11) {
        object_getInstanceVariable(self, "orientation", (void **)&orient);
    } else {
        object_getInstanceVariable(self, "_orientation", (void **)&orient);
    }
    
//    NSLog(@"Dock orientation : %li", (long)orient);

    CALayer *_materialLayer = ZKHookIvar(self, CALayer *, "_materialLayer");
    CALayer *_glassLayer = ZKHookIvar(self, CALayer *, "_glassLayer");
    CALayer *_separatorLayer = ZKHookIvar(self, CALayer *, "_separatorLayer");
    CALayer *_superLayer = self;
    
    // Duplicate the frost layer, I'll use this as our base background layer
    NSData *buffer = [NSKeyedArchiver archivedDataWithRootObject: _materialLayer];
    CALayer *_frostDupe = [NSKeyedUnarchiver unarchiveObjectWithData: buffer];
    [ _frostDupe setName:(@"_frostDupe")];

    // Probably could be done better remove old copy then add new one
    NSMutableArray *mutableArray = (NSMutableArray *)_superLayer.sublayers;
    for (CALayer *item in mutableArray)
        if ([item.name isEqual:@"_frostDupe"]) {
            [item removeFromSuperlayer];
            break;
        }
    [ _superLayer addSublayer:_frostDupe ];
    
    _materialLayer.cornerRadius = 0;
    _materialLayer.borderWidth = 0;

    // Picture background set self background to picture
    if ([[[Preferences sharedInstance] objectForKey:@"cd_pictureBG"] boolValue]) {
        NSString *picFile = nil;
        if (orient == 0) {
            picFile = [NSString stringWithFormat:@"%@/background.png", prefPath];
        } else {
            picFile = [NSString stringWithFormat:@"%@/background1.png", prefPath];
        }
        if ([[[Preferences sharedInstance] objectForKey:@"cd_pictureTile"] boolValue]) {
            [ _materialLayer setBackgroundColor:[[NSColor colorWithPatternImage:[[[NSImage alloc] initWithContentsOfFile:picFile] autorelease]] CGColor] ];
        } else {
            _materialLayer.contents = [[[NSImage alloc] initWithContentsOfFile:picFile] autorelease];
        }
        [ _materialLayer setSublayers:[NSArray arrayWithObjects:_separatorLayer, nil] ];
    }

    // Color background
    if ([[[Preferences sharedInstance] objectForKey:@"cd_dockBG"] boolValue]) {
        float red = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGR"] floatValue];
        float green = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGG"] floatValue];
        float blue = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGB"] floatValue];
        float alpha = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGA"] floatValue];
        NSColor *goodColor = [NSColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
        [_frostDupe setBackgroundColor:[goodColor CGColor]];
        [_frostDupe setOpacity:(alpha / 100.0)];
    }

    // Full width
    if ([[[Preferences sharedInstance] objectForKey:@"cd_fullWidth"] boolValue]) {
        CGRect rect = _superLayer.bounds;
        if (orient == 0) {
            rect.size.width = [[NSScreen mainScreen] frame].size.width * 2;
            rect.origin.x -= [[NSScreen mainScreen] frame].size.width / 2;
        } else {
            rect.size.height = [[NSScreen mainScreen] frame].size.height * 2;
            rect.origin.y -= [[NSScreen mainScreen] frame].size.height;
        }
        [ _materialLayer setFrame:rect ];
    } else {
        // If not full width round corners
        CGRect rect = _superLayer.bounds;
        float cornerSize = [[[Preferences sharedInstance] objectForKey:@"cd_cornerRadius"] floatValue];
        if (cornerSize > (float)0) {
            [ _frostDupe setCornerRadius:cornerSize ];
            [ _materialLayer setCornerRadius:cornerSize ];
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
        }
        [ _materialLayer setFrame:rect ];
    }

    // Why does this work? if I color the original frost layer I lose the frost
    // same with the background layer, so I create this dupe layer
    // but if I don't move it out of the frame I only see the uncolored frost
    // very magical, there must be a better way...
    CGRect rect = _materialLayer.bounds;
    rect.origin.y += rect.size.height;
    [_frostDupe setBounds:rect];
    _frostDupe.hidden = NO;
    
    // Pinning except the actual clickable tile areas don't move, not sure how to do that...
//    static dispatch_once_t once;
//    dispatch_once(&once, ^ {
//        CGRect r1 = _superLayer.bounds;
//        CGRect rect = _superLayer.superlayer.frame;
//        NSLog(@"%f", r1.size.width);
//        rect.origin.x -= ([[NSScreen mainScreen] frame].size.width - r1.size.width) / 2;
//        _superLayer.superlayer.frame = rect;
//    });

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