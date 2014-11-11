#import "BaseEvent.h"
#import "AppInterface.h"

@implementation BaseEvent

@synthesize state;


#pragma mark - Subclass Override Methods
- (void)eventInitialize
{
}
- (void)eventTouchesBegan:(SymbolView*)symbol location:(CGPoint)location
{
    [state stateTouchesBegan: symbol location:location];
}
- (void)eventTouchesMoved:(SymbolView*)symbol location:(CGPoint)location
{
    [state stateTouchesMoved: symbol location:location];
}
- (void)eventTouchesEnded:(SymbolView*)symbol location:(CGPoint)location
{
    [state stateTouchesEnded: symbol location:location];
}
- (void)eventTouchesCancelled:(SymbolView*)symbol location:(CGPoint)location
{
    [state stateTouchesCancelled: symbol location:location];
}



#pragma mark - Event Methods
-(void) eventSymbolsWillRollIn
{
     ACTION.gameState.isGameStarted = YES;
}
-(void) eventSymbolsDidRollIn
{
    [VIEW.gameView.timerView resumeTimer];
}

-(void) eventSymbolsWillRollOut
{
    ACTION.gameState.isGameStarted = NO;
}
-(void) eventSymbolsDidRollOut
{

}

//#ifdef DEBUG
//static NSDate* startTime;
//#endif
-(void) eventSymbolsWillVanish: (NSArray*)symbols
{
//#ifdef DEBUG
//    startTime = [NSDate date];
//#endif
    
    ACTION.gameState.isSymbolsOnMovement = YES;
    
    ACTION.gameState.vanishAmount += symbols.count;
}

-(void) eventSymbolsDidVanish: (NSArray*)symbols
{
//#ifdef DEBUG
//    NSLog(@"eventSymbolsDidVanish duration: %f", [[NSDate date] timeIntervalSinceDate: startTime]);
//#endif
    
    NumberLabel* scoreLabel = VIEW.gameView.scoreLabel;
    for (SymbolView* symbol in symbols){
        scoreLabel.number += symbol.score;
        
        if (![QueueViewsHelper isViewsInVisualAreaContains: symbol]) {
            DLog(@"eventSymbolsDidVanish: %@", symbol);
            symbol.center = VIEW.frame.blackPoint;
        }
        
//        [symbol.layer removeAllAnimations];
    }
}



-(void) eventSymbolsWillAdjusts
{
    
}
-(void) eventSymbolsDidAdjusts
{
    
}


-(void) eventSymbolsWillFillIn
{

}
-(void) eventSymbolsDidFillIn
{
    ACTION.gameState.isSymbolsOnMovement = NO;
}


-(void) eventSymbolsWillSqueeze
{

}
-(void) eventSymbolsDidSqueeze
{
    ACTION.gameState.isSymbolsOnMovement = NO;
}


@end
