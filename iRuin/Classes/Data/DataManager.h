#import <Foundation/Foundation.h>


#define DATA [DataManager getInstance]


@interface DataManager : NSObject


+(DataManager*) getInstance ;


-(void) initializeWithData ;

-(NSMutableDictionary*) config;


-(void) unsetModeChapterConfig;
-(void) setConfigByMode: (NSString*)mode chapter:(int)chapter;


@end
