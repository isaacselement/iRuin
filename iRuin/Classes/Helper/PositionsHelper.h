#import <Foundation/Foundation.h>

@interface PositionsHelper : NSObject


+(NSMutableArray*) getViewsInContainerInVisualArea;

+(void) updateViewsRowsColumnsInVisualArea: (NSMutableArray*)viewsSequence;

+(void) updateRowsColumnsInVisualArea: (NSArray*)oneDimensionSymbols;


@end
