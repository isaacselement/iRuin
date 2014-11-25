#import "DataManager.h"
#import "AppInterface.h"



@implementation DataManager
{
    NSMutableDictionary* protraitShareConfig ;
    NSMutableDictionary* landscapeShareConfig ;
    
    
    NSMutableDictionary* portraitModeConfig;
    NSMutableDictionary* landscapeModeConfig;
    
    
    NSMutableDictionary* chaptersConfig;
    
    NSMutableDictionary* modesConfigs;
}

static DataManager* sharedInstance = nil;


+(void)initialize {
    if (self == [DataManager class]) {
        sharedInstance = [[DataManager alloc] init];
    }
}

+(DataManager*) getInstance {
    return sharedInstance;
}


#pragma mark - Public Methods

-(void) initializeWithData 
{
        
    // set dictionary combine handler
    [DictionaryHelper setCombineHandler:^BOOL(NSString *key, NSMutableDictionary *destination, NSDictionary *source) {
        if ([key hasPrefix:@"_"] && [key hasSuffix:@"_"]) {
            NSString* removeKey = [key substringWithRange:NSMakeRange(1, [key length] - 2)];
            [destination removeObjectForKey: removeKey];
            
            if (source[removeKey]) {
                [destination setObject: source[removeKey] forKey:removeKey];
            }
            
            // firt , _key_ , remove the key object
            // second , key , add the key object
            // just aim that use a key to replace all , not combine ~~~~
            
            return NO;
        }
        return YES;
    }];
    
    
    //--------------------------------   Designs   ---------------------------
    // universal
    NSString* portraitFile = StringAppend(key_Portrait, @".json");
    NSString* landscapeFile = StringAppend(key_Landscape, @".json");
    
    // default iPhone
    NSString* portraitDeviceFile = StringAppend(IPhone_Prefix, portraitFile);
    NSString* landscapeDeviceFile = StringAppend(IPhone_Prefix, landscapeFile);
    // iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        portraitDeviceFile = StringAppend(IPad_Prefix, portraitFile);
        landscapeDeviceFile = StringAppend(IPad_Prefix, landscapeFile);
    }
    
    NSString* portraitFilePath = BUNDLEFILE_PATH(portraitFile);
    NSString* landscapeFilePath = BUNDLEFILE_PATH(landscapeFile);
    NSString* portraitDeviceFilePath = BUNDLEFILE_PATH(portraitDeviceFile);
    NSString* landscapeDeviceFilePath = BUNDLEFILE_PATH(landscapeDeviceFile);
    
    // designs downloaded from remote     
    if ([StandUserDefaults objectForKey: User_ResourcesDesignsPath]) {
        NSString* designsDirectory = [NSHomeDirectory() stringByAppendingPathComponent: [StandUserDefaults objectForKey: User_ResourcesDesignsPath]];
        NSString* path = nil;
        
        path = PathAppend(designsDirectory, portraitFile);
        if ([FileManager isFileExist: path]) {
            portraitFilePath = path;
        }
        path = PathAppend(designsDirectory, landscapeFile);
        if ([FileManager isFileExist: path]) {
            landscapeFilePath = path;
        }
        path = PathAppend(designsDirectory, portraitDeviceFile);
        if ([FileManager isFileExist: path]) {
            portraitDeviceFilePath = path;
        }
        path = PathAppend(designsDirectory, landscapeDeviceFile);
        if ([FileManager isFileExist: path]) {
            landscapeDeviceFilePath = path;
        }
    }
    
    // prepare the share portrait/landscape config
    NSDictionary* portraitDesign = [DictionaryHelper deepCopy: [JsonFileManager getJsonFromPath: portraitFilePath]];
    NSDictionary* landscapeDesign = [DictionaryHelper deepCopy: [JsonFileManager getJsonFromPath: landscapeFilePath]];
    NSDictionary* portraitDeviceJSON = [JsonFileManager getJsonFromPath: portraitDeviceFilePath];
    NSDictionary* landscapeDeviceJSON = [JsonFileManager getJsonFromPath: landscapeDeviceFilePath];
    
    
    
    //--------------------------------   Configs   ---------------------------
    NSString* configFile = StringAppend(key_Config, @".json");
    NSString* configFilePath = BUNDLEFILE_PATH(configFile);
    
    // configs downloaded from remote 
    NSString* configsDirectory = nil;
    if ([StandUserDefaults objectForKey: User_ResourcesConfigsPath]) {
        configsDirectory = [NSHomeDirectory() stringByAppendingPathComponent: [StandUserDefaults objectForKey: User_ResourcesConfigsPath]];
    }
    if (configsDirectory) {
        NSString* path = PathAppend(configsDirectory, configFile);
        if ([FileManager isFileExist: path]) {
            configFilePath = path;
        }
    }
    NSDictionary* shareConfig = [JsonFileManager getJsonFromPath: configFilePath];
    
    // prepare the modes config
    modesConfigs = [NSMutableDictionary dictionary];
    for (NSString* mode in ACTION.gameModes) {
        NSString* modeFile = [NSString stringWithFormat:@"%@_%@", key_Config, mode];
        modeFile = StringAppend(modeFile, @".json");
        
        NSString* modeFilePath = BUNDLEFILE_PATH(modeFile);
        if (configsDirectory) {
            NSString* path = PathAppend(configsDirectory, modeFile);
            if ([FileManager isFileExist: path]) {
                modeFilePath = path;
            }
        }
        NSDictionary* modeConfig = [JsonFileManager getJsonFromPath:modeFilePath];
        if (modeConfig) [modesConfigs setObject: modeConfig forKey:mode];
    }
    
    // chapters config
    NSString* chaptersFile = StringAppend(key_Chapters, @".json");
    NSString* chaptersFilePath = BUNDLEFILE_PATH(chaptersFile);
    if (configsDirectory) {
        NSString* path = PathAppend(configsDirectory, chaptersFile);
        if ([FileManager isFileExist: path]) {
            chaptersFilePath = path;
        }
    }
    chaptersConfig = [DictionaryHelper deepCopy: [JsonFileManager getJsonFromPath: chaptersFilePath]];
    
    //-------------------------------  Handler/Combine Config -------------------
    // combine the configs
    protraitShareConfig = [DictionaryHelper combines:shareConfig with: [DictionaryHelper combines:portraitDeviceJSON with: portraitDesign]];
    landscapeShareConfig = [DictionaryHelper combines:shareConfig with: [DictionaryHelper combines:landscapeDeviceJSON with: landscapeDesign]];
    
    // setup the IndexPathParser's indexPathsRepository, and replace the indexPaths using IndexPathParser's indexPathsRepository
    int maxDimension = MAX([ArrayHelper getMaxCount: protraitShareConfig[@"MATRIX"]], [ArrayHelper getMaxCount: landscapeShareConfig[@"MATRIX"]]);
    [QueueIndexPathParser setIndexPathsRepository: maxDimension];
    [QueueIndexPathParser replaceIndexPathsWithExistingIndexPathsRepositoryInDictionary:protraitShareConfig];
    [QueueIndexPathParser replaceIndexPathsWithExistingIndexPathsRepositoryInDictionary:landscapeShareConfig];
    
    
    // TODO: ... in main thread now !~~~
    [self getRemoteResources];
}

