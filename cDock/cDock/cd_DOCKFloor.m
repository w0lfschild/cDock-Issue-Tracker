//
//  cDockFloor.m
//

#import "Preferences.h"
#import "ZKSwizzle.h"
@import AppKit;

# define dockPath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.apple.dock.plist"]
# define thmePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/org.w0lf.cDock.plist"]
# define thmeName [[NSMutableDictionary dictionaryWithContentsOfFile:thmePath] objectForKey:@"cd_theme"]
# define prefPath [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/cDock/themes/"] stringByAppendingPathComponent:thmeName]
# define prefFile [[prefPath stringByAppendingPathComponent:thmeName ] stringByAppendingString:@".plist"]

NSInteger orient = 0;
long osx_minor = 0;
CGImageRef background;
CGImageRef background1;
BOOL loadShadows = true;
BOOL loadImages = true;

CGImageRef large;
CGImageRef medium;
CGImageRef small;
CGImageRef medium_simple;
CGImageRef small_simple;

@interface _CDMAVSide : CALayer
@end
@interface _CDMAVFloor : CALayer
@end
@interface _CDDOCKFloorLayer : CALayer
@end

void _loadImages()
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (loadImages)
    {
        loadImages = false;
        NSString *picFile;
        
        picFile = [NSString stringWithFormat:@"%@/background.png", prefPath];
        if ([fileManager fileExistsAtPath:picFile])
            background = CGImageCreateWithPNGDataProvider(CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:picFile]), NULL, true, kCGRenderingIntentDefault);
        else
            background = nil;
        
        picFile = [NSString stringWithFormat:@"%@/background1.png", prefPath];
        if ([fileManager fileExistsAtPath:picFile])
            background1 = CGImageCreateWithPNGDataProvider(CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:picFile]), NULL, true, kCGRenderingIntentDefault);
        else
            background1 = nil;
        
        CGDataProviderRef imgDataProvider;
        imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/indicator_large.png", prefPath]]);
        large = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
        imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/indicator_medium.png", prefPath]]);
        medium = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
        imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/indicator_small.png", prefPath]]);
        small = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
        imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/indicator_medium_simple.png", prefPath]]);
        medium_simple = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
        imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/indicator_small_simple.png", prefPath]]);
        small_simple = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
    }
}

void _forceRefresh()
{
    if (osx_minor > 9) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("AppleInterfaceThemeChangedNotification"), (void *)0x1, NULL, YES);
        });
    }
    
    Class cls = NSClassFromString(@"DOCKPreferences");
    id dockPref = nil;
    SEL aSel = NSSelectorFromString(@"preferences");
    if ([cls respondsToSelector:aSel]) {
        dockPref = [cls performSelector:aSel];
    }
    if (dockPref) {
        NSString *key = @"showProcessIndicatorsPref";
        id val = [dockPref valueForKey:key];
        if (val) {
            [dockPref setValue:[NSNumber numberWithBool:![val boolValue]] forKey:key];
            [dockPref setValue:val forKey:key];
        }
    }
}

// Fix for icon shadows / reflection layer not intializing on their own...
void _loadShadows(CALayer* layer)
{
    if (loadShadows) {
        loadShadows = false;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
            SEL aSel = @selector(layoutSublayers);
            NSArray *tileLayers = layer.superlayer.sublayers;
            for (CALayer *item in tileLayers)
            {
                if (item.class == NSClassFromString(@"DOCKTileLayer")) {
                    if ([item respondsToSelector:aSel])
                        [item performSelector:aSel];
                }
            }
                
            // Gotta refresh again here to get custom indicators to theme?
            // Can cause crash if not delayed...
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                _forceRefresh();
            });
            
//            NSLog(@"Shadows and reflections initialized...");
        });
    }
}

// OS X 10.9 Mavericks implementation
void _TenNine(CALayer* layer)
{
    if (![[[Preferences sharedInstance2] objectForKey:@"cd_enabled"] boolValue])
        return;
    
    _loadShadows(layer);
    _loadImages();
    
    object_getInstanceVariable(layer, "_orientation", (void **)&orient);
    
    if (orient == 0) {
        // Remove system icon reflection implementation
        SEL aSel = NSSelectorFromString(@"removeShadowAndReflectionLayers");
        NSArray *tileLayers = [layer.superlayer.sublayers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(id evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject respondsToSelector:aSel];
        }]];
        [tileLayers makeObjectsPerformSelector:aSel];
        
        BOOL flag;
        if (object_getInstanceVariable(layer, "_dontEverShowMirror", (void **)&flag)) {
            if (!flag) {
                object_setInstanceVariable(layer, "_dontEverShowMirror", (void *)YES);
                SEL aSel = NSSelectorFromString(@"turnMirrorOff");
                if ([layer respondsToSelector:aSel]) {
                    [layer performSelector:aSel];
                }
            }
        }
        
        // Flickers
