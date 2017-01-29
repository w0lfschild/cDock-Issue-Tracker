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
@end
