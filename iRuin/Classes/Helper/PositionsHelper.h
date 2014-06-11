#import <Foundation/Foundation.h>

@interface PositionsHelper : NSObject


+(NSMutableArray*) getIndexPathsNullInVisualAreaViews;


+(void) updateAdjustRowsColumnsInVisualArea: (NSMutableArray*)viewsSequence;
+(void) updateFillInRowsColumnsInVisualArea: (NSMutableArray*)viewsSequence;


+(void) updateRowsColumnsInVisualArea: (NSArray*)oneDimensionSymbols;


@end
