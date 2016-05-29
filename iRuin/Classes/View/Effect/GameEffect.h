#import <Foundation/Foundation.h>

@interface GameEffect : NSObject

-(void) designateValuesActionsTo: (id)object config:(NSDictionary*)config completion:(void(^)(void))completion;

-(void) designateValuesActionsTo: (id)object config:(NSDictionary*)config;

@end
