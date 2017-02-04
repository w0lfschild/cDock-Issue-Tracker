//
//  Preferences.h
//

@import AppKit;

@interface Preferences : NSObject {
	NSMutableDictionary *_prefs;
}
+ (instancetype)sharedInstance;
+ (instancetype)sharedInstance2;
- (id)objectForKey:(NSString *)key;
- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey;
- (NSColor *)colorForKey:(NSString *)aKey;
@end
