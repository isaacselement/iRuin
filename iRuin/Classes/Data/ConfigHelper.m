#import "ConfigHelper.h"
#import "AppInterface.h"

@implementation ConfigHelper

+(NSDictionary*) getDesignJson: (NSString*)name
{
    return [self getJson: name key:User_ResourcesDesignsPath];
}

+(NSDictionary*) getConfigJson: (NSString*)name
{
    return [self getJson: name key:User_ResourcesConfigsPath];
}

+(NSDictionary*) getJson: (NSString*)name key:(NSString*)key
{
    return [self getJson: StringDotAppend(name, key_Json) directory:[StandUserDefaults objectForKey: key]];
}

+(NSDictionary*) getJson: (NSString*)fileName directory:(NSString*)directory
{
    NSString* sanboxFilePath = nil;
    if (directory) {
        NSString* configsDirectory = StringPathAppend(NSHomeDirectory(), directory);
        NSString* configFilePath = StringPathAppend(configsDirectory, fileName);
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
    HTTPGetRequest* definedRequest = [[HTTPGetRequest alloc] initWithURLString: definedURL parameters:nil];
    
    [definedRequest startRequest:^(HTTPRequestBase *httpRequest, NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (! connectionError && [(NSHTTPURLResponse*) response statusCode] < 400) {
            NSError* error = nil;
            NSDictionary* contents = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingAllowFragments error:&error];
            
            if (!error && contents) {
                int version = [contents[@"version"] intValue];
                BOOL isProduction = [contents[@"isProduction"] boolValue];
                
                int currentVersion = [[StandUserDefaults objectForKey: User_ResourcesVersion] intValue];
                BOOL isNewerVersion = version > currentVersion;
                
                if (isProduction && isNewerVersion) {
                    NSString* resourcesURL = contents[@"resourcesURL"];
                    NSString* zipFileName = [resourcesURL lastPathComponent];
                    
                    NSString* localPath = contents[@"localPath"];
                    NSString* absLocalPATH = StringPathAppend(NSHomeDirectory(), localPath);
                    NSString* zipFileLocalPATH = StringPathAppend(absLocalPATH, zipFileName);
                    
                    BOOL isSetupImmediately = [contents[@"isSetupImmediately"] boolValue];
                    
                    // Get resources.zip
                    HTTPGetRequest* resourcesRequest = [[HTTPGetRequest alloc] initWithURLString:resourcesURL parameters:nil];
                    
                    [resourcesRequest startRequest:^(HTTPRequestBase *httpRequest, NSURLResponse *response, NSData *data, NSError *connectionError) {
                        if (! connectionError && [(NSHTTPURLResponse*) response statusCode] < 400) {
                            // save
                            [FileManager writeDataToFile:zipFileLocalPATH data:data];
                            
                            // un compress
                            NSString* unZipFilePath = [zipFileLocalPATH stringByDeletingLastPathComponent];
                            [SSZipArchive unzipFileAtPath:zipFileLocalPATH toDestination:unZipFilePath];
                            
                            // delete
                            [FileManager deleteFile:zipFileLocalPATH];
                            
                            // save to user defaults
                            NSString* resourceRootPath = [zipFileLocalPATH stringByDeletingPathExtension];
                            NSString* relativeConfigsPath = StringPathAppend(resourceRootPath, @"Configs");
                            NSString* relativeDesignsPath = StringPathAppend(resourceRootPath, @"Designs");
                            
                            [StandUserDefaults setObject:@(version) forKey:User_ResourcesVersion];
                            [StandUserDefaults setObject: relativeConfigsPath forKey:User_ResourcesConfigsPath];
                            [StandUserDefaults setObject: relativeDesignsPath forKey:User_ResourcesDesignsPath];
                            
                            // if setup immediately
                            if (isSetupImmediately) {
                                [DATA prepareShareDesignsConfigs];
                            }
                        }
                    }];
                    
                }
                
            }
        }
    }];
}


@end
