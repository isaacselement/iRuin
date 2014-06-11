#import <Foundation/Foundation.h>

@class BaseEffect;
@class SymbolView;

@interface BaseState : NSObject

@property (assign) BaseEffect* effect;

#pragma mark - Subclass Override Methods
-(void) stateInitialize;
-(void) stateTouchesBegan:(SymbolView*)symbol location:(CGPoint)location;
-(void) stateTouchesMoved:(SymbolView*)symbol location:(CGPoint)location;
-(void) stateTouchesEnded:(SymbolView*)symbol location:(CGPoint)location;
-(void) stateTouchesCancelled:(SymbolView*)symbol location:(CGPoint)location;


#pragma mark - Public Methods
-(NSMutableArray*) ruinVanishedSymbols: (NSArray*)symbols;
-(void) stateStartNextPhase: (NSArray*)nullRowColumns;



-(void) stateStartAdjusts: (NSArray*)nullRowColumns;
-(void) stateStartFillIn;
-(void) stateStartSqueeze: (NSArray*)nullRowColumns;

@end
