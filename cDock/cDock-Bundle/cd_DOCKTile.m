//
//  cDockTile.m
//

#import "cd_shared.h"

ZKSwizzleInterface(_CDTileLayer, DOCKTileLayer, CALayer)
@implementation _CDTileLayer

- (void)createShadowAndReflectionLayers {
    return;
    // DO NOTHING
}

- (void)_removeReplacementAppImage{
    ZKOrig(void);
    [self reflectionLayerUpdate];
}

- (void)_setReplacementAppImage:(id)arg1 {
    ZKOrig(void, arg1);
    [self reflectionLayerUpdate];
}

- (void)layoutSublayers {
    ZKOrig(void);
    
    [ self setZPosition:999 ];
    
    if (![[[Preferences sharedInstance2] objectForKey:@"cd_enabled"] boolValue])
        return;
    
//    NSLog(@"%ld", (long)orient);
//    NSLog(@"%ld", (long)self.frame.size.height);
    
    if ([[[Preferences sharedInstance] objectForKey:@"cd_iconShadow"] boolValue]) {
        float red = [[[Preferences sharedInstance] objectForKey:@"cd_iconShadowBGR"] floatValue];
        float green = [[[Preferences sharedInstance] objectForKey:@"cd_iconShadowBGG"] floatValue];
        float blue = [[[Preferences sharedInstance] objectForKey:@"cd_iconShadowBGB"] floatValue];
        float alpha = [[[Preferences sharedInstance] objectForKey:@"cd_iconShadowBGA"] floatValue];
        float size = [[[Preferences sharedInstance] objectForKey:@"cd_iconShadowBGS"] floatValue];
        
        NSSize mySize;
        mySize.width = 0;
        mySize.height = -10;
        
        self.shadowOpacity = alpha / 100.0;
        self.shadowColor = CGColorCreateGenericRGB(red/255.0, green/255.0, blue/255.0, 1.0);
        self.shadowRadius = size;
        self.shadowOffset = mySize;
    } else {
        self.shadowOpacity = 0;
    }
    
    // Icon reflections
    if ([[[Preferences sharedInstance] objectForKey:@"cd_iconReflection"] boolValue]) {
        [self reflectionLayersetup];
    } else {
        CALayer *_reflectionLayer = nil;
        
        // Check if our custom layer exists, if it does then reference it
        for (CALayer *item in (NSMutableArray *)self.sublayers)
            if ([item.name  isEqual:@"_reflectionLayer"]) {
                _reflectionLayer = item;
                break;
            }
        
        _reflectionLayer.hidden = YES;
    }
}

- (void)reflectionLayersetup {
    CALayer *_iconLayer = ZKHookIvar(self, CALayer *, "_imageLayer");
    CALayer *_reflectionLayer = nil;
    
    // Check if our custom layer exists, if it does then reference it
    for (CALayer *item in (NSMutableArray *)self.sublayers)
        if ([item.name  isEqual:@"_reflectionLayer"]) {
            _reflectionLayer = item;
            break;
        }
    
    // This way we only add the flipped tile once
    if (_reflectionLayer == nil)
    {
        NSData *buffer = [NSKeyedArchiver archivedDataWithRootObject: _iconLayer];
        _reflectionLayer = [NSKeyedUnarchiver unarchiveObjectWithData: buffer];
        [ _reflectionLayer setName:(@"_reflectionLayer")];
        [ self addSublayer:_reflectionLayer ];
        _reflectionLayer.hidden = YES;
    }
    
//    _reflectionLayer.hidden = NO;
    
    // Transform reflecition layer using CATransform3DMakeRotation
    CGRect frm = _iconLayer.frame ;
    if (orient == 0) {
        frm.origin.y -= frm.size.height;
        _reflectionLayer.transform = CATransform3DMakeRotation(M_PI, 1, 0, 0);
    } else if (orient == 1) {
        frm.origin.x -= frm.size.width;
        _reflectionLayer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
    } else {
        frm.origin.x += frm.size.width;
        _reflectionLayer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
    }
    [ _reflectionLayer setBounds:(frm) ];
    [ _reflectionLayer setFrame:(frm) ];
    _reflectionLayer.opacity = 0.25;
}

- (void)reflectionLayerUpdate {
    if ([[[Preferences sharedInstance] objectForKey:@"cd_iconReflection"] boolValue]) {
        CALayer *_iconLayer = ZKHookIvar(self, CALayer *, "_imageLayer");
        CALayer *_reflectionLayer = nil;
        for (CALayer *item in (NSMutableArray *)self.sublayers)
            if ([item.name  isEqual:@"_reflectionLayer"]) {
                _reflectionLayer = item;
                break;
            }
        _reflectionLayer.contents = _iconLayer.contents;
    }
}
@end
