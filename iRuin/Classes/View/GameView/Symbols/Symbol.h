#import <Foundation/Foundation.h>

// Note : For the case of nil , identification can not be 0

@interface Symbol : NSObject

@property(strong) NSString* name;
@property(assign) int identification;
@property(strong) UIColor* color;

-(id)initWithName: (NSString*)name definition:(NSDictionary*)definition;

@end
