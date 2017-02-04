//
//  cd_Label.m
//

// Icon badge

@import QuartzCore;
#import "cd_shared.h"

ZKSwizzleInterface(__CDthing, ECStatusLabelLayer, CALayer);
@implementation __CDthing

- (void)layoutForFrame:(struct CGRect)arg1 {
    CGRect adjustedFrame = arg1;
//    adjustedFrame.origin.x -= adjustedFrame.size.width / 2;
//    adjustedFrame.origin.y -= adjustedFrame.size.height / 2;
//    adjustedFrame.size.height *= 2;
//    adjustedFrame.size.width *= 2;
    
    ZKOrig(void, adjustedFrame);
    
    if (!iscDockEnabled)
        return;
    
    if ([readPref(@"cd_badge.enabled") boolValue]) {
        NSString *value =  ZKHookIvar(ZKHookIvar(self, NSObject*, "_labelDescription"), NSString*, "_string");
        if ([[NSScanner scannerWithString:value] scanInt:nil]) {
            self.cornerRadius = self.frame.size.height / 2;
        
            CALayer *img = ZKHookIvar(self, CALayer*, "_imageLayer");
            [img setHidden:true];
            
            NSColor *_newColor = _readColor(@"cd_badge");
            
            [self setBackgroundColor:[_newColor CGColor]];
            [self setOpacity:[readPref(@"cd_badge.alp") floatValue] / 100.0];
        
    //        NSString *value =  ZKHookIvar(ZKHookIvar(self, NSObject*, "_labelDescription"), NSString*, "_string");
    //        NSLog(@"wb_ value:%@", value);
        
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
        
            if (txt == nil) {
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
        }
    }
}

@end
