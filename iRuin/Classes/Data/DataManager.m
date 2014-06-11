#import "DataManager.h"
#import "AppInterface.h"

@implementation DataManager
{
    NSMutableDictionary* portraitVisualJSON;
    NSMutableDictionary* landscapeVisualJSON;
    
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
    // iPhone
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
        // check if exist
        if ([[NSFileManager defaultManager] fileExistsAtPath: BUNDLEFILE_PATH(ipadLandscapeDesignJsonFile)]) {
            landscapeDesignJsonFile = ipadLandscapeDesignJsonFile;
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
    config = [DictionaryHelper deepCopy: (NSDictionary*)[JsonFileManager getJsonFromFile: Key_Config]];
    
    // prepare the modes config
    modesConfigs = [NSMutableDictionary dictionary];
    for (NSString* mode in ACTION.gameModes) {
        NSString* modeConfigFileName = [NSString stringWithFormat:@"%@_%@", Key_Config, mode];
        NSMutableDictionary* modeConfig = [DictionaryHelper deepCopy: [JsonFileManager getJsonFromFile: modeConfigFileName]];
        [modesConfigs setObject: modeConfig forKey:mode];
    }
}


#pragma mark - Get The Configs

-(NSMutableDictionary*) visualJSON
{
    return [self isDeviceOrientationPortrait] ? portraitVisualJSON : landscapeVisualJSON;
}
-(NSMutableDictionary*) config
{
    return config;
}
-(NSMutableDictionary*) config: (NSString*)mode
{
    return modesConfigs[mode];
}
-(BOOL) isDeviceOrientationPortrait
{
    return UIDeviceOrientationIsPortrait([self getDeviceOrientation]);
}
-(UIDeviceOrientation) getDeviceOrientation
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationUnknown) {
        orientation = UIDeviceOrientationPortrait;      // default
    }
    return orientation;
}

@end
