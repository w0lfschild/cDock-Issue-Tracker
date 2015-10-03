//
//  cDockIndicator.m
//

#import "Preferences.h"
#import "ZKSwizzle.h"
@import AppKit;

# define thmePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/org.w0lf.cDock.plist"]
# define thmeName [[NSMutableDictionary dictionaryWithContentsOfFile:thmePath] objectForKey:@"cd_theme"]
# define prefPath [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/cDock/themes/"] stringByAppendingPathComponent:thmeName]
# define prefFile [[prefPath stringByAppendingPathComponent:thmeName ] stringByAppendingString:@".plist"]

extern NSInteger orient;
extern long osx_minor;
extern CGImageRef large;
extern CGImageRef medium;
extern CGImageRef small;
extern CGImageRef medium_simple;
extern CGImageRef small_simple;

ZKSwizzleInterface(_CDIndicatorLayer, DOCKIndicatorLayer, CALayer)
@implementation _CDIndicatorLayer
- (void)updateIndicatorForSize:(float)arg1 {
    ZKOrig(void, arg1);
    
//    NSLog(@"Size: %f", arg1);
    
    if (![[[Preferences sharedInstance2] objectForKey:@"cd_enabled"] boolValue])
        return;
    
//    CALayer *test = self.superlayer;
//    NSLog(@"%@", test.debugDescription);
//    NSLog(@"%f", arg1);
//    NSLog(@"%@", self.superlayer.superclass);
    
    // Note to self this should be precentage based not solid numbers
    
    // Color indicator
    if ([[[Preferences sharedInstance] objectForKey:@"cd_colorIndicator"] boolValue]) {
        self.contents = nil;
        self.compositingFilter = nil; // @"plusD";
        float red = [[[Preferences sharedInstance] objectForKey:@"cd_indicatorBGR"] floatValue];
        float green = [[[Preferences sharedInstance] objectForKey:@"cd_indicatorBGG"] floatValue];
        float blue = [[[Preferences sharedInstance] objectForKey:@"cd_indicatorBGB"] floatValue];
        float alpha = [[[Preferences sharedInstance] objectForKey:@"cd_indicatorBGA"] floatValue];
        NSColor *goodColor = [NSColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
        [self setBackgroundColor:[goodColor CGColor]];
        [self setOpacity:(alpha / 100.0)];
    }
    
    // Size indicator
    if ([[[Preferences sharedInstance] objectForKey:@"cd_sizeIndicator"] boolValue]) {
        [ self setFrame:CGRectMake(self.frame.origin.x , self.frame.origin.y,
                                   [[[Preferences sharedInstance] objectForKey:@"cd_indicatorWidth"] floatValue],
                                   [[[Preferences sharedInstance] objectForKey:@"cd_indicatorHeight"] floatValue]) ];
    }
    
    // Probably cound add corner radius
    
    // Image indicator
    if ([[[Preferences sharedInstance] objectForKey:@"cd_customIndicator"] boolValue]) {
        self.compositingFilter = nil; // Prevent Dark/Light mode alteration
        
        self.backgroundColor = NSColor.clearColor.CGColor;
        self.cornerRadius = 0.0;
        
        CGImageRef image = nil;
        
        if (orient == 0) {
            if (arg1 > 100) {
                image = large;
            } else if (arg1 < 35 ) {
                image = small;
            } else {
                image = medium;
            }
        } else {
            if (arg1 < 35 ) {
                image = small_simple;
            } else {
                image = medium_simple;
            }
        }
        
        if (orient == 2) {
            [self setValue:@-1 forKeyPath:@"transform.scale.x"];
        } else {
            self.transform = CATransform3DIdentity;
        }
        
        self.contents = (__bridge id)image;
        self.contentsGravity = kCAGravityBottom;
        self.frame = CGRectMake(self.frame.origin.x, 0, (CGFloat)CGImageGetWidth(image) / self.contentsScale, (CGFloat)CGImageGetHeight(image) / self.contentsScale);
    } else {
//        NSLog(@"What's going on");
        
        self.contents = nil;
        
        if (osx_minor == 9) {
            self.compositingFilter = nil; // @"plusD";
            [self setBackgroundColor:[[NSColor clearColor] CGColor]];
            [self setOpacity:(100.0 / 100.0)];
            float myVar = arg1 * .1;
            if (myVar < 3)
                myVar = 3;
            if (myVar > 8)
                myVar = 8;
            
            [ self setBounds:CGRectMake(self.frame.origin.x, self.frame.origin.y, myVar, myVar) ];
            
            CALayer *sub = nil;
            
            // Look for custom layers
            for (CALayer *item in (NSMutableArray *)self.sublayers)
            {
                if ([item.name isEqual:@"_sub"])
                    sub = item;
            }
            
            // initialize border layer
            if (sub == nil)
            {
                sub = [[CALayer alloc] init];
                [ sub setName:(@"_sub")];
                [ self addSublayer:sub ];
            }
            
            if ([[[Preferences sharedInstance] objectForKey:@"cd_colorIndicator"] boolValue]) {
                float red = [[[Preferences sharedInstance] objectForKey:@"cd_indicatorBGR"] floatValue];
                float green = [[[Preferences sharedInstance] objectForKey:@"cd_indicatorBGG"] floatValue];
                float blue = [[[Preferences sharedInstance] objectForKey:@"cd_indicatorBGB"] floatValue];
                float alpha = [[[Preferences sharedInstance] objectForKey:@"cd_indicatorBGA"] floatValue];
                NSColor *goodColor = [NSColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
                [sub setBackgroundColor:[goodColor CGColor]];
                [sub setOpacity:(alpha / 100.0)];
            } else {
                [sub setBackgroundColor:[[NSColor whiteColor] CGColor]];
            }
            
            double xOrig = self.frame.origin.x;
            if (myVar <= 1)
                xOrig += 10;
            double yOrig = myVar;
            
            if (orient == 0) {
                [sub setFrame:CGRectMake(xOrig, yOrig, myVar, myVar)];
            } else {
                [sub setFrame:CGRectMake(xOrig, self.frame.origin.y, myVar, myVar)];
            }
            
            if (myVar > 7)
                myVar = 7;
            [sub setCornerRadius:myVar];
            
//            if ([[[Preferences sharedInstance] objectForKey:@"cd_sizeIndicator"] boolValue]) {
//                [ sub setFrame:CGRectMake([sub frame].origin.x, myVar,
//                                           [[[Preferences sharedInstance] objectForKey:@"cd_indicatorWidth"] floatValue],
//                                           [[[Preferences sharedInstance] objectForKey:@"cd_indicatorHeight"] floatValue]) ];
//            }
            
//            NSLog(@"%f", self.frame.origin.y);
        }
    }
    
//    SEL aSel = NSSelectorFromString(@"dockBackgroundChanged");
//    [self performSelector:aSel];
}
@end