#import <Foundation/Foundation.h>

#define DATA [DataManager getInstance]

@interface DataManager : NSObject

+(DataManager*) getInstance ;


-(void) initializeWithData ;


-(NSMutableDictionary*) visualJSON;

-(NSMutableDictionary*) config;

-(void) setConfigByMode: (NSString*)mode;

@end
