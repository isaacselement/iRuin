#import "GameEffect.h"
#import "AppInterface.h"

@implementation GameEffect

#define kIgnore @"_"
#define kFrame @"Frame"
#define kExecutors @"Executors"

-(void) designateValuesActionsTo: (id)object config:(NSDictionary*)config
{
    if (!config) return;
    
    KeyValueCodingHelper* keyValueCodingHelper = [KeyValueCodingHelper sharedInstance];
    
    if (! [keyValueCodingHelper translateValueHandler]) {
        
        // set handler, for LineScrollView's "eachCellWidth" now
        [keyValueCodingHelper setTranslateValueHandler:^id(id value, NSString *type, NSString *key) {
            id result = [KeyValueCodingHelper translateValue: value type:type];
            
            const char* rawType = [type UTF8String];
            if (strcmp(rawType, @encode(CGFloat)) == 0) {
                if ([key rangeOfString:@"Width"].location != NSNotFound) {
                    CGFloat num = [value floatValue];
                    result = @(CanvasW(num));
                }
            }
            return result;
        }];
        
    }
    
    
    // UIView's frame , if is CALayer, no need to do this
    id framesConfig = config[kFrame];
    if (framesConfig && [object isKindOfClass:[UIView class]]) {
        ((UIView*)object).frame = CanvasCGRect([RectHelper parseRect: framesConfig]);
    }
    
    id actionsConfig = config[kExecutors];
    if (actionsConfig && [object isKindOfClass:[UIView class]]) {
        [VIEW.actionExecutorManager runActionExecutors:actionsConfig onObjects:@[object] values:nil baseTimes:nil];
    }
    
    for (NSString* key in config) {
        if ([key hasSuffix:kIgnore]) continue;
        if ([key isEqualToString:kFrame]) continue;
        if ([key isEqualToString:kExecutors]) continue;
        
        id value = config[key];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            id nextObject = [object valueForKey: key];
            [self designateValuesActionsTo: nextObject config:value];
        } else {
            [[KeyValueCodingHelper sharedInstance] setValue:value keyPath:key object:object];
        }
        
    }
    
}



@end