//        aSel = NSSelectorFromString(@"turnMirrorOff");
//        if ([layer respondsToSelector:aSel])
//            [layer performSelector:aSel];
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
        // Check orientation
        if (orient == 0)
        {
            if ([[[Preferences sharedInstance] objectForKey:@"cd_pictureTile"] boolValue]) {
                if (background)
                    [ _backgroundLayer setBackgroundColor:[[NSColor colorWithPatternImage:[[NSImage alloc] initWithCGImage:background size:NSZeroSize]] CGColor] ];
                else
                    [ _backgroundLayer setBackgroundColor:[[NSColor clearColor] CGColor] ];
            } else {
                _backgroundLayer.contents = (__bridge id)background;
            }
        }
        else
        {
            if ([[[Preferences sharedInstance] objectForKey:@"cd_pictureTile"] boolValue]) {
                if (background1)
                    [ _backgroundLayer setBackgroundColor:[[NSColor colorWithPatternImage:[[NSImage alloc] initWithCGImage:background1 size:NSZeroSize]] CGColor] ];
                else
                    [ _backgroundLayer setBackgroundColor:[[NSColor clearColor] CGColor] ];
            } else {
                _backgroundLayer.contents = (__bridge id)background1;
            }
        }
        [ _superLayer setSublayers:[NSArray arrayWithObjects: _backgroundLayer, _separatorLayer, nil] ];
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
        [ _borderLayer setOpacity:[[[Preferences sharedInstance] objectForKey:@"cd_borderBGA"] floatValue] / 100 ];
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

