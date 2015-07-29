//
//  Opee.h
//  Opee
//
//  Created by Alexander S Zielenski on 7/22/14.
//  Copyright (c) 2014 Alex Zielenski. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//! Project version number for Opee.
FOUNDATION_EXPORT double OpeeVersionNumber;

//! Project version string for Opee.
FOUNDATION_EXPORT const unsigned char OpeeVersionString[];

// Creates a function which is executed when the library loads
#define _OPNAME(NAME, LINE) _OPNAME2(NAME, LINE) // Preprocess hax to get the line to concat
#define _OPNAME2(NAME, LINE) NAME ## LINE
#define OPInitialize __attribute__((__constructor__)) static void _OPNAME(_OPInitialize, __LINE__) ()

#import <Opee/ZKSwizzle.h>
#import <Opee/OPHooker.h>