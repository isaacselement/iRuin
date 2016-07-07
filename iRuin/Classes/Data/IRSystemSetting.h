#import "IRUserDefaults.h"

@interface IRSystemSetting : IRUserDefaults

@property (nonatomic) int resourceVersion;
@property (nonatomic) NSString* resourceSandbox;

@property (nonatomic) NSString* appVersion;

+ (IRSystemSetting*)sharedSetting;

@end
