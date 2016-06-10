#import <Foundation/Foundation.h>

#define VISUAL_POSITIONS @"VISUAL.POSITIONS"
#define PHASES_POSITIONS @"PHASES.POSITIONS"
#define CONFIG_POSITIONS @"CONFIG.POSITIONS"
#define SYMBOLS_ACTIONEXECUTORS @"SYMBOLS_ACTIONEXECUTORS"


#define RollIn @"RollIn"
#define RollOut @"RollOut"

#define Vanish @"Vanish"

#define Adjusts @"Adjusts"
#define FillIn @"FillIn"

#define SqueezeEnable @"SqueezeEnable"
#define Squeeze_Adjust @"Squeeze.Adjust"
#define Squeeze_FillIn @"Squeeze.FillIn"


#define LINES @"LINES"
#define INDEXPATHS @"INDEXPATHS"

#define IsReverse @"isReverse"
#define IsBackward @"isBackward"
#define IsColumnBase @"isColumnBase"


#define TouchesBegan @"TouchesBegan"
#define TouchesMoved @"TouchesMoved"
#define TouchesEnded @"TouchesEnded"
#define TouchesCancelled @"TouchesCancelled"


@class BaseEvent;
@class SymbolView;
@class QueueTimeCalculator;

@interface BaseEffect : NSObject

@property (assign) BaseEvent* event;

@property (assign) BOOL isSqueezeEnable ;



#pragma mark - Subclass Override Methods

- (void)effectInitialize;
- (void)effectUnInitialize;
- (void)effectTouchesBegan:(SymbolView*)symbol location:(CGPoint)location;
- (void)effectTouchesMoved:(SymbolView*)symbol location:(CGPoint)location;
- (void)effectTouchesEnded:(SymbolView*)symbol location:(CGPoint)location;
- (void)effectTouchesCancelled:(SymbolView*)symbol location:(CGPoint)location;



#pragma mark - Public Methods

-(void) effectStartRollIn ;
-(void) effectStartRollOut;
-(void) effectStartVanish: (NSArray*)symbols;
-(void) effectStartAdjustFillSqueeze:(NSArray*)vanishingViews vanishDuration:(double)vanishDuration;


#pragma mark - Squeeze & Adjust & Fill

-(void) effectStartSqueeze:(NSArray*)vanishingViews vanishDuration:(double)vanishDuration;
-(double) effectStartAdjust:(NSArray*)vanishingViews vanishDuration:(double)vanishDuration;
-(void) effectStartFill:(NSArray*)vanishingViews fillDelayTime:(double)fillDelayTime;



// Adjust is the phase of adjusting the empty
// FillIn is the pahse of filling the empty, waiting until Adjust done , do FillIn
// Squeeze is the connected phase of Adjust and Fill , just not waiting until Adjust done and start the FillIn simultaneously. You should choose one of Adjust or Squeeze when vanish done to continue.



// Note , when vanish top line views , could cause no views to adjust , and do fill directly.



@end
