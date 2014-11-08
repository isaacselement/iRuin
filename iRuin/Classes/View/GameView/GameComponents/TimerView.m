#import "TimerView.h"
#import "ScheduledTask.h"

@implementation TimerView


@synthesize timerFormat;


- (id)init{
    if (self = [super init]) {
        self.clipsToBounds = NO;
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        self.textAlignment = NSTextAlignmentCenter;
        
        timerFormat = @"%02d : %02d";
    }
    return self;
}


-(void)setTotalTime:(double)totalTime
{
    _totalTime = totalTime;
    _currentTime = totalTime;
    [self showTime: totalTime];
}


-(void) resumeTimer {
    [[ScheduledTask sharedInstance] registerSchedule: self timeElapsed:1 repeats:0];
}

-(void) pauseTimer {
    [[ScheduledTask sharedInstance] unRegisterSchedule: self];
}


-(void) caculateRemainTime {
    if (_currentTime <= 0.0) return;
    
    _currentTime -= 1.0;
    
    // timer is over
    if (_currentTime <= 0 ) {
        _currentTime = 0.0;
        
        // call the block
        if (self.timeIsOverAction) {
            self.timeIsOverAction(self);
        }
    }
    
    [self showTime: _currentTime];
}


-(void) showTime:(double)time {
    int minute = time / 60;
    int second = time - ( 60 * minute );
    NSString* strTime = [NSString stringWithFormat: timerFormat, minute, second];
    self.text = strTime;
}


#pragma mark - Scheduled Action

-(void) scheduledTask
{
    [self caculateRemainTime];
}


@end
