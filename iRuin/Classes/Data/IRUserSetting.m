#import "IRUserSetting.h"
#import "AppInterface.h"
#import <objc/runtime.h>


// to do , refactor , iterate the method list and hook it .
@implementation IRUserSetting

//@dynamic chapter;
//@dynamic firstLauchDate;
//@dynamic lastLauchDate;
//@dynamic isMuteMusic;

// without @synthesize , the iVar name will append prefix @"_" . class_getInstanceVariable([self class], ivar_name) in +invoke_in_load_for_subclass: , ivar_name i do not append @"_", so here need @synthesize
@synthesize chapter;
@synthesize isMuteMusic;
@synthesize lastLauchDate;
@synthesize firstLauchDate;


+ (IRUserSetting*)sharedSetting
{
    static IRUserSetting *sharedSetting = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedSetting = [[IRUserSetting alloc] init];
    });
    return sharedSetting;
}

+ (void)load
{
    [self invoke_in_load_for_subclass:@[@"init"]];
}

#pragma mark -

- (instancetype)init
{
    self = [super init];
    if (self) {
        // ---------------2016-07-06---------------
        // ------------------for legacy support
        if ([self objectForKey:@"User_ChapterIndex"]) {
            self.chapter = [[self objectForKey:@"User_ChapterIndex"] intValue];
        }
        if ([self objectForKey:@"User_LastTimeLaunch"]) {
            self.lastLauchDate = [self objectForKey:@"User_LastTimeLaunch"];
        }
        if ([self objectForKey:@"User_FirstTimeLaunch"]) {
            self.firstLauchDate = [self objectForKey:@"User_FirstTimeLaunch"];
        }
        // ---------------2016-07-06---------------
    }
    return self;
}

@end
