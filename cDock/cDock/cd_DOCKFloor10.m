//
//  cDockFloor.m
//

#import "cd_shared.h"

@interface _CDDOCKFloorLayer : CALayer
@end

// OS X 10.10 Yosemite and 10.11 El Capitan implementation
@implementation _CDDOCKFloorLayer
- (void)layoutSublayers {
    ZKOrig(void);
    
    // Do nothing if not enabled
    if (![[[Preferences sharedInstance2] objectForKey:@"cd_enabled"] boolValue])
        return;
        
    if (FLOORLAYER == nil)
        FLOORLAYER = self;
    
    // Fix for icon shadows / reflection layer not intializing on their own...
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
        if (cornerSize == 0)
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
    if ([[[Preferences sharedInstance] objectForKey:@"cd_separatorBG"] boolValue]) {
        [_separatorLayer setCompositingFilter:nil];
        float red = [[[Preferences sharedInstance] objectForKey:@"cd_separatorBGR"] floatValue];
        float green = [[[Preferences sharedInstance] objectForKey:@"cd_separatorBGG"] floatValue];
        float blue = [[[Preferences sharedInstance] objectForKey:@"cd_separatorBGB"] floatValue];
        [ _separatorLayer setBackgroundColor:[[NSColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0] CGColor]];
        [ _separatorLayer setOpacity:([[[Preferences sharedInstance] objectForKey:@"cd_separatorBGA"] floatValue] / 100.0)];
//        NSLog(@"%@", _separatorLayer.debugDescription);
    } else {
        [_separatorLayer setCompositingFilter:@"plusD"];
    }
    
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
        } else {
            _separatorLayer.transform = CATransform3DIdentity;
        }
    } else {
        
        // Adjust height to fit 3D size
        if ([[[Preferences sharedInstance] objectForKey:@"cd_separatorfullHeight"] boolValue]) {
            CGRect rect = _separatorLayer.frame;
            if (orient == 0) {
                rect.size.width = 1;
                rect.origin.y = 0;
                rect.size.height = _backgroundLayer.frame.size.height;
            } else {
                rect.size.height = 1;
                rect.origin.x = 0;
                rect.size.width = _backgroundLayer.frame.size.width;
            }
            [_separatorLayer setFrame:rect];
        }
        
        _separatorLayer.transform = CATransform3DIdentity;
    }
    
    float brdSize = [[[Preferences sharedInstance] objectForKey:@"cd_borderSize"] floatValue];
    // rounded corners
    if (cornerSize > 0) {
        if (! [[[Preferences sharedInstance] objectForKey:@"cd_fullWidth"] boolValue])
        {
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

            CGRect rect1 = _superLayer.bounds;
            
            if (orient == 0) {
                rect1.size.height += cornerSize;
                rect1.origin.y -= cornerSize;
            } else {
                rect1.size.width += cornerSize;
            }
            if (orient == 1) {
                rect1.origin.x -= cornerSize;
            }
            
            [ _materialLayer setFrame:rect1 ];
        }
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
    
    // Make sure separator is on top
    [ _separatorLayer setZPosition:998 ];
    
//    Pinning except the actual clickable tile areas don't move, not sure how to do that...
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