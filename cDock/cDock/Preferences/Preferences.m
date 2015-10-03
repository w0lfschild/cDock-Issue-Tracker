//
//  Preferences.m
//

#import "Preferences.h"
# define thmePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/org.w0lf.cDock.plist"]
# define thmeName [[NSMutableDictionary dictionaryWithContentsOfFile:thmePath] objectForKey:@"cd_theme"]
# define prefPath [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/cDock/themes/"] stringByAppendingPathComponent:thmeName]
# define prefFile [[prefPath stringByAppendingPathComponent:thmeName ] stringByAppendingString:@".plist"]

bool dispatch_prefFile = true;
bool dispatch_dockFile = true;

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
