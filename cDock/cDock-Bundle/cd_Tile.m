//
//  cd_Tile.m
//  cDock
//
//  Created by Wolfgang Baird on 12/30/16.
//  Copyright © 2016 Wolfgang Baird. All rights reserved.
//

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
@end

ZKSwizzleInterface(_CDTile, Tile, NSObject);
@implementation _CDTile

- (void)doCommand:(unsigned int)arg1;
{
    ZKOrig(void, arg1);
    //    NSLog(@"%d", arg1);
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
    
    /* Remove finder icon*/
    if ([self.className isEqualToString:@"DOCKDesktopTile"])
    {
//        [(Tile*)self willBeRemovedFromDock];
//        [(Tile*)self doCommand:1004];
    }
    
    /* Remove trash icon*/
    if ([self.className isEqualToString:@"DOCKTrashTile"])
    {
//        [(Tile*)self setHidden:true];
//        [(Tile*)self willBeRemovedFromDock];
//        [(Tile*)self doCommand:1004];
    }
}

- (void)removeIndicator {
    ZKOrig(void);
    
    //    [(Tile*)self setSelected:true];
    
    CALayer *_tileLayer = ZKHookIvar(self, CALayer *, "_layer");
    for (CALayer *item in (NSMutableArray *)_tileLayer.sublayers)
        if ([item.name  isEqual:@"_reflectionLayer"]) {
            item.hidden = YES;
            break;
        }
}

- (void)addIndicator {
    ZKOrig(void);
    
    //    [(Tile*)self setSelected:false];
    
    CALayer *_tileLayer = ZKHookIvar(self, CALayer *, "_layer");
    for (CALayer *item in (NSMutableArray *)_tileLayer.sublayers)
        if ([item.name  isEqual:@"_reflectionLayer"]) {
            item.hidden = NO;
            break;
        }
    //    NSUInteger count;
    //    Ivar *vars = class_copyIvarList([self.superclass class], &count);
    //    for (NSUInteger i=0; i<count; i++) {
    //        Ivar var = vars[i];
    //        NSLog(@"%s %s", ivar_getName(var), ivar_getTypeEncoding(var));
    //    }
    //    free(vars);
}

- (void)update {
    ZKOrig(void);
    
    unsigned int bstop = ZKHookIvar(self, unsigned int, "bounceStop");
    float moveMe = ZKHookIvar(self, float, "bounceNow");
    
    CALayer *_iconLayer = ZKHookIvar(self, CALayer *, "_layer");
    CALayer *_reflectionLayer = nil;
    
    // Check if our custom layer exists, if it does then reference it
    for (CALayer *item in (NSMutableArray *)_iconLayer.sublayers)
        if ([item.name  isEqual:@"_reflectionLayer"]) {
            _reflectionLayer = item;
            break;
        }
    
    CGRect frm = _reflectionLayer.frame;
    
    if (orig == 999)
    {
        if (orient == 0) {
            orig = _reflectionLayer.frame.origin.y;
            orig2 = _iconLayer.frame.origin.y;
        } else {
            orig = _reflectionLayer.frame.origin.x;
            orig2 = _iconLayer.frame.origin.x;
        }
    }
    
    //    NSLog(@"Launching   : %f", moveMe);
    //    NSLog(@"Bounce Stop : %u", bstop);
    
    if (moveMe != 0.0)
    {
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
    
    if (![[[Preferences sharedInstance2] objectForKey:@"cd_enabled"] boolValue])
        return;
    
    // DO NOT USE
    // 10.9 crash 10.10+ sometimes saves replacement to dock plist
    // either scenario sucks
    //    object_setInstanceVariable(self, "fLabel", @"");
    //    [(Tile*)self setLabel:@"" stripAppSuffix:false];
    
    if ([[[Preferences sharedInstance] objectForKey:@"cd_darkenMouseOver"] boolValue])
        [(Tile*)self setSelected:true];
}

- (void)labelDetached {
    ZKOrig(void);
    
    if (![[[Preferences sharedInstance2] objectForKey:@"cd_enabled"] boolValue])
        return;
    
    if ([[[Preferences sharedInstance] objectForKey:@"cd_darkenMouseOver"] boolValue])
        [(Tile*)self setSelected:false];
}
@end
