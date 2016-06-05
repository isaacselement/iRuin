
#pragma mark - Config Macro


#define kReserved @"~"
#define kSuffixIgnore @"_"

// in GameEffect.m
#define kReservedText @"~Text"
#define kReservedClass @"~Class"
#define kReservedFrame @"~Frame"
#define kReservedExecutors @"~Executors"
#define kReservedExecutorsDone @"~ExecutorsDone"

// in ConfigHelper.m
#define kReservedLoop @"~loop"
#define kReservedCommon @"~common"
#define kReservedDefault @"~default"
#define kReservedInterval @"~interval"
#define kReservedSortedKeys @"~sortedKeys"



#define key_Json        @"json"
#define key_Config      @"Config"
#define key_IPad        @"iPad"
#define key_IPhone      @"iPhone"
#define key_Portrait    @"Portrait"
#define key_Landscape   @"Landscape"
#define key_Chapters    @"Chapters"




#define STR_Dot         @"."

#define STR_UnderLine   @"_"






#pragma mark - User Defaults



#define User_ChapterIndex @"User_ChapterIndex"

#define User_LastTimeLaunch @"User_LastTimeLaunch"
#define User_FirstTimeLaunch @"User_FirstTimeLaunch"

#define User_ResourcesVersion @"User_ResourcesVersion"

#define User_ResourcesSandboxPath @"User_ResourcesSandboxPath"





#pragma mark - App Macro


#define MATCH_COUNT 3

#define CGPointValue(_point) [NSValue valueWithCGPoint: _point]

#define APPStandUserDefaults [AppUserDefaults sharedInstance]





#define StringAppend(x, y) [x stringByAppendingString: y]

#define StringPathAppend(x, y) [x stringByAppendingPathComponent: y]

#define StringDotAppend(x, y) StringAppend(x, StringAppend(STR_Dot, y))

#define StringUnderlineAppend(x, y) StringAppend(x, StringAppend(STR_UnderLine, y))








