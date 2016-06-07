#import "GameEffect.h"
#import "AppInterface.h"

@implementation GameEffect

-(void) designateValuesActionsTo: (id)object config:(NSDictionary*)config completion:( void(^)(void))completion
{
    [VIEW.actionDurations clear];
    [self designateValuesActionsTo:object config:config];
    double duration = [VIEW.actionDurations take];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completion();
    });
}

-(void) designateValuesActionsTo: (id)object config:(NSDictionary*)config
{
    if (!object || !config || config.count == 0) return;
    
    
    // UIView's frame, if it is CALayer, no need to do this code.
    // Cause layer has the property frame. But now we do not set frame on layer
    
    id framesConfig = config[kReservedFrame];
    if (framesConfig && [object isKindOfClass:[UIView class]]) {
        ((UIView*)object).frame = CanvasCGRect([RectHelper parseRect: framesConfig]);
    }
    
    id textFormatterConfig = config[kReservedText];
    if (textFormatterConfig && [object isKindOfClass:[UILabel class]]) {
        [[TextFormatter sharedInstance] execute: textFormatterConfig onObject:object];
    }
    
    
    // Cause use the Dictionary to recursily call, so the CGPoint, CGSize, CGRect, UIColor ... can't use the dictionary to
    // design values. i.e point: {"x": 10, "y": 30} is not available now.
    
    [ConfigHelper iterateConfig:config handler:^(NSString *key, id value) {
        if ([value isKindOfClass:[NSDictionary class]]) {
            
            // ------ Handle the new object Begin ------
            // have "~Class" , means should new a object
            NSString* clazz = value[kReservedClass];
            id nextObject = [object valueForKeyPath: key];
            if (clazz) {
                nextObject = [[NSClassFromString(clazz) alloc] init];
                // add the object , or set the value that we will handle it in NSObject+KeyValueHelper/NSArray+KeyValueHelper/CALayer+KeyValueHelper
                
                if ([object isKindOfClass:[NSMutableArray class]]) {
                    [object addObject: nextObject];
                } else {
                    // not use [[EffectHelper getInstance] setValue:newObj forKeyPath:key onObject:onObject], cause no need to tranlate value
                    // also, you can set nil . nil will remove view / layer.
                    [object setValue:nextObject forKey:key];
                }
            }
            // ------ Handle the new object Begin ------
            
            [self designateValuesActionsTo: nextObject config:value];
            
            
            // ------ Handle the new object End ------
            // cause the CAEmitterLayer & CAEmitterCell class's property emitterCells is NSArray and use keyword copy!!
            if (clazz ) {
                if (/*[object isKindOfClass:[CAEmitterLayer class]] || [object isKindOfClass:[CAEmitterCell class]]*/[key isEqualToString:@"emitterCells"]) {
                    [object setValue:nextObject forKey:key];
                }
            }
            // ------ Handle the new object End ------
            
        } else {
            [[EffectHelper getInstance] setValue:value forKeyPath:key onObject:object];
        }
    }];
    
    
    // for the k_current_value reason , action execute shoule after set values .
    // but audio.play was not use on UIView ... this need to be think more about ...
    
    id actionsConfig = config[kReservedExecutors];
    if (!actionsConfig || ![object isKindOfClass:[UIView class]]) {
        return;
    }
    
    NSArray* objects = @[object];
    // so should have "~Executors" first, then the "~ExecutorsDone" will take effect.
    id actionsDoneConfig = config[kReservedExecutorsDone];
    
    if (actionsDoneConfig) {
        [VIEW.actionDurations justClearOnePhase];
        [VIEW.actionExecutorManager runActionExecutors:actionsConfig onObjects:objects values:nil baseTimes:nil];
        double duration = [VIEW.actionDurations justTakeOnePhase];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [VIEW.actionExecutorManager runActionExecutors:actionsDoneConfig onObjects:objects values:nil baseTimes:nil];
        });
    } else {
        [VIEW.actionExecutorManager runActionExecutors:actionsConfig onObjects:objects values:nil baseTimes:nil];
    }
    
}

@end
