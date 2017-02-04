//
//  Preferences.m
//

#import "cd_shared.h"

@implementation Preferences

+ (instancetype)sharedInstance {    
	static Preferences *sharedInstance = nil;
    if (dispatch_prefFile)
    {
		sharedInstance = [[self.class alloc] init];
		NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:prefFile];
		sharedInstance->_prefs = [plist mutableCopy];
        dispatch_prefFile = false;
    }
	
	return sharedInstance;
}

+ (instancetype)sharedInstance2 {
    static Preferences *sharedInstance2 = nil;
    if (dispatch_dockFile)
    {
        sharedInstance2 = [[self.class alloc] init];
        NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:thmePath];
        sharedInstance2->_prefs = [plist mutableCopy];
        dispatch_dockFile = false;
    }
    
    return sharedInstance2;
}

- (id)objectForKey:(NSString *)key {
	if ([self->_prefs objectForKey:key]) {
		return [self->_prefs objectForKey:key];
	} else {
		return nil;
	}
}

- (id)valueForKey:(NSString *)key {
    if ([self->_prefs valueForKey:key]) {
        return [self->_prefs valueForKey:key];
    } else {
        return nil;
    }
}

- (id)valueForKeyPath:(NSString *)keyPath {
    if ([self->_prefs valueForKeyPath:keyPath]) {
        return [self->_prefs valueForKeyPath:keyPath];
    } else {
        return nil;
    }
}

- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey
{
    NSData *theData=[NSArchiver archivedDataWithRootObject:aColor];
    [self->_prefs setObject:theData forKey:aKey];
}

- (NSColor *)colorForKey:(NSString *)aKey
{
    NSColor *theColor=nil;
    NSData *theData=[[self->_prefs objectForKey:aKey] data];
    if (theData != nil)
        theColor=(NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
    return theColor;
}

@end
