#import "IRUserDefaults.h"

@implementation IRUserDefaults


- (nullable id)objectForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void)setObject:(nullable id)value forKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeObjectForKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark -

- (id)get:(NSString*)key
{
    return [self objectForKey: key];
}

- (void)remove:(NSString*)key
{
    [self removeObjectForKey:key];
}

- (void)set:(id)value key:(NSString*)key
{
    [self setObject:value forKey:key];
}


@end
