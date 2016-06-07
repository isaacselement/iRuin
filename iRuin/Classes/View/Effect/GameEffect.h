#import <Foundation/Foundation.h>

@interface GameEffect : NSObject

-(void) designateValuesActionsTo: (id _Nonnull)object config:(NSDictionary* _Nonnull)config completion:( void(^ _Nonnull )(void))completion;

-(void) designateValuesActionsTo: (id _Nonnull)object config:(NSDictionary* _Nonnull)config;

@end
