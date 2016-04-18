#import "GameEffect.h"
#import "AppInterface.h"

@implementation GameEffect


#define kIgnore @"_"
#define kReserved @"~"
#define kFrame @"Frame"
#define kExecutors @"Executors"
#define kTextFormatter @"kTextFormatter"


-(void) designateValuesActionsTo: (id)object config:(NSDictionary*)config
{
    if (!config || config.count == 0) return;
    
    // UIView's frame , if is CALayer, no need to do this
    id framesConfig = config[kFrame];
    if (framesConfig && [object isKindOfClass:[UIView class]]) {
        ((UIView*)object).frame = CanvasCGRect([RectHelper parseRect: framesConfig]);
    }
    
    id actionsConfig = config[kExecutors];
    if (actionsConfig && [object isKindOfClass:[UIView class]]) {  // but audio.play was not use on UIView ... this need to be think more about ...
        [VIEW.actionExecutorManager runActionExecutors:actionsConfig onObjects:@[object] values:nil baseTimes:nil];
    }
    
    id textFormatterConfig = config[kTextFormatter];
    if (textFormatterConfig && [object isKindOfClass:[UILabel class]]) {
        [[TextFormatter sharedInstance] execute: textFormatterConfig onObject:object];
    }
    
    for (NSString* key in config) {
        if ([key hasSuffix:kIgnore]) continue;
        if ([key hasPrefix:kReserved]) continue;
        // cause above handled these three
        if ([key isEqualToString:kFrame]) continue;
        if ([key isEqualToString:kExecutors]) continue;
        if ([key isEqualToString:kTextFormatter]) continue;
        
        id value = config[key];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            [self designateValuesActionsTo: [object valueForKey: key] config:value];
        } else {
            [[EffectHelper getInstance] setValue:value forKeyPath:key onObject:object];
        }
    }
}


@end
