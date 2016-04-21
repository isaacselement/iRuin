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
    [DictionaryHelper setCombineHandler:^BOOL(NSString *sourceKey, NSMutableDictionary *destination, NSDictionary *source) {
        if ([sourceKey hasPrefix:@"delete_"]) {
            NSString* operationKey = [[sourceKey componentsSeparatedByString:@"delete_"] lastObject];
            [destination removeObjectForKey: operationKey];
            return NO;
        } else if ([sourceKey hasPrefix:@"replace_"]) {
            NSString* operationKey = [[sourceKey componentsSeparatedByString:@"replace_"] lastObject];
            [destination setObject:source[sourceKey] forKey:operationKey];
            return NO;
        }
        return YES;
    }];
    
    // set up designs and configs
    [self prepareShareDesignsConfigs];
    
    // check update and download
    [ConfigHelper requestDowloadRemoteResources];
}


#pragma mark - Private Methods

-(void) prepareShareDesignsConfigs
{
    //--------------------------------   Designs & Configs   ---------------------------

    // share config
    NSDictionary* shareConfig = [ConfigHelper getConfigJson: key_Config ];
    // default iPhone
    BOOL isIpad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    // portrait/landscape share/device config
    NSDictionary* portraitDesign = [DictionaryHelper deepCopy: [ConfigHelper getDesignJson:key_Portrait ]];
    NSDictionary* landscapeDesign = [DictionaryHelper deepCopy: [ConfigHelper getDesignJson:key_Landscape ]];
    NSDictionary* portraitDeviceJSON = [ConfigHelper getDesignJson: StringUnderlineAppend(isIpad ? key_IPad : key_IPhone, key_Portrait) ];
    NSDictionary* landscapeDeviceJSON = [ConfigHelper getDesignJson: StringUnderlineAppend(isIpad ? key_IPad : key_IPhone, key_Landscape) ];
    
    // combine the configs
    protraitShareConfig = [DictionaryHelper combines:shareConfig with: [DictionaryHelper combines:portraitDesign with:portraitDeviceJSON ]];
    landscapeShareConfig = [DictionaryHelper combines:shareConfig with: [DictionaryHelper combines:landscapeDesign with:landscapeDeviceJSON ]];
    // setup the IndexPathParser's indexPathsRepository, and replace the indexPaths using IndexPathParser's indexPathsRepository
    int maxDimension = MAX([ArrayHelper getMaxCount: protraitShareConfig[@"MATRIX"]], [ArrayHelper getMaxCount: landscapeShareConfig[@"MATRIX"]]);
    [QueueIndexPathParser setIndexPathsRepository: maxDimension];
    [QueueIndexPathParser replaceIndexPathsWithExistingIndexPathsRepositoryInDictionary:protraitShareConfig];
    [QueueIndexPathParser replaceIndexPathsWithExistingIndexPathsRepositoryInDictionary:landscapeShareConfig];
    
    //--------------------------------   Modes & Chapters Configs   ---------------------------
    
    // modes config
    modesConfigs = [NSMutableDictionary dictionary];
    for (NSString* mode in ACTION.gameModes) {
        NSDictionary* modeConfig = [ConfigHelper getConfigJson: StringUnderlineAppend(key_Config, mode) ];
        if (modeConfig) [modesConfigs setObject: modeConfig forKey:mode];
    }
    // chapters config
    chaptersConfig = [DictionaryHelper deepCopy: [ConfigHelper getConfigJson: key_Chapters ]];
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
