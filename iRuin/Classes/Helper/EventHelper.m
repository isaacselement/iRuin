#import "EventHelper.h"
#import "AppInterface.h"

@implementation EventHelper

#pragma mark - Music

+(void) playNextBackgroundMusic
{
    [ConfigHelper setNextMusic];
    [self playBackgroundMusic];
}

+(void) playBackgroundMusic
{
    [self runMusicAction:@"PlayActions"];
}

+(void) pauseBackgroundMusic
{
    [self runMusicAction:@"PauseActions"];
}

+(void) resumeBackgroundMusic
{
    [self runMusicAction:@"ResumeActions"];
}

+(void) stopBackgroundMusic
{
    [self runMusicAction:@"StopActions"];
}

+(void) runMusicAction:(NSString*)actionKey
{
    [VIEW.actionExecutorManager runAudioActionExecutors:[ConfigHelper getMusicConfig:actionKey]];
}

@end
