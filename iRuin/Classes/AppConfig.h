


#pragma mark - Config Macro



#define IRuin_Bundle_ID @"com.suchachinoiserie.iRuin"



#define key_Config      @"Config"

#define key_IPad        @"iPad"
#define key_IPhone      @"iPhone"

#define key_Portrait    @"Portrait"
#define key_Landscape   @"Landscape"

#define key_Chapters    @"Chapters"






#define STR_Dot         @"."

#define STR_UnderLine   @"_"

#define key_Json        @"json"





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





#define StringAppend(x, y) [x stringByAppendingString: y]

#define StringPathAppend(x, y) [x stringByAppendingPathComponent: y]

#define StringDotAppend(x, y) StringsAppend(x, STR_Dot, y)

#define StringUnderlineAppend(x, y) StringsAppend(x, STR_UnderLine, y)

#define StringsAppend(x, y, z) [NSString stringWithFormat:@"%@%@%@", x, y, z]





#pragma mark - Macro

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_4_3
#define RANDOM(x) arc4random_uniform(x)
#else
#define RANDOM(x) arc4random() % x
#endif








