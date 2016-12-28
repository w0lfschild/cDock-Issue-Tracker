//
//  cDockLabel.m
//

@import QuartzCore;
#import "cd_shared.h"

ZKSwizzleInterface(__CDthing, ECStatusLabelLayer, CALayer);
@implementation __CDthing
- (void)_renderBadgeImage {
    ZKOrig(void);
//    [self setBackgroundColor:[[NSColor whiteColor] CGColor]];
//    [self setOpacity:1];
    NSLog(@"wb_ norender");
}

- (void)layoutForFrame:(struct CGRect)arg1 {
    CGRect adjustedFrame = arg1;
    adjustedFrame.origin.x -= adjustedFrame.size.width / 2;
    adjustedFrame.origin.y -= adjustedFrame.size.height / 2;
    adjustedFrame.size.height *= 2;
    adjustedFrame.size.width *= 2;
    
    ZKOrig(void, adjustedFrame);
    
    self.cornerRadius = self.frame.size.height / 2;
    
    CALayer *img = ZKHookIvar(self, CALayer*, "_imageLayer");
    [img setHidden:true];
    [self setBackgroundColor:[[NSColor blueColor] CGColor]];
    [self setOpacity:1];
    
    NSString *value =  ZKHookIvar(ZKHookIvar(self, NSObject*, "_labelDescription"), NSString*, "_string");
    NSLog(@"wb_ value:%@", value);
    
    CATextLayer *txt = nil;
    
    // Check if our custom layer exists, if it does then reference it
    for (NSObject *item in (NSMutableArray *)self.sublayers)
        if ([item.className isEqualToString:@"CATextLayer"]) {
            txt = (CATextLayer*)item;
            break;
        }
    
    CGRect newFrame = self.frame;
    newFrame.origin.x = 0;
    newFrame.origin.y = -newFrame.size.height / 8;
    
//    NSLog(@"wb_ new_frame:%@", NSStringFromRect(newFrame));
//    NSLog(@"wb_ label_frame:%@", NSStringFromRect(labelRect));
    
    if (txt == nil)
    {
        CATextLayer *label = [[CATextLayer alloc] init];
        [label setFont:@"Helvetica-Bold"];
        [label setFontSize:newFrame.size.height / 2];
        [label setFrame:newFrame];
        [label setString:value];
        [label setAlignmentMode:kCAAlignmentCenter];
        [label setForegroundColor:[[NSColor whiteColor] CGColor]];
        [self addSublayer:label];
    } else {
        [txt setFrame:newFrame];
        [txt setFontSize:newFrame.size.height / 2];
        [txt setString:value];
    }
    
//    NSLog(@"wb_ setup");
}
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
