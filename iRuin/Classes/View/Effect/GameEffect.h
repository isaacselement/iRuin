#import <Foundation/Foundation.h>

@interface GameEffect : NSObject

-(void) designateValuesActionsTo: (id _Nonnull)object config:(NSDictionary* _Nullable)config completion:( void(^ _Nonnull )(void))completion;


-(void) designateToControllerWithConfig:(NSDictionary* _Nullable)config;

-(void) designateValuesActionsTo: (id _Nonnull)object config:(NSDictionary* _Nullable)config;

@end
