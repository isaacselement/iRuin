#import "ConfigHelper.h"
#import "AppInterface.h"

@implementation ConfigHelper

#pragma mark - Json Files

+(NSDictionary*) getDesignJson: (NSString*)name
{
    return [self getJson: name key:@"Designs"];
}

+(NSDictionary*) getConfigJson: (NSString*)name
{
    return [self getJson: name key:@"Configs"];
}

+(NSDictionary*) getJson: (NSString*)name key:(NSString*)key
{
    NSString* resourceSandboxPath = [APPStandUserDefaults objectForKey:User_ResourcesSandboxPath];
    NSString* relativeDirectory = StringPathAppend(resourceSandboxPath, key);
    return [self getJson: StringDotAppend(name, key_Json) relativeDirectory:relativeDirectory];
}

+(NSDictionary*) getJson: (NSString*)fileName relativeDirectory:(NSString*)relativeDirectory
{
    NSString* sanboxFilePath = nil;
    if (relativeDirectory) {
        NSString* configPath = StringPathAppend(NSHomeDirectory(), relativeDirectory);
        NSString* configFilePath = StringPathAppend(configPath, fileName);
        if ([FileManager isFileExist: configFilePath]) {
            sanboxFilePath = configFilePath;
        }
    }
    if (sanboxFilePath) {
        NSDictionary* result = [JsonFileManager getJsonFromPath: sanboxFilePath];
        if (result) {
            return result;
        }
    }
    return [JsonFileManager getJsonFromPath: BUNDLEFILE_PATH(fileName)];
}


#pragma mark - Config

+(void) iterateConfig:(NSDictionary*)config handler:(void(^)(NSString* key, id value))handler
{
    for (NSString* key in config) {
        if ([key hasPrefix:kReserved]) continue;
        if ([key hasSuffix:kSuffixIgnore]) continue;
        handler(key, config[key]);
    }
}

+(int) getKeysCount:(NSDictionary*)config
{
    __block int count = 0 ;
    [self iterateConfig:config handler:^(NSString *key, id value) {
        count++;
    }];
    return count;
}

+(NSDictionary*) getLoopConfig:(NSMutableDictionary*)configs index:(int)index
{
    NSDictionary* loopConfig = configs[kReservedLoop];
    NSArray* keyPaths = loopConfig[@"keyPaths"];
    NSArray* values = loopConfig[@"values"];
    
    if (!loopConfig || values.count == 0) {
        return configs;
    }
    
    for (int j = 0; j < keyPaths.count; j++) {
        NSString* setKeyPath = keyPaths[j];
        NSArray* setValues = [values safeObjectAtIndex:j];
        if (!setValues) setValues = [values lastObject];
        
        // get the new value
        int circleIndex = abs(index) % [setValues count];
        id newValue = [setValues objectAtIndex:circleIndex];
        
        // if keys.count == 1, or keys.count >= 2
        NSMutableDictionary* handleConfig = configs;
        NSArray* keys = [setKeyPath componentsSeparatedByString:@"."];
        for (int i = 0; i < keys.count - 1; i++) {
            handleConfig = [handleConfig objectForKey: keys[i]];
        }
        // get the key
        NSString* handleKey = [keys lastObject];
        
        // set value
        [handleConfig setObject:newValue forKey:handleKey];
    }

    return configs;
}

// key == nil , use default config , then combine with common config .
// so if key == nil , default config == nil , then result is the common config .
+(NSDictionary*) getNodeConfig:(NSDictionary*)configs key:(NSString*)key
{
    NSDictionary* commonConfig = configs[kReservedCommon];
    NSDictionary* defaultConfig = configs[kReservedDefault];
    
    NSDictionary* result = nil;
    if(key) {
        result = configs[key];
    }
    if (!result) {
        result = defaultConfig;
    }
    if (commonConfig) {
        result = [DictionaryHelper combines:commonConfig with:result];
    }
    return result;
}

#pragma mark - Config Category
int musicIndex = 0;
+(void) setNextMusic
{
    musicIndex++;
}
+(id) getMusicConfig:(NSString*)key
{
    // change the config
    NSDictionary* config = [self getLoopConfig:DATA.config[@"GAME_MUSIC"] index:musicIndex];
    return config[key];
}

