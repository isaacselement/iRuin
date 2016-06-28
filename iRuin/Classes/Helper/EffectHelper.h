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

#pragma mark -

-(void) startChapterCellsEffect: (NSMutableDictionary*)cellsConfigs;

#pragma mark - score

-(void) startScoresEffect:(NSArray*)symbols;

-(void) startChainVanishingEffect: (NSArray*)symbols continuous:(int)continuous;

-(void) stopChainVanishingEffect:(int)continuous;

@end
