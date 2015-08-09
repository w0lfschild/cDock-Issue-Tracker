//
//  DKTrashTIle.m
//  Dockify
//
//  Created by Alexander Zielenski on 4/9/15.
//  Copyright (c) 2015 Alexander Zielenski. All rights reserved.
//

#import "ZKSwizzle.h"
#import <Foundation/Foundation.h>
#import "ECStatusLabelDescription.h"
#import "SGDirWatchdog.h"

@interface NSObject (Tile)
- (void)setStatusLabel:(id)arg1 forType:(int)arg2;
- (void)removeStatusLabelForType:(int)arg1;
@end

static SGDirWatchdog *watchDog = nil;
static NSString *TrashPath = nil;
ZKSwizzleInterface(DKTrashTile, DOCKTrashTile, NSObject)
@implementation DKTrashTile

- (void)dk_updateCount {
    NSMutableArray *filesAtPath = [[NSFileManager defaultManager]
                                   contentsOfDirectoryAtPath:TrashPath error:nil].mutableCopy;
    [filesAtPath removeObject:@".DS_Store"];
    NSUInteger x = [filesAtPath count];
    if (x == 0)
        [self removeStatusLabelForType:1];
    else
        [self setStatusLabel:[[ZKClass(ECStatusLabelDescription) alloc] initWithDefaultPositioningAndString:[NSString stringWithFormat:@"%lu", (unsigned long)x]] forType:1];
}

- (void)resetTrashIcon {
    ZKOrig(void);
    [self dk_updateCount];
}

- (void)changeState:(BOOL)arg1 {
    if (!watchDog) {
        TrashPath = [@"~/.Trash" stringByExpandingTildeInPath];
        __weak DKTrashTile *weakSelf = self;
        watchDog = [[SGDirWatchdog alloc] initWithPath:TrashPath
                                                update:^{
                                                    [weakSelf dk_updateCount];
                                                }];
        [watchDog start];
        [self dk_updateCount];
    }
    
    ZKOrig(void, arg1);
}

- (void)dealloc {
    [watchDog stop];
    watchDog = nil;
    ZKOrig(void);
}

@end
