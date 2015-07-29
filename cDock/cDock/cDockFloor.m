//
//  cDockFloor.m
//

// I feel like a lot of this code is repetitive, I feel like there's got be a way to use the same implementation for 2 swizzles
// _CDMAVFloor is basically the same as _CDMAVSide
// Hmmm... well maybe a global method like _loadShadows would work

#import <objc/runtime.h>
#import "Preferences.h"
#import "Opee/Opee.h"
#import "fishhook.h"
#import <dlfcn.h>

# define thmePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/org.w0lf.cDock.plist"]
# define thmeName [[NSMutableDictionary dictionaryWithContentsOfFile:thmePath] objectForKey:@"cd_theme"]
# define prefPath [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/cDock/themes/"] stringByAppendingPathComponent:thmeName]
# define prefFile [[prefPath stringByAppendingPathComponent:thmeName ] stringByAppendingString:@".plist"]

NSInteger orient = 0;
long osx_minor = 0;

@interface ECMaterialLayer : CALayer
{
    CALayer *_backdropLayer;
    CALayer *_tintLayer;
    NSString *_groupName;
    _Bool _reduceTransparency;
    NSUInteger _material;
}
@end

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

@interface initialize : NSObject
@end
@implementation initialize

+ (void)load {
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
    
    if (![[[Preferences sharedInstance2] objectForKey:@"cd_enabled"] boolValue])
        return;
    
    _loadShadows(self);
    
    object_getInstanceVariable(self, "_orientation", (void **)&orient);
    
    CALayer *_separatorLayer = ZKHookIvar(self, CALayer *, "_separatorLayer");
    CALayer *_glass = ZKHookIvar(self, CALayer *, "_glassLayer");
    CALayer *_superLayer = self;
    CALayer *_rl = [[CALayer alloc] init];
    
    [ _rl setName:(@"_rl")];
    
    if (![[[Preferences sharedInstance] objectForKey:@"cd_showGlass"] boolValue])
        _glass.contents = nil;
        
    object_getInstanceVariable(self, "_orientation", (void **)&orient);
    float alpha = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGA"] floatValue];
    CGRect rect = _superLayer.bounds;
    
    if ([[[Preferences sharedInstance] objectForKey:@"cd_pictureBG"] boolValue]) {
        NSString *picFile = [NSString stringWithFormat:@"%@/background1.png", prefPath];
        if ([[[Preferences sharedInstance] objectForKey:@"cd_pictureTile"] boolValue]) {
            [ _rl setBackgroundColor:[[NSColor colorWithPatternImage:[[[NSImage alloc] initWithContentsOfFile:picFile] autorelease]] CGColor] ];
        } else {
            _rl.contents = [[[NSImage alloc] initWithContentsOfFile:picFile] autorelease];
        }
        [ _superLayer setSublayers:[NSArray arrayWithObjects:_separatorLayer, nil] ];
        [ _superLayer addSublayer:_rl ];
    }
    if ([[[Preferences sharedInstance] objectForKey:@"cd_dockBG"] boolValue]) {
        float red = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGR"] floatValue];
        float green = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGG"] floatValue];
        float blue = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGB"] floatValue];
        NSColor *goodColor = [NSColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
        [_rl setBackgroundColor:[goodColor CGColor]];
    }
    if ([[[Preferences sharedInstance] objectForKey:@"cd_fullWidth"] boolValue]) {
        rect.size.height = [[NSScreen mainScreen] frame].size.height * 2;
        rect.origin.y -= [[NSScreen mainScreen] frame].size.height;
    }
    
    // Resize
    float cornerSize = [[[Preferences sharedInstance] objectForKey:@"cd_cornerRadius"] floatValue];
    if (cornerSize > (float)0) {
        [ _rl setCornerRadius:cornerSize ];
        rect.size.width += cornerSize;
        if (orient == 1)
            rect.origin.x -= cornerSize;
    }
    [ _rl setFrame:rect ];
    [ _rl setOpacity:(alpha / 100.0)];
    
    NSMutableArray *mutableArray = (NSMutableArray *)self.sublayers;
    for (CALayer *item in mutableArray) {
        if ([item.name  isEqual:@"_rl"]) {
            [item removeFromSuperlayer];
            break;
        }
    }
    [ _superLayer addSublayer:_rl ];
    if ([[[Preferences sharedInstance] objectForKey:@"cd_isTransparent"] boolValue])
        [ _superLayer setSublayers:[NSArray arrayWithObjects:_separatorLayer, nil] ];
}
@end

@interface _CDMAVFloor : CALayer
@end
@implementation _CDMAVFloor
- (void)layoutSublayers {
    ZKOrig(void);
    
    if (![[[Preferences sharedInstance2] objectForKey:@"cd_enabled"] boolValue])
        return;
    
    _loadShadows(self);
    
    // Remove system icon reflection implementation
    SEL aSel = @selector(removeShadowAndReflectionLayers);
    NSArray *tileLayers = [self.superlayer.sublayers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject respondsToSelector:aSel];
    }]];
    [tileLayers makeObjectsPerformSelector:aSel];
    
    CALayer *_separatorLayer = ZKHookIvar(self, CALayer *, "_separatorLayer");
    CALayer *_glass = ZKHookIvar(self, CALayer *, "_glassLayer");
    CALayer *_superLayer = self;
    CALayer *_rl = [[CALayer alloc] init];
    [ _rl setName:(@"_rl")];
    
    if (![[[Preferences sharedInstance] objectForKey:@"cd_showGlass"] boolValue])
        _glass.contents = nil;
    
    object_getInstanceVariable(self, "_orientation", (void **)&orient);
    float alpha = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGA"] floatValue];
    CGRect rect = _superLayer.bounds;
    
    if ([[[Preferences sharedInstance] objectForKey:@"cd_pictureBG"] boolValue]) {
        NSString *picFile = [NSString stringWithFormat:@"%@/background.png", prefPath];
        if ([[[Preferences sharedInstance] objectForKey:@"cd_pictureTile"] boolValue]) {
            [ _rl setBackgroundColor:[[NSColor colorWithPatternImage:[[[NSImage alloc] initWithContentsOfFile:picFile] autorelease]] CGColor] ];
        } else {
            _rl.contents = [[[NSImage alloc] initWithContentsOfFile:picFile] autorelease];
        }
        [ _superLayer setSublayers:[NSArray arrayWithObjects:_separatorLayer, nil] ];
        [ _superLayer addSublayer:_rl ];
    }
    if ([[[Preferences sharedInstance] objectForKey:@"cd_dockBG"] boolValue]) {
        float red = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGR"] floatValue];
        float green = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGG"] floatValue];
        float blue = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGB"] floatValue];
        NSColor *goodColor = [NSColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
        [_rl setBackgroundColor:[goodColor CGColor]];
    }
    if ([[[Preferences sharedInstance] objectForKey:@"cd_fullWidth"] boolValue]) {
        rect.size.width = [[NSScreen mainScreen] frame].size.width * 2;
        rect.origin.x -= [[NSScreen mainScreen] frame].size.width;
    }
    
    // Resize
    rect.size.height = rect.size.height * 1.65;
    float cornerSize = [[[Preferences sharedInstance] objectForKey:@"cd_cornerRadius"] floatValue];
    if (cornerSize > (float)0) {
        [ _rl setCornerRadius:cornerSize ];
        rect.size.height += cornerSize;
        rect.origin.y -= cornerSize;
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
    
    NSMutableArray *mutableArray = (NSMutableArray *)self.sublayers;
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
@end


@interface _CDDOCKFloorLayer : CALayer
{
    ECMaterialLayer *_materialLayer;
    CALayer *_separatorLayer;
    CALayer *_glassLayer;
    CGRect _previousFrame;
    int _orientation;
    CGFloat _separatorPosition;
    unsigned int _lastDisplay;
    float _radius;
}
@end
@implementation _CDDOCKFloorLayer
- (void)layoutSublayers {
    ZKOrig(void);
    
    // Do nothing
    if (![[[Preferences sharedInstance2] objectForKey:@"cd_enabled"] boolValue])
        return;
    
    // Fix for icon shadows / reflection layer not intializing on their own...
    _loadShadows(self);
    
//        unsigned int varCount;
//        Ivar *vars = class_copyIvarList([self class], &varCount);
//        for (int i = 0; i < varCount; i++) {
//            Ivar var = vars[i];
//            const char* name = ivar_getName(var);
//            const char* typeEncoding = ivar_getTypeEncoding(var);
//            // do what you wish with the name and type here
//            NSLog(@"%s %s", name, typeEncoding);
//        }
//        free(vars);

    // Get dock orientation
    if (osx_minor == 11) {
        object_getInstanceVariable(self, "orientation", (void **)&orient);
    } else {
        object_getInstanceVariable(self, "_orientation", (void **)&orient);
    }
//    NSLog(@"Dock orientation : %li", (long)orient);

    // Duplicate the frost layer, I'll use this as our base background layer
    NSData *buffer = [NSKeyedArchiver archivedDataWithRootObject: _materialLayer];
    CALayer *_frostDupe = [NSKeyedUnarchiver unarchiveObjectWithData: buffer];
    [ _frostDupe setName:(@"_frostDupe")];

    // Probably could be done better remove old copy then add new one
    NSMutableArray *mutableArray = (NSMutableArray *)self.sublayers;
    for (CALayer *item in mutableArray)
        if ([item.name isEqual:@"_frostDupe"]) {
            [item removeFromSuperlayer];
            break;
        }
    [ self addSublayer:_frostDupe ];

    // Picture background set self background to picture
    if ([[[Preferences sharedInstance] objectForKey:@"cd_pictureBG"] boolValue]) {
        NSString *picFile = nil;
        if (orient == 0) {
            picFile = [NSString stringWithFormat:@"%@/background.png", prefPath];
        } else {
            picFile = [NSString stringWithFormat:@"%@/background1.png", prefPath];
        }
        if ([[[Preferences sharedInstance] objectForKey:@"cd_pictureTile"] boolValue]) {
            [ self setBackgroundColor:[[NSColor colorWithPatternImage:[[[NSImage alloc] initWithContentsOfFile:picFile] autorelease]] CGColor] ];
        } else {
            self.contents = [[[NSImage alloc] initWithContentsOfFile:picFile] autorelease];
        }
        [ self setSublayers:[NSArray arrayWithObjects:_separatorLayer, nil] ];
    }

    // Color background
    if ([[[Preferences sharedInstance] objectForKey:@"cd_dockBG"] boolValue]) {
        float red = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGR"] floatValue];
        float green = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGG"] floatValue];
        float blue = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGB"] floatValue];
        float alpha = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGA"] floatValue];
        NSColor *goodColor = [NSColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
        _materialLayer.cornerRadius = 0;
        _materialLayer.borderWidth = 0;
        [_frostDupe setBackgroundColor:[goodColor CGColor]];
        [_frostDupe setOpacity:(alpha / 100.0)];
    }

    // Full width
    if ([[[Preferences sharedInstance] objectForKey:@"cd_fullWidth"] boolValue]) {
        CGRect rect = _materialLayer.bounds;
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
        CGRect rect = self.bounds;
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
    
//    static dispatch_once_t once;
//    dispatch_once(&once, ^ {
//        CGRect r1 = self.bounds;
//        CGRect rect = self.superlayer.frame;
//        NSLog(@"%f", r1.size.width);
//        rect.origin.x -= ([[NSScreen mainScreen] frame].size.width - r1.size.width) / 2;
//        self.superlayer.frame = rect;
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
        [ self setSublayers:[NSArray arrayWithObjects:_separatorLayer, nil] ];
}
@end