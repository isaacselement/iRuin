#import <Foundation/Foundation.h>

@interface IRUserDefaults : NSObject

#pragma mark -

- (id)get:(NSString*)key;

- (void)remove:(NSString*)key;

- (void)set:(id)value key:(NSString*)key;

@end
