#import <Foundation/Foundation.h>

@interface IRUserDefaults : NSObject

#pragma mark -

- (id)objectForKey:(NSString *)key;

- (void)setObject:(id)value forKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)key;

@end
