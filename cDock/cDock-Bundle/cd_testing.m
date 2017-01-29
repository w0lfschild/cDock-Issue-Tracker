//
//  cd_testing.m
//  cDock
//
//  Created by Wolfgang Baird on 12/31/16.
//  Copyright © 2016 Wolfgang Baird. All rights reserved.
//

#import "cd_shared.h"

struct CPSProcessSerNum {
    unsigned int hi;
    unsigned int lo;
};

ZKSwizzleInterface(wb_DOCKProcessTile, DOCKAppLaunchEvent, NSObject)
@implementation wb_DOCKProcessTile

- (id)initWithTile:(id)arg1 exists:(_Bool)arg2 appLaunch:(_Bool)arg3
{
    NSLog(@"wb_ hooked Tile:%@", arg1);
    return ZKOrig(id, arg1, arg2, arg3);
}
@end
