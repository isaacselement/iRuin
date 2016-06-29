#import "IRUserDefaults.h"

@interface IRSystemSetting : IRUserDefaults

@property (nonatomic) int resourceVersion;
@property (nonatomic) NSString* resourceSandbox;

+ (IRSystemSetting*)sharedSetting;

@end
