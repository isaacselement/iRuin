#import <Foundation/Foundation.h>

@class BaseEffect;
@class SymbolView;

@interface BaseState : NSObject


@property (assign) BaseEffect* effect;

@property (assign) BOOL isSymbolsOnVAFSing;


#pragma mark - Subclass Override Methods
-(void) stateInitialize;
-(void) stateUnInitialize;
-(void) stateTouchesBegan:(SymbolView*)symbol location:(CGPoint)location;
-(void) stateTouchesMoved:(SymbolView*)symbol location:(CGPoint)location;
-(void) stateTouchesEnded:(SymbolView*)symbol location:(CGPoint)location;
-(void) stateTouchesCancelled:(SymbolView*)symbol location:(CGPoint)location;


#pragma mark - Public Methods

-(void) stateSymbolsWillRollIn;
-(void) stateSymbolsDidRollIn;

-(void) stateSymbolsWillRollOut;
-(void) stateSymbolsDidRollOut;

-(void) stateStartVanishSymbols: (NSMutableArray*)vanishSymbols;

-(void) stateSymbolsDidVanish: (NSArray*)symbols;

-(void) stateSymbolsDidAdjusts;

-(void) stateSymbolsDidFillIn;

-(void) stateSymbolsDidSqueeze;


@end
