#import "Symbol.h"
#import "ColorHelper.h"

@implementation Symbol


-(id)initWithName: (NSString*)name definition:(NSDictionary*)definition
{
    self = [super init];
    if (self) {
        self.name = name;
        self.identification = [definition[@"id"] intValue];
        self.color = [ColorHelper parseColor: definition[@"color"]];
    }
    return self;
}

-(NSString*) description {
    const CGFloat* components = CGColorGetComponents(self.color.CGColor);
    CGFloat red     = components[0];
    CGFloat green   = components[1];
    CGFloat blue    = components[2];
    CGFloat alpha   = components[3];

    return [NSString stringWithFormat: @"[name: %@, identifier: %d, color:%f,%f,%f,%f ]", self.name, self.identification, red*255,green*255,blue*255,alpha];
}

@end
