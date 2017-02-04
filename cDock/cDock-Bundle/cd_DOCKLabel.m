//
//  cDockLabel.m
//

// Label hide and show and Mavericks label coloring

#import "cd_shared.h"

ZKSwizzleInterface(__CDLabel, DOCKLabelLayer, CALayer);
@implementation __CDLabel

-(void)layoutSublayers {
    ZKOrig(void);
    
    if (!iscDockEnabled)
        return;
    
    if (osx_minor == 9) {
        NSColor *_labelColor = _readColor(@"cd_label");
        NSColor *_shadowColor = _readColor(@"cd_iconSahdow");
        NSNumber *_shadowSize = readPref(@"cd_iconSahdow.size");
        NSArray *test = self.sublayers;
        if (test != nil) {
            CALayer *layer2 = [ test objectAtIndex:0 ];
            if ([readPref(@"cd_label.enabled") boolValue]) {
                [layer2 setBackgroundColor:[_labelColor CGColor]];
                [layer2 setOpacity:([readPref(@"cd_label.alp") floatValue] / 100.0)];
                [layer2 setCornerRadius: 10];
                if (test.count > 1)
                    [[test objectAtIndex:1] setContents:nil];
            } else {
                [layer2 setBackgroundColor:[[NSColor clearColor] CGColor]];
                [layer2 setOpacity:1];
            }
            if ([readPref(@"cd_iconShadow.enabled") boolValue]) {
                NSSize mySize = NSMakeSize(0, -10);
                [layer2 setShadowOpacity:[readPref(@"cd_iconShadow.alp") floatValue] / 100.0];
                [layer2 setShadowColor:[_shadowColor CGColor]];
                [layer2 setShadowRadius:_shadowSize.floatValue];
                [layer2 setShadowOffset:mySize];
            }
        }
    }
    
    if ([readPref(@"cd_hideLabels") boolValue]) {
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
