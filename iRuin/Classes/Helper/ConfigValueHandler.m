#import "ConfigValueHandler.h"
#import "AppInterface.h"

// To Be refactor...

@implementation ConfigValueHandler


// !!!!! important , only x , y , width , height wrap with canvas . other are the real value
+(id) kValue:(id)value object:(NSObject*)object keyPath:(NSString*)keyPath
{
    if (![value isKindOfClass:[NSString class]] || [value hasPrefix:@"k_"]) {
        return value;
    }
    NSString* expression = [[value componentsSeparatedByString:@"k_"] lastObject];
    NSArray* targetAction = [expression componentsSeparatedByString:@"_"];
    if (targetAction.count == 2) {
        NSString* target = [targetAction firstObject];
        NSString* action = [targetAction lastObject];
        
        // get target object
        id targetObj = nil;
        if ([target isEqualToString:@"current"]) {
            
            targetObj = object;
            
        } else if ([target isEqualToString:@"window"]) {
            
            targetObj = [[[UIApplication sharedApplication] delegate] window];
            
        } else if ([target isEqualToString:@"super"]) {
            
            if ([object isKindOfClass:[UIView class]]) {
                targetObj = [(UIView*)object superview];
            } else if ([object isKindOfClass:[CALayer class]]) {
                targetObj = [(CALayer*)object superlayer];
            }
            
        }
        
        // get value object
        id result = nil;
        if ([action isEqualToString:@"value"]) {
            
            result = [targetObj valueForKeyPath: keyPath];
            
        } else if ([action isEqualToString:@"middle"]) {
            
            result = [NSValue valueWithCGPoint: [targetObj middlePoint]];     // view & layer have method 'middlePoint'
            
        } else if ([action isEqualToString:@"center"]) {
            
            CGPoint point = CGPointZero;
            if ([targetObj isKindOfClass:[UIView class]]) {
                point = [(UIView*)targetObj center];
            } else if ([targetObj isKindOfClass:[CALayer class]]) {
                point = [(CALayer*)targetObj position];
            }
            result = [NSValue valueWithCGPoint: point];
            
        } else if ([action isEqualToString:@"x"]) {
            result = @([FrameTranslater canvasX:CGRectGetMinX([targetObj frame])]);
            
        } else if ([action isEqualToString:@"y"]) {
            result = @([FrameTranslater canvasY:CGRectGetMinY([targetObj frame])]);
            
        } else if ([action isEqualToString:@"width"]) {
            result = @([FrameTranslater canvasWidth:CGRectGetWidth([targetObj frame])]);
            
        } else if ([action isEqualToString:@"Higth"]) {
            result = @([FrameTranslater canvasHeight:CGRectGetHeight([targetObj frame])]);
            
        }
        return result;
    }
    return value;
}

+(CGPoint) parsePoint: (id)config object:(NSObject*)object keyPath:(NSString*)keyPath
{
    BOOL isArray = [config isKindOfClass: [NSArray class]];
    NSArray* keys = @[@"x", @"y"];
    CGFloat result[2];
    for (int i = 0; i < 2; i++) {
        id value = isArray ? [config safeObjectAtIndex: i] : config[keys[i]];
//        CGFloat z = [[self kValue:value object:object keyPath:keyPath] floatValue];
        CGFloat z = 0;
        BOOL isString = [value isKindOfClass:[NSString class]];
        BOOL isCurrentValue = isString && [self checkIsCurrentValue:value];
        BOOL isWindowCenter = isString && [self checkIsWindowCenterValue:value];
        BOOL isSuperCenter = isString && [self checkIsSuperCenterValue:value];
        
        if ( isCurrentValue || isWindowCenter || isSuperCenter ) {
            
            CGPoint point =  [[object valueForKeyPath:keyPath] CGPointValue];
            NSString* key = k_current_value;
            if (isWindowCenter) {
                point = [self getWindowCenter];
                key = k_window_middle;
            } else if (isSuperCenter) {
                point = [self getSuperCenter: object];
                key = k_super_middle;
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
    return [value rangeOfString:k_window_middle].location != NSNotFound ;
}

+(BOOL) checkIsSuperCenterValue:(NSString*)value
{
    return [value rangeOfString:k_super_middle].location != NSNotFound ;
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
