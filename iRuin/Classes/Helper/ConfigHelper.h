#import <Foundation/Foundation.h>

@interface ConfigHelper : NSObject

+(NSDictionary*) getDesignJson: (NSString*)name;

+(NSDictionary*) getConfigJson: (NSString*)name;


#pragma mark - Network Request

+(void) requestDowloadRemoteResources;



+(NSDictionary*) getSubConfig:(NSDictionary*)configs key:(NSString*)key;

+(NSDictionary*) getSubConfig:(NSDictionary*)configs key:(NSString*)key alternateKey:(NSString*)alternateKey;

@end
