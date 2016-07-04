#import "IRSystemSetting.h"
#import "AppInterface.h"

@implementation IRSystemSetting

+ (IRSystemSetting*)sharedSetting
{
    static IRSystemSetting *systemSetting = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        systemSetting = [IRSystemSetting new];
    });
    return systemSetting;
}

- (int)resourceVersion
{
    return [[self objectForKey:SYS_ResourcesVersion] intValue];
}

- (void)setResourceVersion:(int)resourceVersion
{
    [self setObject:@(resourceVersion) forKey:SYS_ResourcesVersion];
}

- (NSString *)resourceSandbox
{
    return [self objectForKey:SYS_ResourcesSandbox];
}

- (void)setResourceSandbox:(NSString *)resourceSandbox
{
    [self setObject:resourceSandbox forKey:SYS_ResourcesSandbox];
}

@end
