//
//  cDockLabel.m
//

// Icon labels

#import "cd_shared.h"

@interface ECMaterialLayer : CALayer
{
    CALayer *_backdropLayer;
    CALayer *_tintLayer;
    NSString *_groupName;
    _Bool _reduceTransparency;
    NSUInteger _material;
}
@end

ZKSwizzleInterface(_CDECMaterialLayer, ECMaterialLayer, CALayer);
@implementation _CDECMaterialLayer

- (void)setBounds:(CGRect)arg1 {
    ZKOrig(void, arg1);
    
    if (!iscDockEnabled)
        return;
    
    if ([readPref(@"cd_label.enabled") boolValue]) {
        /*
         Prevent coloring of some layers
         Floor = Dock Background Frost Layer
         CALayer = Mission Control
         ECBezelIconListLayer = Application switcher background
         */
        
        if (self.superlayer.class != NSClassFromString(@"Dock.FloorLayer")
            && self.superlayer.class != NSClassFromString(@"DOCKFloorLayer")
            && self.superlayer.class != NSClassFromString(@"CALayer")
            && self.superlayer.class != NSClassFromString(@"ECBezelIconListLayer")) {
                        
            NSUInteger _material = ZKHookIvar(self, NSUInteger, "_material");
            if (_material != 0) {
//                CALayer *_tintLayer = ZKHookIvar(self, CALayer *, "_tintLayer");
//                [_tintLayer setBackgroundColor:[[NSColor colorWithCalibratedWhite:0 alpha:0] CGColor]];
//                [_tintLayer setOpacity:0];
//                _tintLayer.compositingFilter = nil;
                
                CALayer *_backdropLayer = ZKHookIvar(self, CALayer *, "_backdropLayer");
                NSColor *_newColor = _readColor(@"cd_label");
                [_backdropLayer setBackgroundColor:[_newColor CGColor]];
                [_backdropLayer setOpacity:[readPref(@"cd_label.alp") floatValue] / 100.0];
                
            }
            
        }
    }
}

@end
