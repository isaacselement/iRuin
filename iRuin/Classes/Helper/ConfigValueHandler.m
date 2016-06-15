#import "ConfigValueHandler.h"
#import "AppInterface.h"

// To Be refactor...

@implementation ConfigValueHandler

+(CGPoint) parsePoint: (id)config object:(NSObject*)object keyPath:(NSString*)keyPath
{
    BOOL isArray = [config isKindOfClass: [NSArray class]];
    NSArray* keys = @[@"x", @"y"];
    CGFloat result[2];
    for (int i = 0; i < 2; i++) {
        CGFloat z = 0;
        id value = isArray ? [config safeObjectAtIndex: i] : config[keys[i]];
        
        BOOL isString = [value isKindOfClass:[NSString class]];
        BOOL isCurrentValue = isString && [self checkIsCurrentValue:value];
        BOOL isWindowCenter = isString && [self checkIsWindowCenterValue:value];
        BOOL isSuperCenter = isString && [self checkIsSuperCenterValue:value];
        
        if ( isCurrentValue || isWindowCenter || isSuperCenter ) {
            
            CGPoint point =  [[object valueForKeyPath:keyPath] CGPointValue];
            NSString* key = k_current_value;
            if (isWindowCenter) {
                point = [self getWindowCenter];
                key = k_window_center;
            } else if (isSuperCenter) {
                point = [self getSuperCenter: object];
                key = k_super_center;
            }
            
            if (i == 0) {
                z = [FrameTranslater canvasX:point.x];
            } else {
                z = [FrameTranslater canvasY:point.y];
            }
            z = [self getExpressionValue:value key:key value:z];
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
        
        BOOL isString = [value isKindOfClass:[NSString class]];
        BOOL isCurrentValue = isString && [self checkIsCurrentValue:value];
        
        if (isCurrentValue) {
            CGSize size = [[object valueForKeyPath:keyPath] CGSizeValue];
            
            if (i == 0) {
                z = [FrameTranslater canvasX:size.width];
            } else {
                z = [FrameTranslater canvasY:size.height];
            }
            z = [self getExpressionValue:value key:k_current_value value:z];
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
        
        BOOL isString = [value isKindOfClass:[NSString class]];
        BOOL isCurrentValue = isString && [self checkIsCurrentValue:value];
        
        if (isCurrentValue) {
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
            z = [self getExpressionValue:value key:k_current_value value:z];
        } else {
            z = [value floatValue];
        }
        result[i] = z;
    }
    return CGRectMake(result[0], result[1], result[2], result[3]);
}

#pragma mark -

+(BOOL) checkIsCurrentValue:(NSString*)value
{
    return  [value rangeOfString:k_current_value].location != NSNotFound ;
}

+(BOOL) checkIsWindowCenterValue:(NSString*)value
{
    return [value rangeOfString:k_window_center].location != NSNotFound ;
}

+(BOOL) checkIsSuperCenterValue:(NSString*)value
{
    return [value rangeOfString:k_super_center].location != NSNotFound ;
}

+(CGPoint) getWindowCenter
{
    return [[[[UIApplication sharedApplication] delegate] window] middlePoint];
}

+(CGPoint) getSuperCenter:(NSObject*)object
{
    CGPoint point = CGPointZero;
    if ([object isKindOfClass:[UIView class]]) {
        point = [[(UIView*)object superview] middlePoint];
    } else if ([object isKindOfClass:[CALayer class]]) {
        point = [[(CALayer*)object superlayer] middlePoint];
    }
    return point;
}

// + - * /
+(CGFloat) getExpressionValue:(NSString*)expression key:(NSString*)key value:(CGFloat)z
{
    if ([expression isEqualToString:key]) {
        return z;
    }
    
    NSString* flag = StringAppend(@"-", key);
    if ([expression hasPrefix:flag]) {
        z = -z;
    }
    
    flag = StringAppend(key, @"-");
    if ([expression rangeOfString:flag].location != NSNotFound) {
        CGFloat v = [[[expression componentsSeparatedByString:flag] lastObject] floatValue];
        z = z - v;
    } else {
        
        flag = StringAppend(key, @"+");
        if ([expression rangeOfString:flag].location != NSNotFound) {
            CGFloat v = [[[expression componentsSeparatedByString:flag] lastObject] floatValue];
            z = z + v;
        } else {
            
            flag = StringAppend(key, @"*");
            if ([expression rangeOfString:flag].location != NSNotFound) {
                CGFloat v = [[[expression componentsSeparatedByString:flag] lastObject] floatValue];
                z = z * v;
            } else {
                
                flag = StringAppend(key, @"/");
                if ([expression rangeOfString:flag].location != NSNotFound) {
                    CGFloat v = [[[expression componentsSeparatedByString:flag] lastObject] floatValue];
                    z = z / v;
                }
            }
        }
    }
    return z;
}



@end
