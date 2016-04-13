#import "AppUserDefaults.h"

#define STANDARDUSERDEFAULTS [NSUserDefaults standardUserDefaults]

@implementation AppUserDefaults

+ (AppUserDefaults*)sharedInstance
{
    static AppUserDefaults *shared = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        shared = [AppUserDefaults new];
    });
    return shared;
}

- (nullable id)objectForKey:(NSString *)defaultName
{
    return [STANDARDUSERDEFAULTS objectForKey:defaultName];
}

- (void)setObject:(nullable id)value forKey:(NSString *)defaultName
{
    [STANDARDUSERDEFAULTS setObject:value forKey:defaultName];
    [STANDARDUSERDEFAULTS synchronize];
}

- (void)removeObjectForKey:(NSString *)defaultName
{
    [STANDARDUSERDEFAULTS removeObjectForKey:defaultName];
    [STANDARDUSERDEFAULTS synchronize];
}

@end
