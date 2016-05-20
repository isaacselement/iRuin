#import "ValueHandler.h"
#import "AppInterface.h"

@implementation ValueHandler

#define k_nil @"k_nil"
#define k_current_value @"k_current_value"

+(CGPoint) parsePoint: (id)config object:(NSObject*)object keyPath:(NSString*)keyPath
{
    BOOL isArray = [config isKindOfClass: [NSArray class]];
    NSArray* keys = @[@"x", @"y"];
    CGFloat result[2];
    for (int i = 0; i < 2; i++) {
        CGFloat z = 0;
        id value = isArray ? [config safeObjectAtIndex: i] : config[keys[i]];
        if ([self checkIsCurrentValue:value]) {
            CGPoint poin = [[object valueForKeyPath:keyPath] CGPointValue];
            if (i == 0) {
                z = [FrameTranslater canvasX:poin.x];
            } else {
                z = [FrameTranslater canvasY:poin.y];
            }
            z = [self getOperatedCurrentValue:value value:z];
        } else {
            z = [value floatValue];
        }
        result[i] = z;
    }
    return CGPointMake(result[0], result[1]);
}


+(CGSize) parseSize: (id)config object:(NSObject*)object keyPath:(NSString*)keyPath
{
    BOOL isArray = [config isKindOfClass: [NSArray class]];
    NSArray* keys = @[@"width", @"height"];
    CGFloat result[2];
    for (int i = 0; i < 2; i++) {
        CGFloat z = 0;
        id value = isArray ? [config safeObjectAtIndex: i] : config[keys[i]];
        if ([self checkIsCurrentValue:value]) {
            CGSize size = [[object valueForKeyPath:keyPath] CGSizeValue];
            if (i == 0) {
                z = [FrameTranslater canvasX:size.width];
            } else {
                z = [FrameTranslater canvasY:size.height];
            }
            z = [self getOperatedCurrentValue:value value:z];
        } else {
            z = [value floatValue];
        }
        result[i] = z;
    }
    return CGSizeMake(result[0], result[1]);
}


+(CGRect) parseRect: (id)config object:(NSObject*)object keyPath:(NSString*)keyPath
{
    BOOL isArray = [config isKindOfClass: [NSArray class]];
    NSArray* keys = @[@"x", @"y", @"width", @"height"];
    CGFloat result[4];
    for (int i = 0; i < 4; i++) {
        CGFloat z = 0;
        id value = isArray ? [config safeObjectAtIndex: i] : config[keys[i]];
        if ([self checkIsCurrentValue:value]) {
            CGRect rect = [[object valueForKeyPath:keyPath] CGRectValue];
            if (i == 0) {
                z = [FrameTranslater canvasX:rect.origin.x];
            } else if (i == 1) {
                z = [FrameTranslater canvasY:rect.origin.y];
            } else if (i == 2) {
                z = [FrameTranslater canvasX:rect.size.width];
            } else {
                z = [FrameTranslater canvasY:rect.size.height];
            }
            z = [self getOperatedCurrentValue:value value:z];
        } else {
            z = [value floatValue];
        }
        result[i] = z;
    }
    return CGRectMake(result[0], result[1], result[2], result[3]);
}

#pragma mark -

+(BOOL) checkIsCurrentValue:(id)value
{
    return [value isKindOfClass:[NSString class]] && ([(NSString*)value rangeOfString:k_current_value].location != NSNotFound) ;
}

+(BOOL) checkIsNilValue:(id)value
{
    return [value isKindOfClass:[NSString class]] && [value isEqualToString:k_nil];
}

// + - * /
+(CGFloat) getOperatedCurrentValue:(NSString*)string value:(CGFloat)z
{
    if ([string isEqualToString:k_current_value]) {
        return z;
    }
    
    NSString* flag = StringAppend(@"-", k_current_value);
    if ([string hasPrefix:flag]) {
        z = -z;
    }
    
    flag = StringAppend(k_current_value, @"-");
    if ([string rangeOfString:flag].location != NSNotFound) {
        CGFloat v = [[[string componentsSeparatedByString:flag] lastObject] floatValue];
        z = z - v;
    }
    
    flag = StringAppend(k_current_value, @"+");
    if ([string rangeOfString:flag].location != NSNotFound) {
        CGFloat v = [[[string componentsSeparatedByString:flag] lastObject] floatValue];
        z = z + v;
    }
    
    flag = StringAppend(k_current_value, @"*");
    if ([string rangeOfString:flag].location != NSNotFound) {
        CGFloat v = [[[string componentsSeparatedByString:flag] lastObject] floatValue];
        z = z * v;
    }
    
    flag = StringAppend(k_current_value, @"/");
    if ([string rangeOfString:flag].location != NSNotFound) {
        CGFloat v = [[[string componentsSeparatedByString:flag] lastObject] floatValue];
        z = z / v;
    }
    return z;
}



@end
