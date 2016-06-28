#import <Foundation/Foundation.h>

@interface ConfigHelper : NSObject

#pragma mark - Json Files

+(NSDictionary*) getDesignJson: (NSString*)name;

+(NSDictionary*) getConfigJson: (NSString*)name;

#pragma mark - Config

+(void) iterateConfig:(NSDictionary*)config handler:(void(^)(NSString* key, id value))handler;

+(NSDictionary*) getLoopConfig:(NSMutableDictionary*)configs index:(int)index;

#pragma mark - Config Category

+(void) setNextMusic;

+(id) getMusicConfig:(NSString*)key;

+(NSArray*) getSupportedModes;

+(int) getSymbolsIdentificationsCount;

+(NSMutableDictionary*) getSymbolsPorperties;

#pragma mark - Network Request

+(void) requestDowloadRemoteResources;


@end
