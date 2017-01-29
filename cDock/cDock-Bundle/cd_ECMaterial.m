//
//  cDockLabel.m
//

#import "cd_shared.h"

//extern long osx_minor;

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
    
    if (![[[Preferences sharedInstance2] objectForKey:@"cd_enabled"] boolValue])
        return;

//    NSLog(@"%lu", (unsigned long)_material);
//    NSLog(@"%@", self.superlayer.class);
    
    if ([[[Preferences sharedInstance] objectForKey:@"cd_labelBG"] boolValue]) {
        
        // Prevent coloration of some layers
        
        // Floor = Dock Background Frost Layer
        // CALayer = Mission Control
        // ECBezelIconListLayer = Application switcher background
        
        if (self.superlayer.class != NSClassFromString(@"Dock.FloorLayer")
            && self.superlayer.class != NSClassFromString(@"DOCKFloorLayer")
            && self.superlayer.class != NSClassFromString(@"CALayer")
            && self.superlayer.class != NSClassFromString(@"ECBezelIconListLayer")) {
            
//            NSLog(@"%@", self.debugDescription);
            
            NSUInteger _material = ZKHookIvar(self, NSUInteger, "_material");
            if (_material != 0) {
//                CALayer *_tintLayer = ZKHookIvar(self, CALayer *, "_tintLayer");
//                [_tintLayer setBackgroundColor:[[NSColor colorWithCalibratedWhite:0 alpha:0] CGColor]];
//                [_tintLayer setOpacity:0];
//                _tintLayer.compositingFilter = nil;
                
                float red = [[[Preferences sharedInstance] objectForKey:@"cd_labelBGR"] floatValue];
                float green = [[[Preferences sharedInstance] objectForKey:@"cd_labelBGG"] floatValue];
                float blue = [[[Preferences sharedInstance] objectForKey:@"cd_labelBGB"] floatValue];
                float alpha = [[[Preferences sharedInstance] objectForKey:@"cd_labelBGA"] floatValue];
                NSColor *goodColor = [NSColor colorWithRed:red/255.0 green:green/255 blue:blue/255.0 alpha:1.0];
                CALayer *_backdropLayer = ZKHookIvar(self, CALayer *, "_backdropLayer");
                [_backdropLayer setBackgroundColor:[goodColor CGColor]];
                [_backdropLayer setOpacity:( alpha / 100.0 )];
            }
            
        }
    }
}
@end