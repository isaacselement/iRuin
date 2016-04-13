#import <Foundation/Foundation.h>

@interface AppUserDefaults : NSObject

+ (nonnull AppUserDefaults*)sharedInstance;

- (nullable id)objectForKey:(nullable NSString *)defaultName;

- (void)setObject:(nullable id)value forKey:(nullable NSString *)defaultName;

- (void)removeObjectForKey:(nullable NSString *)defaultName;

@end
