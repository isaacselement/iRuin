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

+(NSDictionary*) getSubConfigWithLoop:(NSDictionary*)configs index:(int)index
{
    NSString* indexKey = [NSString stringWithFormat: @"%d", index];
    NSString* circleIndexKey = nil;
    NSArray* loopKeys = configs[@"loop"];
    if (loopKeys) {
        int circleIndex = abs(index) % [loopKeys count];
        circleIndexKey = [loopKeys objectAtIndex: circleIndex];
    }
    return [self getSubConfig:configs key:indexKey alternateKey:circleIndexKey];
}

+(NSDictionary*) getSubConfig:(NSDictionary*)configs key:(NSString*)key
{
    return [self getSubConfig:configs key:key alternateKey:nil];
}

+(NSDictionary*) getSubConfig:(NSDictionary*)configs key:(NSString*)key alternateKey:(NSString*)alternateKey
{
    NSDictionary* defaultConfig = configs[@"default"];
    NSDictionary* commonConfig = configs[@"common"];
    
    NSDictionary* config = configs[key];
    if (!config) {
        if (alternateKey) config = configs[alternateKey];
    }
    if (!config) {
        config = defaultConfig;
    }
    
    if (commonConfig) {
        config = [DictionaryHelper combines:commonConfig with:config];
    }
    return config;
}

#pragma mark - Config Music

+(NSDictionary*) getMusicConfig:(NSString*)key
{
    return DATA.config[@"Music"][key];
}


#pragma mark - Network Request

+(void) requestDowloadRemoteResources
{
    NSString* definedURL = DATA.config[@"Utilities"][@"ResourcesSpecificationURL"];
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
