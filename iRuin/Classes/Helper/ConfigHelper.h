#import <Foundation/Foundation.h>

@interface ConfigHelper : NSObject

#pragma mark - Json

+(NSDictionary*) getDesignJson: (NSString*)name;

+(NSDictionary*) getConfigJson: (NSString*)name;

#pragma mark - Config

+(NSDictionary*) getSubConfigWithLoop:(NSDictionary*)configs index:(int)index;

+(NSDictionary*) getSubConfig:(NSDictionary*)configs key:(NSString*)key;

+(NSDictionary*) getSubConfig:(NSDictionary*)configs key:(NSString*)key alternateKey:(NSString*)alternateKey;

#pragma mark - Config Music

+(NSDictionary*) getMusicConfig:(NSString*)key;


#pragma mark - Network Request

+(void) requestDowloadRemoteResources;


@end
