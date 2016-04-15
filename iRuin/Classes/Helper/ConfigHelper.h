#import <Foundation/Foundation.h>

@interface ConfigHelper : NSObject

#pragma mark - Json

+(NSDictionary*) getDesignJson: (NSString*)name;

+(NSDictionary*) getConfigJson: (NSString*)name;

#pragma mark - Config

+(NSDictionary*) getLoopConfig:(NSMutableDictionary*)configs index:(int)index;

+(NSDictionary*) getNodeConfig:(NSDictionary*)configs key:(NSString*)key;

#pragma mark - Config Category

+(id) getMusicConfig:(NSString*)key;

+(id) getUtilitiesConfig:(NSString*)key;

#pragma mark - Network Request

+(void) requestDowloadRemoteResources;


@end
