#import "GameEffect.h"
#import "AppInterface.h"

@implementation GameEffect

-(void) designateValuesActionsTo: (id)object config:(NSDictionary*)config completion:(void(^)(void))completion
{
    [VIEW.actionDurations clear];
    [self designateValuesActionsTo:object config:config];
    double duration = [VIEW.actionDurations take];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completion) {
            completion();
        }
    });
}

-(void) designateValuesActionsTo: (id)object config:(NSDictionary*)config
{
    if (!config || config.count == 0) return;
    
    // UIView's frame, if it is CALayer, no need to do this code.
    // Cause layer has the property frame. But now we do not set frame on layer
    id framesConfig = config[kFrame];
    if (framesConfig && [object isKindOfClass:[UIView class]]) {
        ((UIView*)object).frame = CanvasCGRect([RectHelper parseRect: framesConfig]);
    }
    
    id textFormatterConfig = config[kTextFormat];
    if (textFormatterConfig && [object isKindOfClass:[UILabel class]]) {
        [[TextFormatter sharedInstance] execute: textFormatterConfig onObject:object];
    }
    
    // Cause use the Dictionary to recursily call, so the CGPoint, CGSize, CGRect, UIColor ... can't use the dictionary to
    // design values. i.e point: {"x": 10, "y": 30} is not available now.
    
    [ConfigHelper iterateConfig:config handler:^(NSString *key, id value) {
        if ([key isEqualToString:kFrame]) return ;
        if ([key isEqualToString:kExecutors]) return;
        if ([key isEqualToString:kTextFormat]) return;
        if ([key isEqualToString: @"~class"]) return;
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            // have "~class" , means should new a object
            NSString* clazz = value[@"~class"];
            id nextObject = [object valueForKeyPath: key];
            if (clazz) {
                nextObject = [[NSClassFromString(clazz) alloc] init];
            }
            
            [self designateValuesActionsTo: nextObject config:value];
            
            
            if (clazz) {
                if ([object isKindOfClass:[NSMutableArray class]]) {
                    [object addObject: nextObject];
                } else {
                    // not use [[EffectHelper getInstance] setValue:newObj forKeyPath:key onObject:onObject];
                    // cause no need to tranlate value
                    [object setValue:nextObject forKey:key];
                }
            }
        } else {
            [[EffectHelper getInstance] setValue:value forKeyPath:key onObject:object];
        }
    }];
    
    // for the k_current_value reason , action execute shoule after set values .
    // but audio.play was not use on UIView ... this need to be think more about ...
    id actionsConfig = config[kExecutors];
    if (actionsConfig && [object isKindOfClass:[UIView class]]) {
        [VIEW.actionExecutorManager runActionExecutors:actionsConfig onObjects:@[object] values:nil baseTimes:nil];
    }
}

@end
