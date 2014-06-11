
#pragma mark - Config Macro

#define IPad_Prefix                 @"iPad_"

#define Visual_Portrait_JsonFile    @"Visual_Portrait_10x6.json"
#define Visual_Landscape_JsonFile   @"Visual_Landscape_10x6.json"

#define Key_Config      @"Config"











#pragma mark - App Macro


#define MATCH_COUNT 3

#define CGPointValue(_point) [NSValue valueWithCGPoint: _point ]






#pragma mark - Macro

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_4_3
#define RANDOM(x) arc4random_uniform(x)
#else
#define RANDOM(x) arc4random() % x
#endif



