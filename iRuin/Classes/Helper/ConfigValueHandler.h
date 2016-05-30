#import <Foundation/Foundation.h>

#define k_current_value @"k_current_value"
#define k_window_center @"k_window_center"
#define k_super_center @"k_super_center"

@interface ConfigValueHandler : NSObject

+(CGPoint) parsePoint: (id)config object:(NSObject*)object keyPath:(NSString*)keyPath;

+(CGSize) parseSize: (id)config object:(NSObject*)object keyPath:(NSString*)keyPath;

+(CGRect) parseRect: (id)config object:(NSObject*)object keyPath:(NSString*)keyPath;


#pragma mark 

+(BOOL) checkIsCurrentValue:(id)value;

+(BOOL) checkIsWindowCenterValue:(id)value;

+(BOOL) checkIsSuperCenterValue:(NSString*)value;

@end
