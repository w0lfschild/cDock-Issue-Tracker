//
//  cDockLabel.m
//

#import "Preferences.h"
#import "ZKSwizzle.h"
@import AppKit;

extern long osx_minor;

@interface ECMaterialLayer : CALayer
{
    CALayer *_backdropLayer;
    CALayer *_tintLayer;
    NSString *_groupName;
    _Bool _reduceTransparency;
    NSUInteger _material;
}
@end

ZKSwizzleInterface(__CDLabel, DOCKLabelLayer, CALayer);
@implementation __CDLabel
-(void)layoutSublayers {
    ZKOrig(void);
    
    if (![[[Preferences sharedInstance2] objectForKey:@"cd_enabled"] boolValue])
        return;
    
//    if ([[[Preferences sharedInstance] objectForKey:@"cd_labelBG"] boolValue]) {
//        float red = [[[Preferences sharedInstance] objectForKey:@"cd_labelBGR"] floatValue];
//        float green = [[[Preferences sharedInstance] objectForKey:@"cd_labelBGG"] floatValue];
//        float blue = [[[Preferences sharedInstance] objectForKey:@"cd_labelBGB"] floatValue];
//        float alpha = [[[Preferences sharedInstance] objectForKey:@"cd_labelBGA"] floatValue];
//        
//        NSColor *goodColor = [NSColor colorWithRed:red/255.0 green:green/255 blue:blue/255.0 alpha:1.0];
//        ECMaterialLayer *tintLayer = ZKHookIvar(self, ECMaterialLayer *, "_backdrop");
//        CALayer *test = [tintLayer.sublayers objectAtIndex:0];
//        [test setBackgroundColor:[goodColor CGColor]];
//        [test setOpacity:( alpha / 100.0 )];
//    }
    
    if (osx_minor == 9) {
        float red = [[[Preferences sharedInstance] objectForKey:@"cd_labelBGR"] floatValue];
        float green = [[[Preferences sharedInstance] objectForKey:@"cd_labelBGG"] floatValue];
        float blue = [[[Preferences sharedInstance] objectForKey:@"cd_labelBGB"] floatValue];
        NSColor *goodColor = [NSColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
        
        red = [[[Preferences sharedInstance] objectForKey:@"cd_iconShadowBGR"] floatValue];
        green = [[[Preferences sharedInstance] objectForKey:@"cd_iconShadowBGG"] floatValue];
        blue = [[[Preferences sharedInstance] objectForKey:@"cd_iconShadowBGB"] floatValue];
        float size = [[[Preferences sharedInstance] objectForKey:@"cd_iconShadowBGS"] floatValue];
        NSColor *goodColor2 = [NSColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
        
        NSArray *test = self.sublayers;
        if (test != nil) {
            CALayer *layer2 = [ test objectAtIndex:0 ];
            if ([[[Preferences sharedInstance] objectForKey:@"cd_labelBG"] boolValue]) {
                float alpha = [[[Preferences sharedInstance] objectForKey:@"cd_labelBGA"] floatValue];
                [layer2 setBackgroundColor:[goodColor CGColor]];
                [layer2 setOpacity:(alpha / 100.0)];
                if (test.count > 1) {
                    [[ test objectAtIndex:1 ] setContents:nil];
                }
                [layer2 setCornerRadius: 10];
            }
            if ([[[Preferences sharedInstance] objectForKey:@"cd_iconShadow"] boolValue]) {
                float alpha = [[[Preferences sharedInstance] objectForKey:@"cd_iconShadowBGA"] floatValue];
                NSSize mySize;
                mySize.width = 0;
                mySize.height = -10;
                layer2.shadowOpacity = alpha / 100.0;
                layer2.shadowColor = [goodColor2 CGColor];
                layer2.shadowRadius = size;
                layer2.shadowOffset = mySize;
            }
        }
    }
    
    if ([[[Preferences sharedInstance] objectForKey:@"cd_hideLabels"] boolValue]) {
        for (CALayer *layer in self.sublayers) {
            layer.hidden = YES;
        }
    } else {
        for (CALayer *layer in self.sublayers) {
            layer.hidden = NO;
        }
    }
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
        
        // Prevent coloration of frost layer and misssion control bar
        if (self.superlayer.class != NSClassFromString(@"Dock.FloorLayer") && self.superlayer.class != NSClassFromString(@"CALayer")) {
            
//            NSLog(@"%@", self.debugDescription);
            
            NSUInteger _material = ZKHookIvar(self, NSUInteger, "_material");
            if (_material != 0) {
                float red = [[[Preferences sharedInstance] objectForKey:@"cd_labelBGR"] floatValue];
                float green = [[[Preferences sharedInstance] objectForKey:@"cd_labelBGG"] floatValue];
                float blue = [[[Preferences sharedInstance] objectForKey:@"cd_labelBGB"] floatValue];
                float alpha = [[[Preferences sharedInstance] objectForKey:@"cd_labelBGA"] floatValue];
                NSColor *goodColor = [NSColor colorWithRed:red/255.0 green:green/255 blue:blue/255.0 alpha:1.0];
                CALayer *tintLayer = ZKHookIvar(self, CALayer *, "_backdropLayer");
                [tintLayer setBackgroundColor:[goodColor CGColor]];
                [tintLayer setOpacity:( alpha / 100.0 )];
            }
            
        }
    }
}
@end