#import "EffectHelper.h"
#import "AppInterface.h"

@implementation EffectHelper
{
    NSMutableDictionary* scheduleTaskConfig;
    
    NSArray* imagesValues ;
    
    int imageIndex;
}

static EffectHelper* oneInstance = nil;

+(EffectHelper*) getInstance
{
    if (!oneInstance) {
        oneInstance = [[EffectHelper alloc] init];
    }
    return oneInstance;
}


-(void) updateScheduleTaskConfigAndRegistryToTask
{
    // handler the config
    scheduleTaskConfig = [DictionaryHelper deepCopy:DATA.config[@"GAME_LAUNCH_ScheduleTask"]];
    
    int interval = [scheduleTaskConfig[@"ScheduleTask_Interval"] intValue];
    [scheduleTaskConfig removeObjectForKey:@"ScheduleTask_Interval"];
    
    imagesValues = [scheduleTaskConfig objectForKey:@"view.backgroundView.values"];
    
    [scheduleTaskConfig removeObjectForKey:@"view.backgroundView.values"];
    
    // schedule task
    if (interval == 0) interval = 60;
    [[ScheduledTask sharedInstance] unRegisterSchedule: self];
    [[ScheduledTask sharedInstance] registerSchedule: self timeElapsed:interval repeats:0];
}



#pragma mark - Scheduled Action

-(void) scheduledTask
{
    imageIndex = imageIndex % imagesValues.count;
    NSString* currentImage = [imagesValues objectAtIndex: imageIndex];
    imageIndex++;
    
    NSMutableDictionary* config = scheduleTaskConfig[@"view"][@"backgroundView"][@"Executors"][@"1"];
    [config setObject: currentImage forKey:@"values"];
    
    [ACTION.gameEffect designateValuesActionsTo:VIEW.controller config:scheduleTaskConfig];
}







#pragma mark - Public Methods



-(void) muteBackGroundMusic: (BOOL)isMute
{
    AudiosExecutor* audiosExector = (AudiosExecutor*)[VIEW.actionExecutorManager getActionExecutor: effect_AUDIO];
    NSDictionary* audioPlayers = audiosExector.audiosPlayers;
    NSArray* musics = DATA.config[@"MuteMusic"];
    
    NSOperationQueue *audioFaderQueue = [AudioHandler audioCrossFadeQueue];
    
    for (int i = 0; i < musics.count; i++) {
        NSString* key = musics[i];
        AVAudioPlayer* player = audioPlayers[key];
        if (isMute) {
            MXAudioPlayerFadeOperation *fadeOut = [[MXAudioPlayerFadeOperation alloc] initFadeWithAudioPlayer:player toVolume:0.0 overDuration:2.0];
            [audioFaderQueue addOperation:fadeOut];
        } else {
            MXAudioPlayerFadeOperation *fadeIn = [[MXAudioPlayerFadeOperation alloc] initFadeWithAudioPlayer:player toVolume:0.7 overDuration:2.0];
            [audioFaderQueue addOperation:fadeIn];
        }
    }
}






@end
