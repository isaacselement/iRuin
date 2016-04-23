#import "ConfigHelper.h"
#import "AppInterface.h"

@implementation ConfigHelper

#pragma mark - Json

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

+(NSDictionary*) getLoopConfig:(NSMutableDictionary*)configs index:(int)index
{
    NSDictionary* loopConfig = configs[@"~loop"];
    NSArray* keyPaths = loopConfig[@"keyPaths"];
    NSArray* values = loopConfig[@"values"];
    
    if (!loopConfig || keyPaths.count != values.count) {
        return configs;
    }
    
    for (int j = 0; j < values.count; j++) {
        NSString* setKeyPath = keyPaths[j];
        NSArray* setValues = values[j];
        
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
    NSDictionary* commonConfig = configs[kCommon];
    NSDictionary* defaultConfig = configs[kDefault];
    
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

+(id) getMusicConfig:(NSString*)key
{
    return DATA.config[@"GAME_MUSIC"][key];
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

+(int) getKeysCount:(NSDictionary*)config
{
    int count = 0 ;
    for (NSString* key in config) {
        if ([key hasPrefix:kReserved]) continue;
        if ([key hasSuffix:kSuffixIgnore]) continue;
        if ([key isEqualToString:kCommon]) continue;
        if ([key isEqualToString:kDefault]) continue;
        count++;
    }
    return count;
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
