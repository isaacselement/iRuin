#import <Foundation/Foundation.h>

@interface ConfigHelper : NSObject

#pragma mark - Json Files

+(NSDictionary*) getDesignJson: (NSString*)name;

+(NSDictionary*) getConfigJson: (NSString*)name;

#pragma mark - Config

+(void) iterateConfig:(NSDictionary*)config handler:(void(^)(NSString* key, id value))handler;

+(int) getKeysCount:(NSDictionary*)config;

+(NSDictionary*) getLoopConfig:(NSMutableDictionary*)configs index:(int)index;

+(NSDictionary*) getNodeConfig:(NSDictionary*)configs key:(NSString*)key;

#pragma mark - Config Category

+(id) getMusicConfig:(NSString*)key;

+(id) getUtilitiesConfig:(NSString*)key;

+(NSArray*) getSupportedModes;

+(int) getSymbolsIdentificationsCount;

+(NSDictionary*) getSymbolsPorperties;

+(void) initializeViewsWithConfig:(NSDictionary*)config onObject:(id)onObject;

#pragma mark - Network Request

+(void) requestDowloadRemoteResources;


@end
