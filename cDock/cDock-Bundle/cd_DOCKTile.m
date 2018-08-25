//
//  cDockTile.m
//

// Icon shadows and icon reflections

#import "cd_shared.h"

ZKSwizzleInterface(_CDTileLayer, DOCKTileLayer, CALayer)
@implementation _CDTileLayer

- (void)createShadowAndReflectionLayers {
    return;
}

- (void)_removeReplacementExtraImage {
    ZKOrig(void);
    [self reflectionLayerImageUpdate];
}

- (void)_removeReplacementAppImage{
    ZKOrig(void);
    [self reflectionLayerImageUpdate];
}

- (void)_setReplacementExtraImage:(id)arg1 {
    ZKOrig(void, arg1);
    [self reflectionLayerImageUpdate];
}

- (void)_setReplacementAppImage:(id)arg1 {
    ZKOrig(void, arg1);
    [self reflectionLayerImageUpdate];
}

- (void)layoutSublayers {
    ZKOrig(void);
    
//    [ self setZPosition:999 ];
//    
//    if (!iscDockEnabled)
//        return;
//    
//    if ([readPref(@"cd_iconShadow.enabled") boolValue]) {
//        NSSize mySize;
//        mySize.width = 0;
//        mySize.height = -10;
//        [self setShadowColor:[_readColor(@"cd_iconShadow") CGColor]];
//        [self setShadowOpacity:[readPref(@"cd_iconShadow.alp") floatValue] / 100.0];
//        [self setShadowRadius:[readPref(@"cd_iconShadow.size") floatValue]];
//        [self setShadowOffset:mySize];
//    } else {
//        [self setShadowOpacity:0];
//    }
    
    // Icon reflections
    [self reflectionLayerUpdate];
}

- (void)reflectionLayerUpdate {
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
    
    if ([readPref(@"cd_iconReflection") boolValue]) {
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
        [_reflectionLayer setBounds:(frm) ];
        [_reflectionLayer setFrame:(frm) ];
        _reflectionLayer.opacity = 0.25;
    } else {
        [_reflectionLayer setHidden:YES];
    }
}

- (void)reflectionLayerImageUpdate {
    if (iscDockEnabled) {
        if ([readPref(@"cd_iconReflection") boolValue]) {
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
}

@end
