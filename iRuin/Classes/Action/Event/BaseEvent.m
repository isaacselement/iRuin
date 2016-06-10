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
    
    [VIEW.gameView.timerView pauseTimer];
    VIEW.gameView.containerView.userInteractionEnabled = NO;
    [state stateSymbolsWillRollIn];
}

-(void) eventSymbolsDidRollIn
{
    DLOG(@"eventSymbolsDidRollIn");
    
    [VIEW.gameView.timerView startTimer];
    VIEW.gameView.containerView.userInteractionEnabled = YES;
    [state stateSymbolsDidRollIn];
}

-(void) eventSymbolsWillRollOut
{
    [VIEW.gameView.timerView pauseTimer];
    
    [state stateSymbolsWillRollOut];
}

-(void) eventSymbolsDidRollOut
{
    DLOG(@"eventSymbolsDidRollOut");
    [state stateSymbolsDidRollOut];
}

-(void) eventSymbolsDidVanish: (NSArray*)symbols
{
    DLOG(@"eventSymbolsDidVanish");
    
    for (NSArray* innerArray in symbols) {
        for (SymbolView* symbol in innerArray){
            // cause the view will be reused , so here we need to check ~~~~~~
            // get the no reuse symbol to restore
            if (![QueueViewsHelper isViewsInVisualAreaContains: symbol]) {
                [symbol restore];
            }
        }
    }
    
    [state stateSymbolsDidVanish: symbols];
}

-(void) eventSymbolsDidAdjusts
{
    DLOG(@"eventSymbolsDidAdjusts");
    [state stateSymbolsDidAdjusts];
}

-(void) eventSymbolsDidFillIn
{
    DLOG(@"eventSymbolsDidFillIn");
    [state stateSymbolsDidFillIn];
}

-(void) eventSymbolsDidSqueeze
{
    DLOG(@"eventSymbolsDidSqueeze");
    [state stateSymbolsDidSqueeze];
}


@end
