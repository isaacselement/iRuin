#import "BaseState.h"
#import "AppInterface.h"

@implementation BaseState

@synthesize effect;

#pragma mark - Subclass Override Methods

-(void) stateInitialize
{
}

-(void) stateUnInitialize
{
}

-(void) stateTouchesBegan:(SymbolView*)symbol location:(CGPoint)location
{
    [effect effectTouchesBegan: symbol location:location];
}

-(void) stateTouchesMoved:(SymbolView*)symbol location:(CGPoint)location
{
//    [effect effectTouchesMoved: symbol location:location];    // give to everyone state to handle it.
}

-(void) stateTouchesEnded:(SymbolView*)symbol location:(CGPoint)location
{
    [effect effectTouchesEnded: symbol location:location];
}

-(void) stateTouchesCancelled:(SymbolView*)symbol location:(CGPoint)location
{
    [effect effectTouchesCancelled: symbol location:location];
}

#pragma mark - Public Methods

-(void) stateSymbolsWillRollIn
{
    
}

-(void) stateSymbolsDidRollIn
{
    [[ScoreHelper getInstance] setupClearedSeasonStatus];
}

-(void) stateSymbolsWillRollOut
{
    
}

-(void) stateSymbolsDidRollOut
{
    
}

-(void) stateStartVanishSymbols: (NSMutableArray*)vanishSymbols
{
    // two dimension, nil return. cause the callers didn't check nil .
    if (!vanishSymbols) return;
    self.isSymbolsOnVAFSing = YES;
    
    ACTION.gameState.vanishCount++;
    
    int viewsCount = 0;
    NSArray* symbolsAtContainer = QueueViewsHelper.viewsInVisualArea;
    for (NSArray* innerViews in vanishSymbols) {
        for (SymbolView* symbol in innerViews) {
            if (symbol.row == -1 || symbol.column == -1) {
                DLOG(@"ERROR!!!! __________________________");
                continue;
            }
            viewsCount++;
            int row = symbol.row;
            int column = symbol.column;
            [[symbolsAtContainer objectAtIndex: row] replaceObjectAtIndex: column withObject:[NSNull null]];
            symbol.row = -1;
            symbol.column = -1;
        }
    }
    ACTION.gameState.vanishViewsAmount += viewsCount;
    
    // start the score & VASF effect
    [[EffectHelper getInstance] startScoresEffect: vanishSymbols];
    [self.effect effectStartVanish: vanishSymbols];
    
    [[ScoreHelper getInstance] checkIsClearedSeasonOnSymbolVanish];
}

-(void) stateSymbolsDidVanish: (NSArray*)symbols
{
    
}

-(void) stateSymbolsDidAdjusts
{
    
}

-(void) stateSymbolsDidFillIn
{
    self.isSymbolsOnVAFSing = NO;
}

-(void) stateSymbolsDidSqueeze
{
    self.isSymbolsOnVAFSing = NO;
}

@end
