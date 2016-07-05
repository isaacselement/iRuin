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
    NSString* configDirectory = StringPathAppend([self getPath:[IRSystemSetting sharedSetting].resourceSandbox], key);
    return [self getJson: StringDotAppend(name, key_Json) configDirectory:configDirectory];
}

+(NSDictionary*) getJson: (NSString*)fileName configDirectory:(NSString*)configDirectory
{
    if (configDirectory) {
        NSString* configInSandbox = StringPathAppend(configDirectory, fileName);
        if ([FileManager isFileExist: configInSandbox]) {
            NSDictionary* result = [JsonFileManager getJsonFromPath: configInSandbox];
            if (result) {
                return result;
            }
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
        // if no corresponding setValues, get the last one . i.e. config "GAME_MUSIC"
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
#ifdef DEBUG
    NSString* URL = DATA.config[@"__specification__UAT__"];
#else
    NSString* URL = DATA.config[@"__specification__"];
#endif
    
    HTTPGetRequest* specificationRequest = [[HTTPGetRequest alloc] initWithURLString:URL parameters:nil];
    [specificationRequest startRequest:^(HTTPRequestBase *httpRequest, NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (! connectionError && [(NSHTTPURLResponse*) response statusCode] == 200) {
            NSError* jsonParseError = nil;
            NSDictionary* specification = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingAllowFragments error:&jsonParseError];
            if (!jsonParseError && specification) {
                NSString* resourcesURL = specification[@"uri"];
                int version = [specification[@"version"] intValue];
                BOOL isSetupImmediately = [specification[@"isImmediately"] boolValue];
                
                NSString* inSandboxPath = specification[@"inSandboxPath"];
                NSString* zipFilePath = StringPathAppend(inSandboxPath, [resourcesURL lastPathComponent]);
                
                if (version > [IRSystemSetting sharedSetting].resourceVersion) {
                    
                    // Get resources.zip
                    HTTPGetRequest* resourcesRequest = [[HTTPGetRequest alloc] initWithURLString:resourcesURL parameters:nil];
                    [resourcesRequest startRequest:^(HTTPRequestBase *httpRequest, NSURLResponse *response, NSData *data, NSError *connectionError) {
                        if (! connectionError && [(NSHTTPURLResponse*) response statusCode] == 200) {
                            NSString* inSandboxFullPath = [self getPath:inSandboxPath];
                            NSString* zipFileFullPath = [self getPath:zipFilePath];
                            // save
                            [FileManager writeDataToFile:zipFileFullPath data:data];
                            // un compress
                            NSError* unZipError = nil;
                            [SSZipArchive unzipFileAtPath:zipFileFullPath toDestination:inSandboxFullPath overwrite:YES password:nil error:&unZipError];
                            // delete
                            [FileManager deleteFile:zipFileFullPath];
                            
                            // save to user defaults
                            [IRSystemSetting sharedSetting].resourceVersion = version;
                            [IRSystemSetting sharedSetting].resourceSandbox = [zipFilePath stringByDeletingPathExtension];
                            
                            DLOG(@"Did download & unzip resources!!!");
                            // if setup immediately
                            if (isSetupImmediately) {
                                [DATA prepareShareDesignsConfigs];
                                DLOG(@"Did renew resources!!!");
                            }
                        }
                    }];
                }
            }
        }
    }];
}

+(NSString*) getPath: (NSString*)path
{
    if ([path hasPrefix:@"~"]) {
        return [path stringByReplacingOccurrencesOfString:@"~" withString:NSHomeDirectory()];
    }
    return path;
}


@end
