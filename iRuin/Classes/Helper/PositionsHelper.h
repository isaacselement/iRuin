#import <Foundation/Foundation.h>

@interface PositionsHelper : NSObject


+(NSMutableArray*) getViewsInContainerInVisualArea;
+(NSMutableArray*) getNullIndexPathsInVisualAreaViews;

+(void) updateViewsRowsColumnsInVisualArea: (NSMutableArray*)viewsSequence;

+(void) updateRowsColumnsInVisualArea: (NSArray*)oneDimensionSymbols;


@end
