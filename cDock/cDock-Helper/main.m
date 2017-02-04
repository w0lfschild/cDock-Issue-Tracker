//
//  main.m
//  cDock-Helper
//
//  Created by Wolfgang Baird on 10/3/15.
//  Copyright © 2015 Wolfgang Baird. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
    AppDelegate * delegate = [[AppDelegate alloc] init];
    [[NSApplication sharedApplication] setDelegate:delegate];
    [NSApp run];
    return EXIT_SUCCESS;
//    return NSApplicationMain(argc, argv);
}
