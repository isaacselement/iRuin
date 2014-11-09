
#pragma mark - Config Macro


#define key_Config      @"Config"

#define IPad_Prefix     @"iPad_"
#define IPhone_Prefix   @"iPhone_"

#define key_Portrait    @"Portrait"
#define key_Landscape   @"Landscape"







#pragma mark - 

#define UserChapterIndex @"UserChapterIndex"






#pragma mark - App Macro


#define MATCH_COUNT 3

#define CGPointValue(_point) [NSValue valueWithCGPoint: _point ]






#pragma mark - Macro

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_4_3
#define RANDOM(x) arc4random_uniform(x)
#else
#define RANDOM(x) arc4random() % x
#endif

