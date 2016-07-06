#import "IRSystemSetting.h"
#import "AppInterface.h"

@implementation IRSystemSetting

//@synthesize resourceVersion;
//@synthesize resourceSandbox;

+ (IRSystemSetting*)sharedSetting
{
    static IRSystemSetting *systemSetting = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        systemSetting = [IRSystemSetting new];
    });
    return systemSetting;
}

+ (void)load
{
    [self invoke_in_load_for_subclass:nil];
}

@end
