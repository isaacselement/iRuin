#import <Foundation/Foundation.h>

@interface PositionsHelper : NSObject


+(NSMutableArray*) getIndexPathsNullInVisualAreaViews;

+(void) updateViewsRowsColumnsInVisualArea: (NSMutableArray*)viewsSequence;

+(void) updateRowsColumnsInVisualArea: (NSArray*)oneDimensionSymbols;


@end