+(id) getUtilitiesConfig:(NSString*)key
{
    return DATA.config[@"Utilities"][key];
}

+(NSArray*) getSupportedModes
{
    return DATA.config[@"Supported_Modes"];
}

+(int) getSymbolsIdentificationsCount
{
    return [ConfigHelper getKeysCount:[ConfigHelper getSymbolsPorperties]];
}

+(NSDictionary*) getSymbolsPorperties
{
    return DATA.config[@"SYMBOLS_PORPERTIES"];
}

+(void) initializeViewsWithConfig:(NSDictionary*)config onObject:(id)onObject
{
    [ConfigHelper iterateConfig:config handler:^(NSString *key, id value) {
        if ([key isEqualToString: @"class"]) {
            return ;
        }
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSString* clazz = value[@"class"];
            if (clazz) {
                id newObj = [[NSClassFromString(clazz) alloc] init];
                [onObject setValue:newObj forKey:key];
//                [[KeyValueHelper sharedInstance] setValue:newObj keyPath:key object:onObject];
            }
            id nextObject = [onObject valueForKey:key];
            [ConfigHelper initializeViewsWithConfig:value onObject:nextObject];
        }
    }];
}

#pragma mark - Network Request

+(void) requestDowloadRemoteResources
{
    NSString* definedURL = [ConfigHelper getUtilitiesConfig:@"ResourcesSpecificationURL"];
    if (!definedURL) return;
    HTTPGetRequest* definedRequest = [[HTTPGetRequest alloc] initWithURLString: definedURL parameters:nil];
    
    [definedRequest startRequest:^(HTTPRequestBase *httpRequest, NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (! connectionError && [(NSHTTPURLResponse*) response statusCode] < 400) {
            NSError* error = nil;
            NSDictionary* specification = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingAllowFragments error:&error];
            
            if (!error && specification) {
                int version = [specification[@"version"] intValue];
                NSString* resourcesURL = specification[@"resourcesURL"];
                NSString* inSandboxPath = specification[@"inSandboxPath"];
                BOOL isProduction = [specification[@"isProduction"] boolValue];
                BOOL isSetupImmediately = [specification[@"isSetupImmediately"] boolValue];
                
                int currentVersion = [[APPStandUserDefaults objectForKey: User_ResourcesVersion] intValue];
                BOOL isNewerVersion = version > currentVersion;
                
                if (isProduction && isNewerVersion) {
                    NSString* zipFileName = [resourcesURL lastPathComponent];
                    NSString* inSandboxFullPath = StringPathAppend(NSHomeDirectory(), inSandboxPath);
                    NSString* zipFileFullPath = StringPathAppend(inSandboxFullPath, zipFileName);
                    
                    
                    // Get resources.zip
                    HTTPGetRequest* resourcesRequest = [[HTTPGetRequest alloc] initWithURLString:resourcesURL parameters:nil];
                    
                    [resourcesRequest startRequest:^(HTTPRequestBase *httpRequest, NSURLResponse *response, NSData *data, NSError *connectionError) {
                        if (! connectionError && [(NSHTTPURLResponse*) response statusCode] < 400) {
                            // save
                            [FileManager writeDataToFile:zipFileFullPath data:data];
                            
                            // un compress
                            NSError* unZipError = nil;
                            [SSZipArchive unzipFileAtPath:zipFileFullPath toDestination:inSandboxFullPath overwrite:YES password:nil error:&unZipError];
                            
                            // delete
                            [FileManager deleteFile:zipFileFullPath];
                            
                            // save to user defaults
                            NSString* resourceSandboxPath = StringPathAppend(inSandboxPath, [zipFileName stringByDeletingPathExtension]);
                            [APPStandUserDefaults setObject: @(version) forKey:User_ResourcesVersion];
                            [APPStandUserDefaults setObject: resourceSandboxPath forKey:User_ResourcesSandboxPath];
                            
                            // if setup immediately
                            if (isSetupImmediately) [DATA prepareShareDesignsConfigs];
                            DLOG(@"Did renew json!!!");
                        }
                    }];
                }
            }
        }
    }];
}


@end
