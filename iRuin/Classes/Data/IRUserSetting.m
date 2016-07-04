#import "IRUserSetting.h"
#import "AppInterface.h"


// to do , refactor , iterate the method list and hook it .
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
    return [[self objectForKey:User_ChapterIndex] intValue];
}

- (void)setChapter:(int)chapter
{
    [self setObject:@(chapter) forKey:User_ChapterIndex];
}

- (NSDate *)firtLauchDate
{
    return [self objectForKey:User_FirstTimeLaunch];
}

- (void)setFirtLauchDate:(NSDate *)firtLauchDate
{
    [self setObject:firtLauchDate forKey:User_FirstTimeLaunch];
}

- (NSDate *)lastLauchDate
{
    return [self objectForKey:User_LastTimeLaunch];
}

- (void)setLastLauchDate:(NSDate *)lastLauchDate
{
    [self setObject:lastLauchDate forKey:User_LastTimeLaunch];
}

- (BOOL)isMuteMusic
{
    return [[self objectForKey:@"User_IsMusicDisable"] boolValue];
}

- (void)setIsMuteMusic:(BOOL)isMuteMusic
{
    [self setObject:@(isMuteMusic) forKey:@"User_IsMusicDisable"];
}

@end