@implementation _CDMAVSide : CALayer
- (void)layoutSublayers {
    ZKOrig(void);
    _TenNine(self);
}
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
//    if ([[[Preferences sharedInstance] objectForKey:@"cd_iconShadow"] boolValue] || [[[Preferences sharedInstance] objectForKey:@"cd_iconReflection"] boolValue])
    _loadShadows(self);
    
    _loadImages();

    // Update dock orientation
    if (osx_minor == 11) {
        object_getInstanceVariable(self, "orientation", (void **)&orient);
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
    
    _materialLayer.hidden = NO;
    _glassLayer.hidden = NO;
    _separatorLayer.hidden = NO;
    
    _borderLayer.hidden = NO;
    _backgroundLayer.hidden = NO;
    
    // Read corner radius
    float cornerSize = [[[Preferences sharedInstance] objectForKey:@"cd_cornerRadius"] floatValue];
    
    // Lets make the frost layer rectangular by default
    _materialLayer.cornerRadius = 0;
    _materialLayer.borderWidth = 0;

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
    } else {
        [ _materialLayer setFrame:_superLayer.bounds ];
    }
    
    // Picture background
    if ([[[Preferences sharedInstance] objectForKey:@"cd_pictureBG"] boolValue]) {
        if (orient == 0)
        {
            if ([[[Preferences sharedInstance] objectForKey:@"cd_pictureTile"] boolValue]) {
                if (background)
                    [ _backgroundLayer setBackgroundColor:[[NSColor colorWithPatternImage:[[NSImage alloc] initWithCGImage:background size:NSZeroSize]] CGColor] ];
                else
                    [ _backgroundLayer setBackgroundColor:[[NSColor clearColor] CGColor] ];
            } else {
                [ _backgroundLayer setBackgroundColor:[[NSColor clearColor] CGColor] ];
                [ _backgroundLayer setContents:(__bridge id)background ];
            }
        }
        else
        {
            if ([[[Preferences sharedInstance] objectForKey:@"cd_pictureTile"] boolValue]) {
                if (background1)
                    [ _backgroundLayer setBackgroundColor:[[NSColor colorWithPatternImage:[[NSImage alloc] initWithCGImage:background1 size:NSZeroSize]] CGColor] ];
                else
                    [ _backgroundLayer setBackgroundColor:[[NSColor clearColor] CGColor] ];
            } else {
                [ _backgroundLayer setBackgroundColor:[[NSColor clearColor] CGColor] ];
                [ _backgroundLayer setContents:(__bridge id)background1 ];
            }
        }
        // Set self sublayers to _backgroundLayer and _serparatorLayer
        // Make sure _sepraratorLayer is on top
//        [ _superLayer setSublayers:[NSArray arrayWithObjects:_backgroundLayer, _separatorLayer, nil] ];
        if (![[[Preferences sharedInstance] objectForKey:@"cd_fullWidth"] boolValue])
            [ _materialLayer setFrame: _superLayer.bounds ];
        
        if ([[[Preferences sharedInstance] objectForKey:@"cd_is3D"] boolValue] && orient == 0)
        {
            CGRect rect = _superLayer.bounds;
            rect.size.width = rect.size.width * 1.025;
            rect.origin.x -= (rect.size.width * 0.025) / 2;
            [ _materialLayer setFrame: rect ];
        }
        
        float alpha = [[[Preferences sharedInstance] objectForKey:@"cd_dockBGA"] floatValue];
        [_backgroundLayer setOpacity:(alpha / 100.0)];
    } else {
        [ _backgroundLayer setContents:nil ];
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

    if (![[[Preferences sharedInstance] objectForKey:@"cd_dockBG"] boolValue] && ![[[Preferences sharedInstance] objectForKey:@"cd_pictureBG"] boolValue])
        _backgroundLayer.hidden = YES;
    
    // Separator
    if ([[[Preferences sharedInstance] objectForKey:@"cd_is3D"] boolValue]) {
        if (orient == 0) {
            // Kinda cool rotating...
//            CATransform3D current = _separatorLayer.transform;
//            _separatorLayer.transform = CATransform3DRotate(current, 10/(180 * M_PI), 0, 0, 1.0);
            
            // Tilt the 3D separator 15 degrees
            [_separatorLayer setTransform:CATransform3DMakeRotation((15 * M_PI / 180), -1.0, 0.0, 1.0)];
            
            // Adjust height to fit 3D size
            CGRect rect = _separatorLayer.frame;
            rect.origin.x += (_backgroundLayer.frame.size.width / 100) * 0.2;
            rect.size.width = 1; //(_backgroundLayer.frame.size.width / 100) * 0.1;
            rect.size.height = _backgroundLayer.frame.size.height * .4;
            [_separatorLayer setFrame:rect];
            
            // Make sure we're in the front
            _separatorLayer.zPosition = 999;
        } else {
            _separatorLayer.transform = CATransform3DIdentity;
        }
    } else {
        _separatorLayer.transform = CATransform3DIdentity;
    }
    
    float brdSize = [[[Preferences sharedInstance] objectForKey:@"cd_borderSize"] floatValue];
    // rounded corners
    if (cornerSize > 0 && ![[[Preferences sharedInstance] objectForKey:@"cd_fullWidth"] boolValue]) {
        CGRect rect = _superLayer.bounds;
        
        // Not sure if there is some exact math but this mitigates the gap between the corner of the background layers and the border layer showing
        if (brdSize > 0) {
            [ _backgroundLayer setCornerRadius:cornerSize / brdSize ];
            [ _materialLayer setCornerRadius:cornerSize / brdSize ];
            [ _borderLayer setCornerRadius:cornerSize / brdSize ];
        } else {
            [ _materialLayer setCornerRadius:cornerSize ];
            [ _backgroundLayer setCornerRadius:cornerSize ];
            [ _borderLayer setCornerRadius:cornerSize ];
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
    } else {
        [ _materialLayer setCornerRadius:cornerSize ];
        [ _backgroundLayer setCornerRadius:cornerSize ];
        [ _borderLayer setCornerRadius:cornerSize ];
    }
    
    // Border layer
    brdSize = [[[Preferences sharedInstance] objectForKey:@"cd_borderSize"] floatValue];
    if (brdSize > 0) {
        CGRect newFrame = _materialLayer.frame;
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
    } else {
        _borderLayer.hidden = YES;
    }
    
    // background layer should have same frame as frost layer
    [ _backgroundLayer setFrame: _materialLayer.frame];
    
    [ _separatorLayer removeFromSuperlayer ];
    [ _superLayer addSublayer:_separatorLayer ];
    
    // Pinning except the actual clickable tile areas don't move, not sure how to do that...
//        CGRect r1 = _superLayer.bounds;
//        CGRect rect = _superLayer.superlayer.frame;
//        rect.origin.x = -([[NSScreen mainScreen] frame].size.width - r1.size.width) / 2;
//        _superLayer.superlayer.frame = rect;
//    NSLog(@"%@",  self.superlayer.debugDescription);

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