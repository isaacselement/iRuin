#import <Foundation/Foundation.h>


typedef NSArray*(^ViewsInRepositoryPositionsHandler)(NSArray* lines, NSArray* indexPaths, NSArray* groupedNullIndexpaths, NSDictionary* linesConfig, NSArray* vanishingViews);


@interface EffectHelper : NSObject


+(EffectHelper*) getInstance;




#pragma mark - Queue Views Positiosn Handler

-(ViewsInRepositoryPositionsHandler) fillInViewsPositionsHandler;

-(ViewsInRepositoryPositionsHandler) adjustViewsInVisualPositionsHandler;

-(ViewsInRepositoryPositionsHandler) rollInViewsInRepositoryPositionsHandler;

-(ViewsInRepositoryPositionsHandler) rollOutViewsInRepositoryPositionsHandler;



#pragma mark - Bonus Effect

-(void) scoreWithEffect:(NSArray*)symbols;

-(void) chainScoreWithEffect: (NSArray*)symbols continuous:(int)continuous;


@end
