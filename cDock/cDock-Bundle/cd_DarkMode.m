//
//  cd_DarkMode.m
//  

// Force Dock into dark or light mode

#import "cd_shared.h"

ZKSwizzleInterface(wb_CFXPreferences, _CFXPreferences, NSObject)
@implementation wb_CFXPreferences

- (void *)copyAppValueForKey:(struct __CFString *)arg1 identifier:(struct __CFString *)arg2 container:(struct __CFString *)arg3 configurationURL:(struct __CFURL *)arg4 {
    if (iscDockEnabled) {
        if ([(__bridge NSString *)arg1 isEqualToString:@"AppleInterfaceTheme"] || [(__bridge NSString *)arg1 isEqualToString:@"AppleInterfaceStyle"]) {
            if ([readPref(@"cd_darkMode") intValue] == 1) {
                return @"Light";
            } else if ([readPref(@"cd_darkMode") intValue] == 2) {
                return @"Dark";
            } else if ([readPref(@"cd_darkMode") intValue] == 3) {
                if ([(id)ZKOrig(void *, arg1, arg2, arg3, arg4)  isEqual:@"Dark"]) {
                    return @"Light";
                } else {
                    return @"Dark";
                }
            } else {
                return ZKOrig(void *, arg1, arg2, arg3, arg4);
            }
        } else {
            return ZKOrig(void *, arg1, arg2, arg3, arg4);
        }
    } else {
        return ZKOrig(void *, arg1, arg2, arg3, arg4);
    }
}

@end
