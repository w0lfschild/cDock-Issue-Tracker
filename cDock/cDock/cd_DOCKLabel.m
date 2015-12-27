//
//  cDockLabel.m
//

#import "cd_shared.h"

//extern long osx_minor;

ZKSwizzleInterface(__CDthing, ECStatusLabelLayer, CALayer);
@implementation __CDthing

- (void)_renderBadgeImage {
    ZKOrig(void);
//    [self setBackgroundColor:[[NSColor whiteColor] CGColor]];
//    [self setOpacity:1];
//    NSLog(@"t");
}

//- (id)initWithMaxSize:(double)arg1 scaleFactor:(float)arg2 {
//    NSLog(@"TTT");
//    return ZKOrig(id);
//}

//- (void)layoutForFrame:(struct CGRect)arg1 {
//    ZKOrig(void);
////    [self setBackgroundColor:[[NSColor whiteColor] CGColor]];
////    [self setOpacity:1];
//    NSLog(@"TTT");
//}
@end

ZKSwizzleInterface(__CDLabel, DOCKLabelLayer, CALayer);
@implementation __CDLabel
-(void)layoutSublayers {
    ZKOrig(void);
    
    if (![[[Preferences sharedInstance2] objectForKey:@"cd_enabled"] boolValue])
        return;
    
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
            } else {
                [layer2 setBackgroundColor:[[NSColor clearColor] CGColor]];
                [layer2 setOpacity:1];
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