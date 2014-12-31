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
    [self prepareShareDesignsConfigs];
    
    // check update and download
    [ConfigHelper requestDowloadRemoteResources];
}


#pragma mark - Private Methods

-(void) prepareShareDesignsConfigs
{
    //--------------------------------   Designs   ---------------------------

    // default iPhone
    BOOL isIpad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    
    // portrait/landscape share/device config
    NSDictionary* portraitDesign = [DictionaryHelper deepCopy: [ConfigHelper getDesignJson:key_Portrait ]];
    NSDictionary* landscapeDesign = [DictionaryHelper deepCopy: [ConfigHelper getDesignJson:key_Landscape ]];
    NSDictionary* portraitDeviceJSON = [ConfigHelper getDesignJson: StringUnderlineAppend(isIpad ? key_IPad : key_IPhone, key_Portrait) ];
    NSDictionary* landscapeDeviceJSON = [ConfigHelper getDesignJson: StringUnderlineAppend(isIpad ? key_IPad : key_IPhone, key_Landscape) ];
    
    
    
    //--------------------------------   Configs   ---------------------------

    // share config
    NSDictionary* shareConfig = [ConfigHelper getConfigJson: key_Config ];
    // modes config
    modesConfigs = [NSMutableDictionary dictionary];
    for (NSString* mode in ACTION.gameModes) {
        NSDictionary* modeConfig = [ConfigHelper getConfigJson: StringUnderlineAppend(key_Config, mode) ];
        if (modeConfig) [modesConfigs setObject: modeConfig forKey:mode];
    }
    // chapters config
    chaptersConfig = [DictionaryHelper deepCopy: [ConfigHelper getConfigJson: key_Chapters ]];
    
    
    
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