-(void) getRemoteResources
{
    HTTPGetRequest* request = [[HTTPGetRequest alloc] initWithURLString: URL_JSON_iRuinResources parameters:nil];
    [request startRequest:^(HTTPRequestBase *httpRequest, NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (! connectionError && [(NSHTTPURLResponse*) response statusCode] < 400) {
            NSError* error = nil;
            NSDictionary* contents = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingAllowFragments error:&error];
            if (!error) {
                int currentVersion = [[StandUserDefaults objectForKey: User_ResourcesVersion] intValue];
                int newVersion = [contents[@"version"] intValue];
                BOOL isProductionVersion = [contents[@"isProductionVersion"] boolValue];
                
                if (isProductionVersion && (newVersion > currentVersion )) {
                    NSString* remoteURL = contents[@"remoteURL"];
                    NSString* zipFileName = [remoteURL lastPathComponent];
                    
                    NSString* relativeLocalPATH = contents[@"localPATH"];
                    NSString* absoluteLocalPATH = [NSHomeDirectory() stringByAppendingPathComponent: relativeLocalPATH];
                    NSString* compressedFilePath = [absoluteLocalPATH stringByAppendingPathComponent: zipFileName];
                    
                    // configs and designs path
                    NSString* relativeConfigsPath = contents[@"configsPath"];
                    NSString* relativeDesignsPath = contents[@"designsPath"];
                    
                    // get resources
                    HTTPGetRequest* resourcesRequest = [[HTTPGetRequest alloc] initWithURLString:remoteURL parameters:nil];
                    [resourcesRequest startRequest:^(HTTPRequestBase *httpRequest, NSURLResponse *response, NSData *data, NSError *connectionError) {
                        if (! connectionError && [(NSHTTPURLResponse*) response statusCode] < 400) {
                            // save 
                            [FileManager writeDataToFile:compressedFilePath data:data];
                            
                            // un compress
                            NSString* unCompressedFilePath = [compressedFilePath stringByDeletingLastPathComponent];
                            [SSZipArchive unzipFileAtPath:compressedFilePath toDestination:unCompressedFilePath];
                            
                            // delete
                            [FileManager deleteFile:compressedFilePath];
                            
                            // --------------
                            [StandUserDefaults setObject:@(newVersion) forKey:User_ResourcesVersion];
                            
                            [StandUserDefaults setObject: relativeConfigsPath forKey:User_ResourcesConfigsPath];
                            [StandUserDefaults setObject: relativeDesignsPath forKey:User_ResourcesDesignsPath];
                            
                            DLog(@"+++++ %d : %@ : %@", newVersion, relativeConfigsPath, relativeDesignsPath);
                        }
                    }];
                    
                }
                
            }
        }
    }];
}


#pragma mark - Get and Set The Configs

-(NSMutableDictionary*) config
{
    if (UIInterfaceOrientationIsLandscape([ViewHelper getTopViewController].interfaceOrientation)) {
        return landscapeModeConfig ? landscapeModeConfig : landscapeShareConfig;
    } else {
        return portraitModeConfig ? portraitModeConfig : protraitShareConfig;
    }
}

-(void) setConfigByMode: (NSString*)mode chapter:(NSString*)chapter
{
    portraitModeConfig = [DictionaryHelper combines: protraitShareConfig with:modesConfigs[mode]];
    landscapeModeConfig = [DictionaryHelper combines: protraitShareConfig with:modesConfigs[mode]];
    
    // combine with specific chapter
    id config = chaptersConfig[chapter];
    if ([config isKindOfClass:[NSString class]]) {
        config = chaptersConfig[config];
    }
    if (![config isKindOfClass:[NSDictionary class]]) return;
    
    [DictionaryHelper combine: portraitModeConfig with:config];
    [DictionaryHelper combine: landscapeModeConfig with:config];
}


@end
