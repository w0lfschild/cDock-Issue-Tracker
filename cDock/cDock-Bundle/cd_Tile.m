//
//  cd_Tile.m
//  cDock

// Icon reflections, hiding, dimming, bouncing

#import "cd_shared.h"

double orig = 999;
double orig2 = 999;

struct FloatRect
{
    float left;
    float top;
    float right;
    float bottom;
};

@interface Tile : NSObject
{
    unsigned int bouncing:1;
    struct CGRect fGlobalBounds;
}
- (void)setSelected:(BOOL)arg1;
- (void)setLabel:(id)arg1 stripAppSuffix:(_Bool)arg2;
- (void)setHidden:(BOOL)arg1;
- (void)doCommand:(unsigned int)arg1;
- (id)layer;
- (void)willBeRemovedFromDock;
- (BOOL)hasIndicator;
@end

ZKSwizzleInterface(_CDTile, Tile, NSObject);
@implementation _CDTile

- (void)doCommand:(unsigned int)arg1 {
    ZKOrig(void, arg1);
}

- (BOOL)isRemovable {
    return true;
}

- (void)setGlobalFrame:(struct FloatRect)arg1 {
    /* Move icons */
     
//    CGFloat height = (CGFloat)labs((NSInteger)arg1.top - (NSInteger)arg1.bottom);
//    arg1.bottom -= height * 0.1;
//    arg1.top -= height * 0.1;
    
    ZKOrig(void, arg1);
    
    if (!iscDockEnabled)
        return;
    
    /* Remove finder icon*/
//    if ([readPref(@"cd_hideIcons.finder") boolValue]) {
//        if ([self.className isEqualToString:@"DOCKDesktopTile"]) {
//            [(Tile*)self willBeRemovedFromDock];
//            [(Tile*)self doCommand:1004];
//        }
//    }

    /* Remove trash icon*/
//    if ([readPref(@"cd_hideIcons.trash") boolValue]) {
//        if ([self.className isEqualToString:@"DOCKTrashTile"]) {
//            [(Tile*)self willBeRemovedFromDock];
//            [(Tile*)self doCommand:1004];
//        }
//    }
    
//    CALayer *_iconLayer = ZKHookIvar(self, CALayer *, "_layer");
//    
//    if ([_iconLayer respondsToSelector:@selector(layoutSublayers)])
//        [_iconLayer performSelector:@selector(layoutSublayers)];
//    
//    CALayer *_reflectionLayer = nil;
//    for (CALayer *item in (NSMutableArray *)_iconLayer.sublayers) {
//        if ([item.name  isEqual:@"_reflectionLayer"]) {
//            _reflectionLayer = item;
//            break;
//        }
//    }
//    
//    Boolean isRunning = [(Tile*)self hasIndicator];
//    Boolean isProc = [self.className isEqualToString:@"DOCKProcessTile"] || [self.className isEqualToString:@"DOCKFileTile"];
//    if ([readPref(@"cd_iconReflection") boolValue]) {
//        if (isRunning) {
//            [_reflectionLayer setHidden:NO];
//        } else {
//            if ([readPref(@"cd_dimInactive") boolValue])
//                if (isProc)
//                    [(Tile*)self setSelected:true];
//            if ([readPref(@"cd_appReflection") boolValue])
//                if (isProc)
//                    [_reflectionLayer setHidden:YES];
//                else
//                    [_reflectionLayer setHidden:NO];
//            else
//                [_reflectionLayer setHidden:NO];
//        }
//    }
}

- (void)removeIndicator {
    ZKOrig(void);
    
    if (!iscDockEnabled)
        return;
    
    if ([readPref(@"cd_dimInactive") boolValue])
        if ([self.className isEqualToString:@"DOCKProcessTile"] || [self.className isEqualToString:@"DOCKFileTile"])
            [(Tile*)self setSelected:true];
}

- (void)addIndicator {
    ZKOrig(void);
    
    if (!iscDockEnabled)
        return;
    
    if ([readPref(@"cd_dimInactive") boolValue])
        [(Tile*)self setSelected:false];
}

- (void)update {
    ZKOrig(void);
    
    if (!iscDockEnabled)
        return;
    
    unsigned int bstop = ZKHookIvar(self, unsigned int, "bounceStop");
    float moveMe = ZKHookIvar(self, float, "bounceNow");
    
    CALayer *_iconLayer = ZKHookIvar(self, CALayer *, "_layer");
    CALayer *_reflectionLayer = nil;
    
    // Check if our custom layer exists, if it does then reference it
    for (CALayer *item in (NSMutableArray *)_iconLayer.sublayers) {
        if ([item.name  isEqual:@"_reflectionLayer"]) {
            _reflectionLayer = item;
            break;
        }
    }
    
    CGRect frm = _reflectionLayer.frame;
    
    if (orig == 999) {
        if (orient == 0) {
            orig = _reflectionLayer.frame.origin.y;
            orig2 = _iconLayer.frame.origin.y;
        } else {
            orig = _reflectionLayer.frame.origin.x;
            orig2 = _iconLayer.frame.origin.x;
        }
    }
    
    if (moveMe != 0.0) {
        if (orient == 0) frm.origin.y = orig - 2 * (_iconLayer.frame.origin.y - orig2);
        if (orient == 1) frm.origin.x = orig - 2 * (_iconLayer.frame.origin.x - orig2);
        if (orient == 2) frm.origin.x = orig - 2 * (_iconLayer.frame.origin.x - orig2);
        [_reflectionLayer setFrame:frm];
    }
    
    NSArray *stops = @[@128, @130, @65666, @65664];
    if ([stops containsObject:[NSNumber numberWithUnsignedInt:bstop]]) {
        orig = 999;
        orig2 = 999;
        if (orient == 0) frm.origin.y = (-frm.size.height);
        if (orient == 1) frm.origin.x = (-frm.size.width);
        if (orient == 2) frm.origin.x = (frm.size.width);
        [_reflectionLayer setFrame:frm];
    }
}

- (void)labelAttached {
    ZKOrig(void);
    
    if (!iscDockEnabled)
        return;
    
    if ([readPref(@"cd_darkenMouseOver") boolValue])
        [(Tile*)self setSelected:true];
}

- (void)labelDetached {
    ZKOrig(void);
    
    if (!iscDockEnabled)
        return;
    
    if ([readPref(@"cd_darkenMouseOver") boolValue]) {
        if ([readPref(@"cd_dimInactive") boolValue]) {
            if (![self.className isEqualToString:@"DOCKProcessTile"] || ![self.className isEqualToString:@"DOCKFileTile"])
                [(Tile*)self setSelected:false];
            if([(Tile*)self hasIndicator])
                [(Tile*)self setSelected:false];
        } else {
            [(Tile*)self setSelected:false];
        }
    }
}
@end
