#import "ConfigHelper.h"
#import "AppInterface.h"

@implementation ConfigHelper

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
                        }
                    }];
                }
            }
        }
    }];
}




+(NSDictionary*) handleDefaultCommonConfig:(NSDictionary*)configs key:(NSString*)key
{
    NSDictionary* config = configs[key];
    if (! config) {
        config = configs[@"default"];
    }
    if (configs[@"common"]) {
        config = [DictionaryHelper combines:configs[@"common"] with:config];
    }
    return config;
}

@end
