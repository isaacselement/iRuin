#import <Foundation/Foundation.h>

#define k_current_value @"k_current_value"
#define k_window_middle @"k_window_middle"
#define k_super_middle @"k_super_middle"

@interface ConfigValueHandler : NSObject

+(CGPoint) parsePoint: (id)config object:(NSObject*)object keyPath:(NSString*)keyPath;

+(CGSize) parseSize: (id)config object:(NSObject*)object keyPath:(NSString*)keyPath;

+(CGRect) parseRect: (id)config object:(NSObject*)object keyPath:(NSString*)keyPath;


#pragma mark 

+(BOOL) checkIsCurrentValue:(id)value;

+(BOOL) checkIsWindowCenterValue:(id)value;

+(BOOL) checkIsSuperCenterValue:(NSString*)value;

+(CGPoint) getWindowCenter;

+(CGPoint) getSuperCenter:(NSObject*)object;

@end
