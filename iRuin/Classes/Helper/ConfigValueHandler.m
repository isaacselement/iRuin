#import "ConfigValueHandler.h"
#import "AppInterface.h"


#define k_prefix @"k_"
#define k_sperator @"_"

#define k_object_current @"current"
#define k_object_window  @"window"
#define k_object_super   @"super"

@implementation ConfigValueHandler


+(CGPoint) parsePoint: (id)config object:(NSObject*)object keyPath:(NSString*)keyPath
{
    NSArray* keys = @[@"x", @"y"];
    CGFloat result[keys.count];
    [self parse:config keys:keys object:object keyPath:keyPath result:result];
    return CGPointMake(result[0], result[1]);
}


+(CGSize) parseSize: (id)config object:(NSObject*)object keyPath:(NSString*)keyPath
{
    NSArray* keys = @[@"width", @"height"];
    CGFloat result[keys.count];
    [self parse:config keys:keys object:object keyPath:keyPath result:result];
    return CGSizeMake(result[0], result[1]);
}


+(CGRect) parseRect: (id)config object:(NSObject*)object keyPath:(NSString*)keyPath
{
    NSArray* keys = @[@"x", @"y", @"width", @"height"];
    CGFloat result[keys.count];
    [self parse:config keys:keys object:object keyPath:keyPath result:result];
    return CGRectMake(result[0], result[1], result[2], result[3]);
}

+(void) parse:(id)config keys:(NSArray*)keys object:(NSObject*)object keyPath:(NSString*)keyPath result:(CGFloat[])result
{
    int count = (int)keys.count;
    BOOL isArray = [config isKindOfClass: [NSArray class]];
    for (int i = 0; i < count; i++) {
        id value = isArray ? [config safeObjectAtIndex: i] : config[keys[i]];
        if ([self isKValue: value]) {
            result[i] = [[self getKValue:value object:object keyPath:keyPath] floatValue];
        } else {
            CGFloat o = [value floatValue];
            if (i == 0) {
                o = [FrameTranslater convertCanvasX:o];
            } else if (i == 1) {
                o = [FrameTranslater convertCanvasY:o];
            } else if (i == 2) {
                o = [FrameTranslater convertCanvasWidth:o];
            } else {
                o = [FrameTranslater convertCanvasHeight:o];
            }
            result[i] = o;
        }
    }
}


+(BOOL) isKValue:(id)value
{
    return [value isKindOfClass:[NSString class]] && [value hasPrefix: k_prefix];
}

+(id) getKValue:(id)value object:(NSObject*)object keyPath:(NSString*)keyPath
{
    NSString* expression = [[value componentsSeparatedByString:k_prefix] lastObject];
    NSArray* targetAction = [expression componentsSeparatedByString:k_sperator];
    if (targetAction.count >= 2) {
        NSString* targetString = [targetAction firstObject];
        NSString* actionString = [targetAction objectAtIndex:1];
        NSString* expression = [targetAction safeObjectAtIndex:2];
        
        // get target object
        id targetObj = nil;
        if ([targetString isEqualToString:k_object_current]) {
            targetObj = object;
        } else if ([targetString isEqualToString:k_object_window]) {
            targetObj = [[[UIApplication sharedApplication] delegate] window];
        } else if ([targetString isEqualToString:k_object_super]) {
            targetObj = [self getSuperObject: object];
        }
        
        // get value object
        if ([actionString hasPrefix:@"value"]) {
            id newValue = [targetObj valueForKeyPath: keyPath];
            return [self getValue:newValue action:actionString expression:expression];;
            
        } else {
            
            if ([actionString hasPrefix:@"center"]) {
                CGPoint point = [self getViewLayerCenter: targetObj];
                return [self getValue:[NSValue valueWithCGPoint: point] action:actionString expression:expression];
                
            } else if ([actionString hasPrefix:@"middle"]) {
                CGPoint point = [self getViewLayerMiddle: targetObj];
                return [self getValue:[NSValue valueWithCGPoint: point] action:actionString expression:expression];
                
            } else {
                NSValue* newValue = [NSValue valueWithCGRect: [targetObj frame]];
                
                //--- like k_window_width, k_window_height, k_super_x, k_current_y
                return [self getElementValue:actionString value:newValue expression:expression];
            }
        }
    }
    return value;
}

