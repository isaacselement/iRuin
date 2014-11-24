
#pragma mark - Config Macro


#define IRuin_Bundle_ID   @"com.suchachinoiserie.iRuin"


#define key_Config      @"Config"

#define IPad_Prefix     @"iPad_"
#define IPhone_Prefix   @"iPhone_"

#define key_Portrait    @"Portrait"
#define key_Landscape   @"Landscape"





#pragma mark - URLS

#define URL_JSON_iRuinResources @"https://raw.githubusercontent.com/suchavision/Productions_Resources/master/iRuinResources.json"





#pragma mark - User Defaults



#define User_ChapterIndex @"User_ChapterIndex"

#define User_LastTimeLaunch @"User_LastTimeLaunch"



#define User_ResourcesVersion @"User_ResourcesVersion"

#define User_ResourcesConfigsPath @"User_ResourcesConfigsPath"

#define User_ResourcesDesignsPath @"User_ResourcesDesignsPath"






#pragma mark - App Macro


#define MATCH_COUNT 3

#define CGPointValue(_point) [NSValue valueWithCGPoint: _point]

#define StandUserDefaults [NSUserDefaults standardUserDefaults]

#define StringAppend(_first, _second) [_first stringByAppendingString: _second]

#define PathAppend(_first, _second) [_first stringByAppendingPathComponent: _second];








#pragma mark - Macro

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_4_3
#define RANDOM(x) arc4random_uniform(x)
#else
#define RANDOM(x) arc4random() % x
#endif








