//
//  cDockIndicator.m
//

#import "Preferences.h"
#import "Opee/Opee.h"
#import <Quartz/Quartz.h>

# define thmePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/org.w0lf.cDock.plist"]
# define thmeName [[NSMutableDictionary dictionaryWithContentsOfFile:thmePath] objectForKey:@"cd_theme"]
# define prefPath [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/cDock/themes/"] stringByAppendingPathComponent:thmeName]
# define prefFile [[prefPath stringByAppendingPathComponent:thmeName ] stringByAppendingString:@".plist"]

extern NSInteger orient;
extern long osx_minor;

ZKSwizzleInterface(_CDIndicatorLayer, DOCKIndicatorLayer, CALayer)
@implementation _CDIndicatorLayer
- (void)updateIndicatorForSize:(float)arg1 {
    ZKOrig(void, arg1);
    
    if (![[[Preferences sharedInstance2] objectForKey:@"cd_enabled"] boolValue])
        return;
    
    //    NSLog(@"%f", arg1);
    
    if ([[[Preferences sharedInstance] objectForKey:@"cd_customIndicator"] boolValue]) {
        self.backgroundColor = NSColor.clearColor.CGColor;
        self.cornerRadius = 0.0;
        
        NSString *iconFile = @"";
        NSString *file_orient = @"";
        if (orient == 0) {
            file_orient = @"";
        } else {
            file_orient = @"_simple";
        }
        
//        NSLog(@"%@", [NSString stringWithFormat:@"%@/indicator_large%@.png", prefPath, file_orient]);
        
//        NSLog(@"%li", (long)arg1);
        if (arg1 > 100) {
            iconFile=[NSString stringWithFormat:@"%@/indicator_large%@.png", prefPath, file_orient];
        } else if (arg1 < 35 ) {
            iconFile=[NSString stringWithFormat:@"%@/indicator_small%@.png", prefPath, file_orient];
        } else {
            iconFile=[NSString stringWithFormat:@"%@/indicator_medium%@.png", prefPath, file_orient];
        }
        
        NSImage *image = [[[NSImage alloc] initWithContentsOfFile:iconFile] autorelease];
        NSImageRep *rep = [[image representations] objectAtIndex:0];
        NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
        
        self.contents = (__bridge id)image;
        self.contentsGravity = kCAGravityBottom;
        if (orient != 0 && osx_minor == 9) {
            self.frame = CGRectMake(self.frame.origin.x, 0, imageSize.width / self.contentsScale, imageSize.height / self.contentsScale);
        }
        if (osx_minor > 10) {
            self.frame = CGRectMake(self.frame.origin.x, 0, imageSize.width / self.contentsScale, imageSize.height / self.contentsScale);
        }
    }
}
@end