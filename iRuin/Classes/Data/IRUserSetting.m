#import "IRUserSetting.h"
#import "AppInterface.h"

@implementation IRUserSetting

+ (IRUserSetting*)sharedSetting
{
    static IRUserSetting *sharedSetting = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedSetting = [IRUserSetting new];
    });
    return sharedSetting;
}

#pragma mark -

- (int)chapter
{
    return [[self get:User_ChapterIndex] intValue];
}

- (void)setChapter:(int)chapter
{
    [self set:@(chapter) key:User_ChapterIndex];
}

- (NSDate *)firtLauchDate
{
    return [self get:User_FirstTimeLaunch];
}

- (void)setFirtLauchDate:(NSDate *)firtLauchDate
{
    [self set:firtLauchDate key:User_FirstTimeLaunch];
}

- (NSDate *)lastLauchDate
{
    return [self get:User_LastTimeLaunch];
}

- (void)setLastLauchDate:(NSDate *)lastLauchDate
{
    [self set:lastLauchDate key:User_LastTimeLaunch];
}

- (BOOL)isMuteMusic
{
    return [[self get:@"User_IsMusicDisable"] boolValue];
}

- (void)setIsMuteMusic:(BOOL)isMuteMusic
{
    [self set:@(isMuteMusic) key:@"User_IsMusicDisable"];
}

@end
