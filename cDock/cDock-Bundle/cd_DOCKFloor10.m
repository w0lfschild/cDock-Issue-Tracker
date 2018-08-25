//
//  cDockFloor.m
//

// Dock background, border, separator, frost and glass layers

@import QuartzCore;

#import "cd_shared.h"

@interface _CDDOCKFloorLayer : CALayer
@end

// OS X 10.10 Yosemite and 10.11 El Capitan implementation
@implementation _CDDOCKFloorLayer

- (void)layoutSublayers {
    ZKOrig(void);
    
    // Do nothing if not enabled
    if (!iscDockEnabled)
        return;
        
    if (FLOORLAYER == nil)
        FLOORLAYER = self;
    
    // Fix for icon shadows / reflection layer not intializing on their own...
    _loadShadows(self);
    _loadImages();

    // Update dock orientation
    if (osx_minor >= 11) {
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
    for (CALayer *item in (NSMutableArray *)_superLayer.sublayers) {
        if ([item.name isEqual:@"_borderLayer"])
            _borderLayer = item;
        if ([item.name isEqual:@"_backgroundLayer"])
            _backgroundLayer = item;
    }
    
    // initialize border layer
    if (_borderLayer == nil) {
        _borderLayer = [[CALayer alloc] init];
        [ _borderLayer setName:(@"_borderLayer")];
        [ _superLayer addSublayer:_borderLayer ];
    }
    
    // initialize background layer
    if (_backgroundLayer == nil) {
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
    float cornerSize = [readPref(@"cd_cornerRadius") floatValue];
    
    // Lets make the frost layer rectangular by default
    _materialLayer.cornerRadius = 0;
    _materialLayer.borderWidth = 0;

    // Full width dock
    if ([readPref(@"cd_background.fullwidth") boolValue]) {
        CGRect rect = _superLayer.bounds;
        
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
    if ([readPref(@"cd_background.picture") boolValue]) {
        if (orient == 0) {
            if ([readPref(@"cd_background.tile") boolValue]) {
                if (background)
                    [ _backgroundLayer setBackgroundColor:[[NSColor colorWithPatternImage:[[NSImage alloc] initWithCGImage:background size:NSZeroSize]] CGColor] ];
                else
                    [ _backgroundLayer setBackgroundColor:[[NSColor clearColor] CGColor] ];
            } else {
                [ _backgroundLayer setBackgroundColor:[[NSColor clearColor] CGColor] ];
                [ _backgroundLayer setContents:(__bridge id)background ];
            }
        } else {
            if ([readPref(@"cd_background.tile") boolValue]) {
                if (background1)
                    [ _backgroundLayer setBackgroundColor:[[NSColor colorWithPatternImage:[[NSImage alloc] initWithCGImage:background1 size:NSZeroSize]] CGColor] ];
                else
                    [ _backgroundLayer setBackgroundColor:[[NSColor clearColor] CGColor] ];
            } else {
                [ _backgroundLayer setBackgroundColor:[[NSColor clearColor] CGColor] ];
                [ _backgroundLayer setContents:(__bridge id)background1 ];
            }
        }

        if (![readPref(@"cd_background.fullwidth") boolValue])
            [ _materialLayer setFrame: _superLayer.bounds ];
        
        if ([readPref(@"cd_background.3d") boolValue] && orient == 0) {
            CGRect rect = _superLayer.bounds;
            rect.size.width = rect.size.width * 1.025;
            rect.origin.x -= (rect.size.width * 0.025) / 2;
            [ _materialLayer setFrame: rect ];
        }
        
        [_backgroundLayer setOpacity:([readPref(@"cd_background.alp") floatValue] / 100.0)];
    } else {
        [ _backgroundLayer setContents:nil ];
    }

    // Color background layer
    if ([readPref(@"cd_background.enabled") boolValue]) {
        [_backgroundLayer setBackgroundColor:[_readColor(@"cd_background") CGColor]];
        [_backgroundLayer setOpacity:([readPref(@"cd_background.alp") floatValue] / 100.0)];
        
        /* Gradient Fill
        
        CAGradientLayer *_gradientLayer = nil;
        
        // Look for custom layers
        for (CAGradientLayer *item in (NSMutableArray *)_superLayer.sublayers)
            if ([item.name isEqual:@"_gradientLayer"])
                _gradientLayer = item;
        
        // initialize border layer
        if (_gradientLayer == nil)
        {
            _gradientLayer = [CAGradientLayer layer];
            [ _gradientLayer setName:(@"_gradientLayer")];
            [ _superLayer addSublayer:_gradientLayer ];
        }
        
        NSColor * highColor = [NSColor colorWithWhite:1.000 alpha:1.000];
        NSColor * lowColor = [NSColor redColor];
        
        //The gradient, simply enough.  It is a rectangle
        [_gradientLayer setFrame:_backgroundLayer.frame];
        [_gradientLayer setColors:[NSArray arrayWithObjects:(id)[highColor CGColor], (id)[lowColor CGColor], nil]];
    
        [_gradientLayer setStartPoint:CGPointMake(0.2, 0.8)];
        [_gradientLayer setEndPoint:CGPointMake(0.8, 0.2)];
         
         */
    }

    if (![readPref(@"cd_background.enabled") boolValue] && ![readPref(@"cd_background.picture") boolValue])
        _backgroundLayer.hidden = YES;
    
    // Separator
    if ([readPref(@"cd_separator.enabled") boolValue]) {
        [_separatorLayer setCompositingFilter:nil];
        [_separatorLayer setBackgroundColor:[_readColor(@"cd_separator") CGColor]];
        [_separatorLayer setOpacity:([readPref(@"cd_separator.alp") floatValue] / 100.0)];
    } else {
        [_separatorLayer setCompositingFilter:@"plusD"];
    }
    
    if ([readPref(@"cd_background.3d") boolValue]) {
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
        if ([readPref(@"cd_separator.fullheight") boolValue]) {
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
    
    float brdSize = [readPref(@"cd_border.size") floatValue];
    // rounded corners
    if (cornerSize > 0) {
        if (![readPref(@"cd_background.fullwidth") boolValue]) {
            // Not sure if there is some exact math but this mitigates the gap between the corner of the background layers and the border layer showing
            if (brdSize > 0) {
                [_backgroundLayer setCornerRadius:cornerSize / brdSize];
                [_materialLayer setCornerRadius:cornerSize / brdSize];
                [_borderLayer setCornerRadius:cornerSize / brdSize];
            } else {
                [_materialLayer setCornerRadius:cornerSize];
                [_backgroundLayer setCornerRadius:cornerSize];
                [_borderLayer setCornerRadius:cornerSize];
            }
        
            [_borderLayer setCornerRadius:cornerSize];

            // Couldn't figure out how to adjust this layers corners so lets hide it
            _glassLayer.hidden = YES;

            CGRect rect1 = _superLayer.bounds;
            
            if (orient == 0) {
                rect1.size.height += cornerSize;
                rect1.origin.y -= cornerSize;
            } else {
                rect1.size.width += cornerSize;
            }
            if (orient == 1)
                rect1.origin.x -= cornerSize;
            
            [ _materialLayer setFrame:rect1 ];
        }
    } else {
        [_materialLayer setCornerRadius:cornerSize];
        [_backgroundLayer setCornerRadius:cornerSize];
        [_borderLayer setCornerRadius:cornerSize];
    }
    
    // Border layer
    brdSize = [readPref(@"cd_border.size") floatValue];
    if (brdSize > 0) {
        CGRect newFrame = _materialLayer.frame;
        newFrame.origin.x -= brdSize;
        newFrame.size.width += brdSize * 2;
        newFrame.origin.y -= brdSize;
        newFrame.size.height += brdSize * 2;
        [ _borderLayer setFrame:newFrame];
        [ _borderLayer setBackgroundColor:[[NSColor clearColor] CGColor]];
        [ _borderLayer setBorderColor:[_readColor(@"cd_border") CGColor]];
        [ _borderLayer setOpacity:([readPref(@"cd_border.alp") floatValue] / 100.0)];
        [ _borderLayer setBorderWidth:brdSize];
        [ _borderLayer setHidden:false];
    } else {
        _borderLayer.hidden = YES;
    }
    
    // background layer should have same frame as frost layer
    [_backgroundLayer setFrame: _materialLayer.frame];
    
    // Make sure separator is on top
    [_separatorLayer setZPosition:998];

    // Hide layers if we want to
    if (![readPref(@"cd_stock.frost") boolValue])
        _materialLayer.hidden = YES;
    
    if (![readPref(@"cd_stock.glass") boolValue]) {
        _glassLayer.hidden = YES;
    } else {
        if ([readPref(@"cd_background.fullwidth") boolValue])
            _glassLayer.hidden = YES;
        if ([readPref(@"cd_background.enabled") boolValue])
            _glassLayer.hidden = YES;
    }

    if (![readPref(@"cd_stock.separator") boolValue])
        _separatorLayer.hidden = YES;

    // Setting sublayer to just the separator seems to work nice for this
    if ([readPref(@"cd_background.transparent") boolValue])
        [_superLayer setSublayers:[NSArray arrayWithObjects:_separatorLayer, nil]];
}

@end
