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

CGImageRef large;
CGImageRef medium;
CGImageRef small;
CGImageRef medium_simple;
CGImageRef small_simple;

// Loading the images once prevents huge +50% or more CPU usage when mousing over icons with custom image indicators
void load()
{
    CGDataProviderRef imgDataProvider;
    imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/indicator_large.png", prefPath]]);
    large = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
    imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/indicator_medium.png", prefPath]]);
    medium = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
    imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/indicator_small.png", prefPath]]);
    small = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
    imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/indicator_medium_simple.png", prefPath]]);
    medium_simple = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
    imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/indicator_small_simple.png", prefPath]]);
    small_simple = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
}

ZKSwizzleInterface(_CDIndicatorLayer, DOCKIndicatorLayer, CALayer)
@implementation _CDIndicatorLayer
//- (void)dockBackgroundChanged {
//    ZKOrig(void);
//}

- (void)updateIndicatorForSize:(float)arg1 {
    ZKOrig(void, arg1);
    
    if (![[[Preferences sharedInstance2] objectForKey:@"cd_enabled"] boolValue])
        return;
    
//    CALayer *test = self.superlayer;
//    NSLog(@"%@", test.debugDescription);
//    NSLog(@"%f", arg1);
//    NSLog(@"%@", self.debugDescription);
    
    // Note to self this should be precentage based not solid numbers
    if (osx_minor > 9) {
        // Color indicator
        if ([[[Preferences sharedInstance] objectForKey:@"cd_colorIndicator"] boolValue]) {
            self.compositingFilter = nil; // @"plusD";
            float red = [[[Preferences sharedInstance] objectForKey:@"cd_indicatorBGR"] floatValue];
            float green = [[[Preferences sharedInstance] objectForKey:@"cd_indicatorBGG"] floatValue];
            float blue = [[[Preferences sharedInstance] objectForKey:@"cd_indicatorBGB"] floatValue];
            float alpha = [[[Preferences sharedInstance] objectForKey:@"cd_indicatorBGA"] floatValue];
            NSColor *goodColor = [NSColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
            [self setBackgroundColor:[goodColor CGColor]];
            [self setOpacity:(alpha / 100.0)];
            
//            NSLog(@"%f %f %f %f", red, green, blue, alpha);
        }
        
        // Size indicator
        if ([[[Preferences sharedInstance] objectForKey:@"cd_sizeIndicator"] boolValue]) {
            [ self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,
                                       [[[Preferences sharedInstance] objectForKey:@"cd_indicatorWidth"] floatValue],
                                       [[[Preferences sharedInstance] objectForKey:@"cd_indicatorHeight"] floatValue]) ];
        }
        
        // Probably cound add corner radius
    }
    
    // Image indicator
    if ([[[Preferences sharedInstance] objectForKey:@"cd_customIndicator"] boolValue]) {
        static dispatch_once_t once;
        dispatch_once(&once, ^ {
            load();
        });
        
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
        
        self.contents = (__bridge id)image;
        self.contentsGravity = kCAGravityBottom;
        self.frame = CGRectMake(self.frame.origin.x, 0, (CGFloat)CGImageGetWidth(image) / self.contentsScale, (CGFloat)CGImageGetHeight(image) / self.contentsScale);
    } else {
        self.contents = nil;
    }
}
@end