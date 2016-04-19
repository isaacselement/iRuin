#import <Foundation/Foundation.h>


typedef NSArray*(^ViewsInRepositoryPositionsHandler)(NSArray* lines, NSArray* indexPaths, NSArray* groupedNullIndexpaths, NSDictionary* linesConfig, NSArray* vanishingViews);


@interface EffectHelper : NSObject

+(EffectHelper*) getInstance;

-(void) setValue:(id)value forKeyPath:(NSString*)keyPath onObject:(NSObject*)object;

#pragma mark - Queue Views Positiosn Handler

-(ViewsInRepositoryPositionsHandler) fillInViewsPositionsHandler;

-(ViewsInRepositoryPositionsHandler) adjustViewsInVisualPositionsHandler;

-(ViewsInRepositoryPositionsHandler) rollInViewsInRepositoryPositionsHandler;

-(ViewsInRepositoryPositionsHandler) rollOutViewsInRepositoryPositionsHandler;

#pragma mark - score

-(void) scoreWithEffect:(NSArray*)symbols;

-(void) chainScoreWithEffect: (NSArray*)symbols continuous:(int)continuous;


#pragma mark - pass season hint

-(void) showPassedSeasonHint:(int)hideDelay title:(NSString*)title scoreDelay:(int)scoreDelay messageDelay:(int)messageDelay;


@end
