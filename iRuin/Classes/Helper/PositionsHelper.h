#import <Foundation/Foundation.h>

@interface PositionsHelper : NSObject


+(NSMutableArray*) getNullIndexPathsInVisualAreaViews;
+(NSMutableArray*) getAllNullIndexPathsInVisualAreaViews;

+(void) updateViewsRowsColumnsInVisualArea: (NSMutableArray*)viewsSequence;

+(void) updateRowsColumnsInVisualArea: (NSArray*)oneDimensionSymbols;


@end
