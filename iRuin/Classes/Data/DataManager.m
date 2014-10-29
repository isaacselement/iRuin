#import "DataManager.h"
#import "AppInterface.h"

@implementation DataManager
{
    NSMutableDictionary* portraitConfig;
    NSMutableDictionary* landscapeConfig;
    
    
    NSMutableDictionary* protraitShareConfig ;
    NSMutableDictionary* landscapeShareConfig ;
    
    
    
//    NSDictionary* sharedConfig;
    NSMutableDictionary* config;
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

#pragma mark - initialization

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}


#define JsonExtension(name) [name stringByAppendingPathExtension:@"json"]
#define StringAppend(first, second) [first stringByAppendingString:second]

#pragma mark - Public Methods
-(void) initializeWithData {
    
    // file paths
    // universal
    NSString* portraitDesignJsonFile = JsonExtension(key_Portrait);
    NSString* landscapeDesignJsonFile = JsonExtension(key_Landscape);
    
    // iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSString* ipadPortraitDesignJsonFile = StringAppend(IPad_Prefix, portraitDesignJsonFile);
        NSString* ipadLandscapeDesignJsonFile = StringAppend(IPad_Prefix, landscapeDesignJsonFile);
        
        // check if exist
        if ([[NSFileManager defaultManager] fileExistsAtPath: BUNDLEFILE_PATH(ipadPortraitDesignJsonFile)]) {
            portraitDesignJsonFile = ipadPortraitDesignJsonFile;
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath: BUNDLEFILE_PATH(ipadLandscapeDesignJsonFile)]) {
            landscapeDesignJsonFile = ipadLandscapeDesignJsonFile;
        }
    // iPhone
    } else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        NSString* iphonePortraitDesignJsonFile = StringAppend(IPhone_Prefix, portraitDesignJsonFile);
        NSString* iphoneLandscapeDesignJsonFile = StringAppend(IPhone_Prefix, landscapeDesignJsonFile);
        
        // check if exist
        if ([[NSFileManager defaultManager] fileExistsAtPath: BUNDLEFILE_PATH(iphonePortraitDesignJsonFile)]) {
            portraitDesignJsonFile = iphonePortraitDesignJsonFile;
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath: BUNDLEFILE_PATH(iphoneLandscapeDesignJsonFile)]) {
            landscapeDesignJsonFile = iphoneLandscapeDesignJsonFile;
        }
    }
    
    // prepare the share portrait/landscape config
    NSDictionary* portraitJSON = [DictionaryHelper deepCopy: [JsonFileManager getJsonFromFile: portraitDesignJsonFile]];
    NSDictionary* landscapeJSON = [DictionaryHelper deepCopy: [JsonFileManager getJsonFromFile: landscapeDesignJsonFile]];
    
    NSDictionary* shareConfig = [JsonFileManager getJsonFromFile: key_Config];
    
    protraitShareConfig = [DictionaryHelper combines:shareConfig with:portraitJSON];
    landscapeShareConfig = [DictionaryHelper combines:shareConfig with:landscapeJSON];
    
    // setup the IndexPathParser's indexPathsRepository, and replace the indexPaths using IndexPathParser's indexPathsRepository
    int maxDimension = MAX([ArrayHelper getMaxCount: protraitShareConfig[@"MATRIX"]], [ArrayHelper getMaxCount: landscapeShareConfig[@"MATRIX"]]);
    [QueueIndexPathParser setIndexPathsRepository: maxDimension];
    
    [QueueIndexPathParser replaceIndexPathsWithExistingIndexPathsRepositoryInDictionary:protraitShareConfig];
    [QueueIndexPathParser replaceIndexPathsWithExistingIndexPathsRepositoryInDictionary:landscapeShareConfig];
    
    
    // prepare the modes config
    modesConfigs = [NSMutableDictionary dictionary];
    for (NSString* mode in ACTION.gameModes) {
        NSDictionary* modeConfig = [JsonFileManager getJsonFromFile: [NSString stringWithFormat:@"%@_%@", key_Config, mode]];
        if (modeConfig) [modesConfigs setObject: modeConfig forKey:mode];
    }
}


#pragma mark - Get and Set The Configs

-(NSMutableDictionary*) config
{
    return UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) ? landscapeConfig : portraitConfig ;
}

-(void) setConfigByMode: (NSString*)mode
{
    BOOL (^combineHandler)(NSString* key, NSMutableDictionary* destination, NSDictionary* source) = ^BOOL(NSString *key, NSMutableDictionary *destination, NSDictionary *source) {
        if ([key hasPrefix:@"_"] && [key hasSuffix:@"_"]) {
            NSString* removeKey = [key substringWithRange:NSMakeRange(1, [key length] - 2)];
            [destination removeObjectForKey: removeKey];
            return NO;
        }
        return YES;
    };
    
    // set the handler
    [DictionaryHelper setCombineHandler: combineHandler];
    // combine it
    portraitConfig = [DictionaryHelper combines: protraitShareConfig with:modesConfigs[mode]];
    landscapeConfig = [DictionaryHelper combines: protraitShareConfig with:modesConfigs[mode]];
    // set the handler nil
    [DictionaryHelper setCombineHandler: nil];

}



@end
