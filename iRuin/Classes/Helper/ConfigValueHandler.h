#import <Foundation/Foundation.h>

@interface ConfigValueHandler : NSObject

+(CGPoint) parsePoint: (id)config object:(NSObject*)object keyPath:(NSString*)keyPath;

+(CGSize) parseSize: (id)config object:(NSObject*)object keyPath:(NSString*)keyPath;

+(CGRect) parseRect: (id)config object:(NSObject*)object keyPath:(NSString*)keyPath;


#pragma mark 

+(BOOL) checkIsCurrentValue:(id)value;

@end