+(id) getValue:(NSValue*)value action:(NSString*)action expression:(NSString*)expression
{
    NSString* xywh = [[action componentsSeparatedByString:@"."] lastObject];
    if (![xywh isEqualToString:action]) {
        return [self getElementValue:xywh value:value expression:expression];
    }
    return value;
}

+(id) getElementValue:xywh value:(NSValue*)value expression:(NSString*)expression
{
    if (![value isKindOfClass:[NSValue class]]) {
        return value;
    }
    if (!([xywh isEqualToString:@"x"] || [xywh isEqualToString:@"y"] || [xywh isEqualToString:@"width"] || [xywh isEqualToString:@"height"])) {
        return value;
    }
    
    // get the value
    CGFloat z = 0;
    NSString* valueDescription = [value description];
    if ([valueDescription rangeOfString:@"Rect"].location != NSNotFound) {
        CGRect rect = [value CGRectValue];
        if ([xywh isEqualToString:@"x"]) {
            z = rect.origin.x;
        } else if ([xywh isEqualToString:@"y"]) {
            z = rect.origin.y;
        } else if ([xywh isEqualToString:@"width"]) {
            z = rect.size.width;
        } else if ([xywh isEqualToString:@"height"]) {
            z = rect.size.height;
        }
        
    } else if ([valueDescription rangeOfString:@"Point"].location != NSNotFound) {
        CGPoint point = [value CGPointValue];
        if ([xywh isEqualToString:@"x"]) {
            z = point.x;
        } else if ([xywh isEqualToString:@"y"]) {
            z = point.y;
        }
        
    } else if ([valueDescription rangeOfString:@"Size"].location != NSNotFound) {
        CGSize size = [value CGSizeValue];
        if ([xywh isEqualToString:@"width"]) {
            z = size.width;
        } else if ([xywh isEqualToString:@"height"]) {
            z = size.height;
        }
    }
    
    // handle the expression
    if ([expression isEqualToString:@"-"]) {
        z = -z;
    } else if ([expression hasPrefix:@"-"]) {
        CGFloat v = [[[expression componentsSeparatedByString:@"-"] lastObject] floatValue];
        v = [self canvasV:v xywh:xywh];
        z = z - v;
    } else if ([expression hasPrefix:@"+"]) {
        CGFloat v = [[[expression componentsSeparatedByString:@"+"] lastObject] floatValue];
        v = [self canvasV:v xywh:xywh];
        z = z + v;
    } else if ([expression hasPrefix:@"*"]) {
        CGFloat v = [[[expression componentsSeparatedByString:@"*"] lastObject] floatValue];
        z = z * v;
    } else if ([expression hasPrefix:@"/"]) {
        CGFloat v = [[[expression componentsSeparatedByString:@"/"] lastObject] floatValue];
        z = z / v;
    }
    
    return @(z);
}

+(CGFloat) canvasV:(CGFloat)v xywh:(NSString*)xywh
{
    if ([xywh isEqualToString:@"x"]) {
        v = [FrameTranslater convertCanvasX:v];
    } else if ([xywh isEqualToString:@"y"]) {
        v = [FrameTranslater convertCanvasY:v];
    } else if ([xywh isEqualToString:@"width"]) {
        v = [FrameTranslater convertCanvasWidth:v];
    } else if ([xywh isEqualToString:@"height"]) {
        v = [FrameTranslater convertCanvasHeight:v];
    }
    return v;
}

#pragma mark -

+(id) getSuperObject:(id)object
{
    id obj = nil;
    if ([object isKindOfClass:[UIView class]]) {
        obj = [(UIView*)object superview];
    } else if ([object isKindOfClass:[CALayer class]]) {
        obj = [(CALayer*)object superlayer];
    }
    return obj;
}

+(CGPoint) getViewLayerCenter:(id)object
{
    CGPoint point = CGPointZero;
    if ([object isKindOfClass:[UIView class]]) {
        point = [(UIView*)object center];
    } else if ([object isKindOfClass:[CALayer class]]) {
        point = [(CALayer*)object position];
    }
    return point;
}

+(CGPoint) getViewLayerMiddle:(id)object
{
    return [object middlePoint];
}

@end