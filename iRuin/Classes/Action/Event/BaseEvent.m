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
    
    VIEW.gameView.containerView.userInteractionEnabled = NO;
}

-(void) eventSymbolsDidRollIn
{
    [VIEW.gameView.timerView startTimer];
    ACTION.gameState.isGameStarted = YES;
    
    VIEW.gameView.containerView.userInteractionEnabled = YES;
    
    DLog(@"eventSymbolsDidRollIn");
}

-(void) eventSymbolsWillRollOut
{
    [VIEW.gameView.timerView pauseTimer];
    ACTION.gameState.isGameStarted = NO;
}

-(void) eventSymbolsDidRollOut
{
    DLog(@"eventSymbolsDidRollOut");
}

//#ifdef DEBUG
//static NSDate* startTime;
//#endif
-(void) eventSymbolsWillVanish: (NSArray*)symbols
{
//#ifdef DEBUG
//    startTime = [NSDate date];
//#endif
    
    ACTION.gameState.isSymbolsOnVAFSing = YES;
    
    ACTION.gameState.vanishAmount += symbols.count;
    
    NumberLabel* scoreLabel = VIEW.gameView.scoreLabel;
    for (SymbolView* symbol in symbols) scoreLabel.number += symbol.score;
}

-(void) eventSymbolsDidVanish: (NSArray*)symbols
{
//#ifdef DEBUG
//    DLog(@"eventSymbolsDidVanish duration: %f", [[NSDate date] timeIntervalSinceDate: startTime]);
//#endif
    
    DLog(@"eventSymbolsDidVanish"); 
    
    for (SymbolView* symbol in symbols){
        // cause the view will be reused , so here we need to check ~~~~~~
        if (![QueueViewsHelper isViewsInVisualAreaContains: symbol]) {
            [symbol restore];
        }
    }
}



-(void) eventSymbolsWillAdjusts
{
    
}
-(void) eventSymbolsDidAdjusts
{
    DLog(@"eventSymbolsDidAdjusts");   
}


-(void) eventSymbolsWillFillIn
{

}
-(void) eventSymbolsDidFillIn
{
    ACTION.gameState.isSymbolsOnVAFSing = NO;
    DLog(@"eventSymbolsDidFillIn");
}


-(void) eventSymbolsWillSqueeze
{

}
-(void) eventSymbolsDidSqueeze
{
    ACTION.gameState.isSymbolsOnVAFSing = NO;
    DLog(@"eventSymbolsDidSqueeze"); 
}


@end
