#import <Foundation/Foundation.h>

@interface ConfigHelper : NSObject

+(NSDictionary*) getDesignJson: (NSString*)name;

+(NSDictionary*) getConfigJson: (NSString*)name;


#pragma mark - Network Request

+(void) requestDowloadRemoteResources;



+(NSDictionary*) handleDefaultCommonConfig:(NSDictionary*)configs key:(NSString*)key;

@end
