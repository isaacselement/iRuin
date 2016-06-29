#import "IRUserDefaults.h"

@interface IRUserSetting : IRUserDefaults

// http://stackoverflow.com/questions/12933785/ios-automatic-synthesize-without-creating-an-ivar
@property (nonatomic) int chapter;
@property (nonatomic) NSDate* firtLauchDate;
@property (nonatomic) NSDate* lastLauchDate;

@property (nonatomic) BOOL isMuteMusic;


+ (IRUserSetting*)sharedSetting;


@end
