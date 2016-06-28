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
    // 1. call sorted keys first
    NSArray* sortedKeys = config[kReservedSortedKeys];
    for (int i = 0; i < sortedKeys.count; i++) {
        NSString* key = sortedKeys[i];
        if ([key hasPrefix:kReserved]) continue;
        if ([key hasSuffix:kSuffixIgnore]) continue;
        handler(key, config[key]);
    }
    // 2. then iterate the rest keys
    for (NSString* key in config) {
        if ([key hasPrefix:kReserved]) continue;
        if ([key hasSuffix:kSuffixIgnore]) continue;
        if ([sortedKeys containsObject: key]) continue;
        handler(key, config[key]);
    }
}

+(NSDictionary*) getLoopConfig:(NSMutableDictionary*)configs index:(int)index
{
    // First , checkout if have "~0" or "~1" ... to need to combine  (such as chepater cells and symbols)
    NSString* indexKey = [NSString stringWithFormat:@"%@%d", kReserved, index];
    NSDictionary* indexConfig = configs[indexKey];
    if (indexConfig) {
        configs = [DictionaryHelper combines:configs with:indexConfig];
    }
    
    // Second , loop with replace the config
    NSDictionary* loopConfig = configs[kReservedLoop];
    NSArray* keyPaths = loopConfig[@"keyPaths"];
    NSArray* values = loopConfig[@"values"];
    
    // no need to replace the value
    if (!loopConfig || values.count == 0 || keyPaths.count == 0) {
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

#pragma mark - Music


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



#pragma mark - 

+(NSArray*) getSupportedModes
{
    return DATA.config[@"Supported_Modes"];
}

+(int) getSymbolsIdentificationsCount
{
    return [[ConfigHelper getSymbolsPorperties][@"~count"] intValue];
}

+(NSMutableDictionary*) getSymbolsPorperties
{
    return DATA.config[@"SYMBOLS_PORPERTIES"];
}



#pragma mark - Network Request


+(void) requestDowloadRemoteResources
{
    NSString* definedURL = DATA.config[@"ResourcesSpecificationURL"];
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
