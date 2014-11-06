#import "StrokeLabel.h"

@interface TimerView : StrokeLabel


@property (assign, nonatomic) double totalTime;

@property (assign, readonly) double currentTime;

@property (copy) void(^timeIsOverAction)(TimerView* timerView);



-(void) resumeTimer ;

-(void) pauseTimer ;



@end
