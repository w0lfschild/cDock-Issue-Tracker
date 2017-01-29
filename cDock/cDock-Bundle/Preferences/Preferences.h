//
//  Preferences.h
//

#import <Foundation/Foundation.h>

@interface Preferences : NSObject {
	NSMutableDictionary *_prefs;
}
+ (instancetype)sharedInstance;
+ (instancetype)sharedInstance2;
- (id)objectForKey:(NSString *)key;
@end