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
    return [[self get:SYS_ResourcesVersion] intValue];
}

- (void)setResourceVersion:(int)resourceVersion
{
    [self set:@(resourceVersion) key:SYS_ResourcesVersion];
}

- (NSString *)resourceSandbox
{
    return [self get:SYS_ResourcesSandbox];
}

- (void)setResourceSandbox:(NSString *)resourceSandbox
{
    [self set:resourceSandbox key:SYS_ResourcesSandbox];
}

@end
