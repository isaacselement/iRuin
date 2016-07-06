#import <Foundation/Foundation.h>

@interface IRUserDefaults : NSObject


+ (void)invoke_in_load_for_subclass: (NSArray*)skip_sel_names;


#pragma mark -

- (id)objectForKey:(NSString *)key;

- (void)setObject:(id)value forKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)key;

@end
