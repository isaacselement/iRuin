#import "DataManager.h"
#import "AppInterface.h"

@implementation DataManager
{
    NSMutableDictionary* portraitVisualJSON;
    NSMutableDictionary* landscapeVisualJSON;
    
    NSDictionary* sharedConfig;
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


#pragma mark - Public Methods
-(void) initializeWithData {
    // universal
    NSString* portraitDesignJsonFile = Visual_Portrait_JsonFile;
    NSString* landscapeDesignJsonFile = Visual_Landscape_JsonFile;
    
    // iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSString* ipadPortraitDesignJsonFile = [IPad_Prefix stringByAppendingString: portraitDesignJsonFile];
        NSString* ipadLandscapeDesignJsonFile = [IPad_Prefix stringByAppendingString: landscapeDesignJsonFile];
        
        // check if exist
        if ([[NSFileManager defaultManager] fileExistsAtPath: BUNDLEFILE_PATH(ipadPortraitDesignJsonFile)]) {
            portraitDesignJsonFile = ipadPortraitDesignJsonFile;
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath: BUNDLEFILE_PATH(ipadLandscapeDesignJsonFile)]) {
            landscapeDesignJsonFile = ipadLandscapeDesignJsonFile;
        }
    // iPhone
    } else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        NSString* iphonePortraitDesignJsonFile = [IPhone_Prefix stringByAppendingString: portraitDesignJsonFile];
        NSString* iphoneLandscapeDesignJsonFile = [IPhone_Prefix stringByAppendingString: landscapeDesignJsonFile];
        
        // check if exist
        if ([[NSFileManager defaultManager] fileExistsAtPath: BUNDLEFILE_PATH(iphonePortraitDesignJsonFile)]) {
            portraitDesignJsonFile = iphonePortraitDesignJsonFile;
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath: BUNDLEFILE_PATH(iphoneLandscapeDesignJsonFile)]) {
            landscapeDesignJsonFile = iphoneLandscapeDesignJsonFile;
        }
    }
    
    // prepare the portrait and landscape design specifications
    portraitVisualJSON = [DictionaryHelper deepCopy: [JsonFileManager getJsonFromFile: portraitDesignJsonFile]];
    landscapeVisualJSON = [DictionaryHelper deepCopy: [JsonFileManager getJsonFromFile: landscapeDesignJsonFile]];
    
    // replace the indexPaths using IndexPathParser's indexPathsRepository
    [QueueIndexPathParser setIndexPathsRepository: [ArrayHelper getMaxCount: portraitVisualJSON[@"MATRIX"]]];
    [QueueIndexPathParser replaceIndexPathsWithExistingIndexPathsRepositoryInDictionary:portraitVisualJSON];
    [QueueIndexPathParser setIndexPathsRepository: [ArrayHelper getMaxCount: landscapeVisualJSON[@"MATRIX"]]];
    [QueueIndexPathParser replaceIndexPathsWithExistingIndexPathsRepositoryInDictionary:landscapeVisualJSON];
    
    // prepare the shared config
    sharedConfig = [JsonFileManager getJsonFromFile: Key_Config];
    
    // prepare the modes config
    modesConfigs = [NSMutableDictionary dictionary];
    for (NSString* mode in ACTION.gameModes) {
        NSDictionary* modeConfig = [JsonFileManager getJsonFromFile: [NSString stringWithFormat:@"%@_%@", Key_Config, mode]];
        if (modeConfig) [modesConfigs setObject: modeConfig forKey:mode];
    }
}


#pragma mark - Get and Set The Configs

-(NSMutableDictionary*) visualJSON
{
    return UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) ? landscapeVisualJSON : portraitVisualJSON ;
}

-(NSMutableDictionary*) config
{
    return config;
}

-(void) setConfigByMode: (NSString*)mode
{
    config = [DictionaryHelper combines: sharedConfig with:modesConfigs[mode]];
}



@end
