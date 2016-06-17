#import <Foundation/Foundation.h>

@interface ConfigValueHandler : NSObject


+(CGPoint) parsePoint: (id)config object:(NSObject*)object keyPath:(NSString*)keyPath;

+(CGSize) parseSize: (id)config object:(NSObject*)object keyPath:(NSString*)keyPath;

+(CGRect) parseRect: (id)config object:(NSObject*)object keyPath:(NSString*)keyPath;

+(BOOL) isKValue:(id)value;

+(id) getKValue:(id)value object:(NSObject*)object keyPath:(NSString*)keyPath;


@end
