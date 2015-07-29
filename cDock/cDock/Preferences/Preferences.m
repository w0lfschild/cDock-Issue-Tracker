//
//  Preferences.m
//

#import "Preferences.h"
# define thmePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/org.w0lf.cDock.plist"]
# define thmeName [[NSMutableDictionary dictionaryWithContentsOfFile:thmePath] objectForKey:@"cd_theme"]
# define prefPath [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/cDock/themes/"] stringByAppendingPathComponent:thmeName]
# define prefFile [[prefPath stringByAppendingPathComponent:thmeName ] stringByAppendingString:@".plist"]

@implementation Preferences
+ (instancetype)sharedInstance {    
	static Preferences *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self.class alloc] init];
		NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:prefFile];
		sharedInstance->_prefs = [plist mutableCopy];
	});
	
	return sharedInstance;
}

+ (instancetype)sharedInstance2 {
    static Preferences *sharedInstance2 = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance2 = [[self.class alloc] init];
        NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:thmePath];
        sharedInstance2->_prefs = [plist mutableCopy];
    });
    
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
