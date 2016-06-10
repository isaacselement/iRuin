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
    // start the vanish effect
    self.isSymbolsOnVAFSing = YES;
    [[EffectHelper getInstance] startScoresEffect: vanishSymbols];
    [self.effect effectStartVanish: vanishSymbols];
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
