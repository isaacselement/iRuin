#import "BaseEvent.h"
#import "AppInterface.h"

@implementation BaseEvent

@synthesize state;


#pragma mark - Subclass Override Methods
- (void)eventInitialize
{
}
- (void)eventUnInitialize
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
    [IterateHelper iterateTwoDimensionArray:[QueueViewsHelper viewsInVisualArea] handler:^BOOL(NSUInteger outterIndex, NSUInteger innerIndex, id obj, NSUInteger outterCount, NSUInteger innerCount) {
        if (obj == [NSNull null]) return NO;
        SymbolView* symbolView = (SymbolView*)obj;
        symbolView.identification = [SymbolView getOneRandomSymbolIdentification];
        return NO;
    }];
}

-(void) eventSymbolsDidRollIn
{
    [VIEW.gameView.timerView resumeTimer];
    ACTION.gameState.isGameStarted = YES;
}

-(void) eventSymbolsWillRollOut
{
    [VIEW.gameView.timerView pauseTimer];
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
        
        // cause the view will be reused , so here we need to check ~~~~~~
        if (![QueueViewsHelper isViewsInVisualAreaContains: symbol]) {
            symbol.center = VIEW.frame.blackPoint;
            [symbol.layer removeAllAnimations];
        }
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
