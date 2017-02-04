//
//  cDockIndicator.m
//

// Indicators

#import "cd_shared.h"
#import <QuartzCore/QuartzCore.h>

ZKSwizzleInterface(_CDIndicatorLayer, DOCKIndicatorLayer, CALayer)
@implementation _CDIndicatorLayer

- (void)updateIndicatorForSize:(float)arg1 {
    ZKOrig(void, arg1);
    
    [self setZPosition:998];
    
    if (!iscDockEnabled)
        return;
    
    // Note to self this should be precentage based not solid numbers
    
    // Color indicator
    if ([readPref(@"cd_indicator.enabled") boolValue]) {
        self.contents = nil;
        self.compositingFilter = nil; // @"plusD";
        NSColor *_newColor = _readColor(@"cd_indicator");
        [self setBackgroundColor:[_newColor CGColor]];
        [self setOpacity:([readPref(@"cd_indicator.alp") floatValue] / 100.0)];
    }
    
    // Size indicator
    if ([readPref(@"cd_indicator.resize") boolValue])
        [self setFrame:CGRectMake(self.frame.origin.x , self.frame.origin.y, [readPref(@"cd_indicator.width") floatValue], [readPref(@"cd_indicator.height") floatValue]) ];
    
    // Probably cound add corner radius
    
    // Image indicator
    if ([readPref(@"cd_indicator.picture") boolValue]) {
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
            
            [self setBounds:CGRectMake(self.frame.origin.x, self.frame.origin.y, myVar, myVar)];
            
            CALayer *sub = nil;
            
            // Look for custom layers
            for (CALayer *item in (NSMutableArray *)self.sublayers) {
                if ([item.name isEqual:@"_sub"])
                    sub = item;
            }
            
            // initialize border layer
            if (sub == nil) {
                sub = [[CALayer alloc] init];
                [ sub setName:(@"_sub")];
                [ self addSublayer:sub ];
            }
            
            if ([readPref(@"cd_indicator.enabled") boolValue]) {
                [sub setBackgroundColor:[_readColor(@"cd_indicator") CGColor]];
                [sub setOpacity:([readPref(@"cd_indicator.alp") floatValue] / 100.0)];
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
//            [sub setCornerRadius:myVar];
            
            
//            if ([[[Preferences sharedInstance] objectForKey:@"cd_sizeIndicator"] boolValue]) {
//                [ self setFrame:CGRectMake(self.frame.origin.x , self.frame.origin.y,
//                                           [[[Preferences sharedInstance] objectForKey:@"cd_indicatorWidth"] floatValue],
//                                           [[[Preferences sharedInstance] objectForKey:@"cd_indicatorHeight"] floatValue]) ];
//            }
            
            if ([readPref(@"cd_indicator.resize") boolValue]) {
//                [ sub setFrame:CGRectMake([sub frame].origin.x, myVar,
//                                           [[[Preferences sharedInstance] objectForKey:@"cd_indicatorWidth"] floatValue],
//                                           [[[Preferences sharedInstance] objectForKey:@"cd_indicatorHeight"] floatValue]) ];
                float myWidth = [readPref(@"cd_indicator.width") floatValue];
                float myHeight = [readPref(@"cd_indicator.height") floatValue];
                
                float xCenter = self.frame.origin.x + (self.frame.size.width / 2);
                float yCenter = self.frame.origin.y + (self.frame.size.height / 2);
                
                if (orient == 1)
                    xCenter += 1;
                if (orient == 2)
                    xCenter -= 1;
                if (orient == 0)
                    yCenter += 5;
                
                [sub setFrame:CGRectMake(xCenter - myWidth/2, yCenter - (myHeight/2), myWidth, myHeight)];
            }
            
            if (sub.frame.size.width > sub.frame.size.height) {
                [sub setCornerRadius:sub.frame.size.height/2];
            } else {
                [sub setCornerRadius:sub.frame.size.width/2];
            }
        }
    }
    
//    SEL aSel = NSSelectorFromString(@"dockBackgroundChanged");
//    [self performSelector:aSel];
}

@end
