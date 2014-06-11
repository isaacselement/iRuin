#import <Foundation/Foundation.h>

@class SymbolView;

@interface StateHelper : NSObject

+(NSMutableArray*) getViewsInContainer: (NSArray*)views;

+(BOOL) isInContainer: (SymbolView*)symbol;

@end
