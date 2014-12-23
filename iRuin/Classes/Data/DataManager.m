#import "DataManager.h"
#import "AppInterface.h"



@implementation DataManager
{
    NSMutableDictionary* protraitShareConfig ;
    NSMutableDictionary* landscapeShareConfig ;
    
    
    
    NSMutableDictionary* portraitModeChapterConfig;
    NSMutableDictionary* landscapeModeChapterConfig;
    
    
    
    NSMutableDictionary* modesConfigs;
    NSMutableDictionary* chaptersConfig;
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
        if ([key hasPrefix:STR_UnderLine] && [key hasSuffix:STR_UnderLine]) {
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
    
    // set up designs and configs
    [self setupBasicDesignsAndConfigs];
    
    // check update and download
    [self checkAndDowloadRemoteResources];
}


#pragma mark - Private Methods

-(void) setupBasicDesignsAndConfigs
{
    //--------------------------------   Designs   ---------------------------
    NSString* designKey = User_ResourcesDesignsPath;
    
    // default iPhone
    NSString* portraitDeviceFile = StringUnderlineAppend(key_IPhone, key_Portrait);
    NSString* landscapeDeviceFile = StringUnderlineAppend(key_IPhone, key_Landscape);
    // if iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        portraitDeviceFile = StringUnderlineAppend(key_IPad, key_Portrait);
        landscapeDeviceFile = StringUnderlineAppend(key_IPad, key_Landscape);
    }
    // prepare the share portrait/landscape config
    NSDictionary* portraitDesign = [DictionaryHelper deepCopy: [self getJson:key_Portrait key:designKey]];
    NSDictionary* landscapeDesign = [DictionaryHelper deepCopy: [self getJson:key_Landscape key:designKey]];
    NSDictionary* portraitDeviceJSON = [self getJson:portraitDeviceFile key:designKey];
    NSDictionary* landscapeDeviceJSON = [self getJson:landscapeDeviceFile key:designKey];
    
    
    //--------------------------------   Configs   ---------------------------
    NSString* configKey = User_ResourcesConfigsPath;
    
    // share config
    NSDictionary* shareConfig = [self getJson: key_Config key:configKey];
    // prepare the modes config
    modesConfigs = [NSMutableDictionary dictionary];
    for (NSString* mode in ACTION.gameModes) {
        NSDictionary* modeConfig = [self getJson: StringUnderlineAppend(key_Config, mode) key:configKey];
        if (modeConfig) [modesConfigs setObject: modeConfig forKey:mode];
    }
    // chapters config
    chaptersConfig = [DictionaryHelper deepCopy: [self getJson: key_Chapters key:configKey]];
    
    
    //-------------------------------  Handler/Combine Configs and Designs -------------------
    // combine the configs
    protraitShareConfig = [DictionaryHelper combines:shareConfig with: [DictionaryHelper combines:portraitDeviceJSON with: portraitDesign]];
    landscapeShareConfig = [DictionaryHelper combines:shareConfig with: [DictionaryHelper combines:landscapeDeviceJSON with: landscapeDesign]];
    // setup the IndexPathParser's indexPathsRepository, and replace the indexPaths using IndexPathParser's indexPathsRepository
    int maxDimension = MAX([ArrayHelper getMaxCount: protraitShareConfig[@"MATRIX"]], [ArrayHelper getMaxCount: landscapeShareConfig[@"MATRIX"]]);
    [QueueIndexPathParser setIndexPathsRepository: maxDimension];
    [QueueIndexPathParser replaceIndexPathsWithExistingIndexPathsRepositoryInDictionary:protraitShareConfig];
    [QueueIndexPathParser replaceIndexPathsWithExistingIndexPathsRepositoryInDictionary:landscapeShareConfig];
}

-(NSDictionary*) getJson: (NSString*)name key:(NSString*)key
{
    NSString* fileName = StringDotAppend(name, key_Json);
    
    NSString* sanboxFilePath = nil;
    NSString* configsDirectory = nil;
    NSString* subDirectory = [StandUserDefaults objectForKey: key];
    if (subDirectory) {
        configsDirectory = StringPathAppend(NSHomeDirectory(), subDirectory);
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

-(void) checkAndDowloadRemoteResources
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
                                [DATA setupBasicDesignsAndConfigs];
                            }
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
        return landscapeModeChapterConfig ? landscapeModeChapterConfig : landscapeShareConfig;
    } else {
        return portraitModeChapterConfig ? portraitModeChapterConfig : protraitShareConfig;
    }
}

-(void) unsetModeChapterConfig
{
    // then , the landscapeShareConfig and protraitShareConfig will be reused.
    landscapeModeChapterConfig = nil;
    portraitModeChapterConfig = nil;
}

-(void) setConfigByMode: (NSString*)mode chapter:(int)chapter
{
    // combine with specific mode
    portraitModeChapterConfig = [DictionaryHelper combines: protraitShareConfig with:modesConfigs[mode]];
    landscapeModeChapterConfig = [DictionaryHelper combines: protraitShareConfig with:modesConfigs[mode]];
    
    // combine with specific chapter
    NSString* chapterString = [NSString stringWithFormat:@"%d", chapter];
    id seasonConfig = chaptersConfig[chapterString];
    if ([seasonConfig isKindOfClass:[NSString class]]) {
        seasonConfig = chaptersConfig[seasonConfig];
    }
    if (![seasonConfig isKindOfClass:[NSDictionary class]]) return;
    [DictionaryHelper combine: portraitModeChapterConfig with:seasonConfig];
    [DictionaryHelper combine: landscapeModeChapterConfig with:seasonConfig];
}


@end
