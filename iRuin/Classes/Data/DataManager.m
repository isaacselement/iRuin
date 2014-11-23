#import "DataManager.h"
#import "AppInterface.h"


#define StringAppend(first, second) [first stringByAppendingString:second]



@implementation DataManager
{
    NSMutableDictionary* portraitConfig;
    NSMutableDictionary* landscapeConfig;
    
    NSMutableDictionary* protraitShareConfig ;
    NSMutableDictionary* landscapeShareConfig ;
    
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


#pragma mark - Public Methods

-(void) initializeWithData {
    
    // set dictionary combine handler
    [DictionaryHelper setCombineHandler:^BOOL(NSString *key, NSMutableDictionary *destination, NSDictionary *source) {
        if ([key hasPrefix:@"_"] && [key hasSuffix:@"_"]) {
            NSString* removeKey = [key substringWithRange:NSMakeRange(1, [key length] - 2)];
            [destination removeObjectForKey: removeKey];
            return NO;
        }
        return YES;
    }];
    
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
    
    // prepare the share portrait/landscape config
    NSDictionary* portraitDesign = [DictionaryHelper deepCopy: [JsonFileManager getJsonFromFile: portraitFile]];
    NSDictionary* landscapeDesign = [DictionaryHelper deepCopy: [JsonFileManager getJsonFromFile: landscapeFile]];
    NSDictionary* portraitDeviceJSON = [JsonFileManager getJsonFromFile: portraitDeviceFile];
    NSDictionary* landscapeDeviceJSON = [JsonFileManager getJsonFromFile: landscapeDeviceFile];
    NSDictionary* shareConfig = [JsonFileManager getJsonFromFile: key_Config];
    
    protraitShareConfig = [DictionaryHelper combines:shareConfig with: [DictionaryHelper combines:portraitDeviceJSON with: portraitDesign]];
    landscapeShareConfig = [DictionaryHelper combines:shareConfig with: [DictionaryHelper combines:landscapeDeviceJSON with: landscapeDesign]];
    
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
    if (UIInterfaceOrientationIsLandscape([ViewHelper getTopViewController].interfaceOrientation)) {
        return landscapeConfig ? landscapeConfig : landscapeShareConfig;
    } else {
        return portraitConfig ? portraitConfig : protraitShareConfig;
    }
}

-(void) setConfigByMode: (NSString*)mode
{
    portraitConfig = [DictionaryHelper combines: protraitShareConfig with:modesConfigs[mode]];
    landscapeConfig = [DictionaryHelper combines: protraitShareConfig with:modesConfigs[mode]];
}



@end
