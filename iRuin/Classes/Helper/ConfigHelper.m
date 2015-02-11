#import "ConfigHelper.h"
#import "DictionaryHelper.h"

@implementation ConfigHelper


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
