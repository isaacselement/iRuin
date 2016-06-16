#import "EffectHelper.h"
#import "AppInterface.h"


#define SeasonHintHudTag 2008


@implementation EffectHelper
{
    // queue views positions handler
    ViewsInRepositoryPositionsHandler fillInViewsPositionsHandler;
    ViewsInRepositoryPositionsHandler adjustViewsInVisualPositionsHandler;
    ViewsInRepositoryPositionsHandler rollInViewsInRepositoryPositionsHandler;
    ViewsInRepositoryPositionsHandler rollOutViewsInRepositoryPositionsHandler;
}

+(EffectHelper*) getInstance
{
    static EffectHelper* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[EffectHelper alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        KeyValueHelper* keyValueCodingHelper = [KeyValueHelper sharedInstance];
        [keyValueCodingHelper setTranslateValueHandler:^id(NSObject* obj, id value, NSString *type, NSString *key) {
            
            if ([key hasSuffix:@".x"]) {                    // for
                return @(CanvasX([value floatValue]));
            } else if ([key hasSuffix:@".y"]) {             // for
                return @(CanvasX([value floatValue]));
            } else if ([key hasSuffix:@".width"]) {         // for
                return @(CanvasW([value floatValue]));
            } else  if ([key hasSuffix:@".height"]) {       // for "bounds.size.height"
                return @(CanvasH([value floatValue]));
            }
            
            if (type) {
                
                if ([value isKindOfClass:[NSString class]]) {
                    if ([ConfigValueHandler checkIsCurrentValue:value]) {
                        return [obj valueForKeyPath:key];
                    } else if ([ConfigValueHandler checkIsWindowCenterValue:value]) {
                        return [NSValue valueWithCGPoint:[ConfigValueHandler getWindowCenter]];
                    } else if ([ConfigValueHandler checkIsSuperCenterValue:value]) {
                        return [NSValue valueWithCGPoint:[ConfigValueHandler getSuperCenter:obj]];
                    }
                }
                
                const char* rawType = [type UTF8String];
                
                if (strcmp(rawType, @encode(CGFloat)) == 0) {
                    if ([key hasSuffix:@"Width"]) {             // for. "eachCellWidth", "borderWidth"
                        return @(CanvasW([value floatValue]));
                    } else  if ([key hasSuffix:@"Height"]) {    // for. "eachCellHeight"
                        return @(CanvasH([value floatValue]));
                    }
                    
                } else if (strcmp(rawType, @encode(CGRect)) == 0) {
                    return [NSValue valueWithCGRect: CanvasCGRect([ConfigValueHandler parseRect:value object:obj keyPath:key])];
                    
                } else if (strcmp(rawType, @encode(CGPoint)) == 0) {
                    return [NSValue valueWithCGPoint: CanvasCGPoint([ConfigValueHandler parsePoint:value object:obj keyPath:key])];
                    
                } else if (strcmp(rawType, @encode(CGSize)) == 0) {
                    return [NSValue valueWithCGSize: CanvasCGSize([ConfigValueHandler parseSize:value object:obj keyPath:key])];
                    
                }
                
                if ([obj isKindOfClass:[CAGradientLayer class]]) {
                    if ([key isEqualToString:@"colors"]) {
                        /* po [KeyValueHelper getClassPropertieTypes:[CAGradientLayer class]] & colors = "@\"NSArray\""; & print @encode(NSArray) & (const char [12]) $1 = "{NSArray=#}" */
                        NSMutableArray* colors = [NSMutableArray array];
                        for (int i = 0; i < [value count]; i++) {
                            [colors addObject:(__bridge id)([ColorHelper parseColor: value[i]].CGColor)];
                        }
                        return colors;
                        
                    } else if ([key isEqualToString:@"startPoint"] || [key isEqualToString:@"endPoint"]) {
                        return [NSValue valueWithCGPoint: [RectHelper parsePoint: value]];
                    }
                    
                } else if ([obj isKindOfClass:[CAEmitterCell class]]) {
                    if ([key isEqualToString:@"contents"]) {
                        return (id)[[KeyValueHelper getUIImageByPath:value] CGImage];
                    }
                }
            }
            
            return [KeyValueHelper translateValue:value type:type];
        }];
    }
    return self;
}

-(void) setValue:(id)value forKeyPath:(NSString*)keyPath onObject:(NSObject*)object
{
    // cause we setTranslateValueHandler in init methods , so do not directly call this method below outside
    [[KeyValueHelper sharedInstance] setValue:value keyPath:keyPath object:object];
}

#pragma mark - Queue Views Positiosn Handler

-(ViewsInRepositoryPositionsHandler) fillInViewsPositionsHandler
{
    if (! fillInViewsPositionsHandler) {
        fillInViewsPositionsHandler = ^NSArray *(NSArray *lines, NSArray *indexPaths, NSArray* groupedNullIndexpaths, NSDictionary *linesConfig, NSArray* vanishingViews) {
            
            // TODO: If not enough ~~~~~~ , cause may vanish many ~~~~~  !
            NSMutableArray* uselessViews = [QueueViewsHelper getUselessViews];
            for (UIView* symbol in vanishingViews) {
                [uselessViews removeObject: symbol];
            }
            
            int count = 0 ;
            NSMutableArray* views = [NSMutableArray array];
            for (NSUInteger i = 0; i < groupedNullIndexpaths.count; i++) {
                NSArray* oneGroupedNullIndexpaths = groupedNullIndexpaths[i];
                NSMutableArray* innerViews = [NSMutableArray array];
                for (NSUInteger j = 0; j < oneGroupedNullIndexpaths.count; j++) {
                    SymbolView* symbol = [uselessViews objectAtIndex:count];
                    [symbol restore];
                    symbol.identification = [SymbolView getOneRandomSymbolIdentification];
                    [innerViews addObject: symbol];
                    count++;
                }
                [views addObject: innerViews];
            }
            
            NSMutableArray* positions = [QueuePositionsHelper getPositionsQueues: lines indexPaths:indexPaths linesConfig:linesConfig];
            
            // cause roll know how many view roll in , fill in need dynamic
            for (int i = 0; i < views.count; i++) {
                NSMutableArray* innverViews = [views objectAtIndex: i];
                for (int j = 1; j < innverViews.count; j++) {
                    [positions[i] insertObject:positions[i][0] atIndex:0];
                }
            }
            return @[views, positions];
        };
    }
    return fillInViewsPositionsHandler;
}

-(ViewsInRepositoryPositionsHandler) adjustViewsInVisualPositionsHandler
{
    if (! adjustViewsInVisualPositionsHandler) {
        adjustViewsInVisualPositionsHandler = ^NSArray *(NSArray *lines, NSArray *indexPaths, NSArray* groupedNullIndexpaths, NSDictionary *linesConfig, NSArray* vanishingViews) {
            NSMutableArray* views = [QueueViewsHelper getViewsQueuesIn:QueueViewsHelper.viewsInVisualArea lines:lines indexPaths:indexPaths];
            NSMutableArray* positions = [QueuePositionsHelper getPositionsQueues: lines indexPaths:indexPaths linesConfig:linesConfig];
            return @[views, positions];
        };
    }
    return adjustViewsInVisualPositionsHandler;
}

-(ViewsInRepositoryPositionsHandler) rollInViewsInRepositoryPositionsHandler
{
    if (! rollInViewsInRepositoryPositionsHandler) {
        rollInViewsInRepositoryPositionsHandler = ^NSArray *(NSArray *lines, NSArray *indexPaths, NSArray* groupedNullIndexpaths, NSDictionary *linesConfig, NSArray* vanishingViews) {
            // move all symbols to black point , cause roll out may be some time not roll all out . cause the line defined difference ...
            [IterateHelper iterateTwoDimensionArray:QueueViewsHelper.viewsRepository handler:^BOOL(NSUInteger outterIndex, NSUInteger innerIndex, id obj, NSUInteger outterCount, NSUInteger innerCount) {
                ((UIView*)obj).center = VIEW.frame.blackPoint;
                return NO;
            }];
            NSMutableArray* views = [QueueViewsHelper getViewsQueuesIn:QueueViewsHelper.viewsRepository lines:lines indexPaths:indexPaths];
            NSMutableArray* positions = [QueuePositionsHelper getPositionsQueues: lines indexPaths:indexPaths linesConfig:linesConfig];
            return @[views, positions];
        };
    }
    return rollInViewsInRepositoryPositionsHandler;
}

-(ViewsInRepositoryPositionsHandler) rollOutViewsInRepositoryPositionsHandler
{
    if (! rollOutViewsInRepositoryPositionsHandler) {
        rollOutViewsInRepositoryPositionsHandler = ^NSArray *(NSArray *lines, NSArray *indexPaths, NSArray* groupedNullIndexpaths, NSDictionary *linesConfig, NSArray* vanishingViews) {
            NSMutableArray* viewsInVisualArea = [PositionsHelper getViewsInContainerInVisualArea];
            NSMutableArray* views = [QueueViewsHelper getViewsQueuesIn:viewsInVisualArea lines:lines indexPaths:indexPaths];
            NSMutableArray* positions = [QueuePositionsHelper getPositionsQueues: lines indexPaths:indexPaths linesConfig:linesConfig];
            return @[views, positions];
        };
    }
    return rollOutViewsInRepositoryPositionsHandler;
}


#pragma mark -

-(void) startChapterCellsEffect: (NSMutableDictionary*)cellsConfigs
{
    NSArray* chaptersCells = VIEW.chaptersView.lineScrollView.contentView.subviews;
    for (int i = 0 ; i < chaptersCells.count; i++) {
        ImageLabelLineScrollCell* cell = [chaptersCells objectAtIndex:i];
        NSDictionary* config = [ConfigHelper getLoopConfig:cellsConfigs index:i];
        [ACTION.gameEffect designateValuesActionsTo:cell config: config];
    }
}


#pragma mark -

-(void) startScoresEffect:(NSArray*)symbols
{
    
}

-(void) startChainVanishingEffect:(NSArray*)symbols continuous:(int)continuous
{
    NSDictionary* ContinuousConfig = DATA.config[@"Continuous_Vanish"];
    
    NSDictionary* config = [ConfigHelper getLoopConfig:ContinuousConfig[@"ChainVanishing"] index:continuous];
    [ACTION.gameEffect designateToControllerWithConfig:config];
}

// here continuous is the last continuous count
-(void) stopChainVanishingEffect:(int)continuous
{
    NSDictionary* ContinuousConfig = DATA.config[@"Continuous_Vanish"];
    
    NSDictionary* config = [ConfigHelper getLoopConfig:ContinuousConfig[@"ChainVanishing_Stop"] index:continuous];
    [ACTION.gameEffect designateToControllerWithConfig:config];
}

#pragma mark - pass season hint

-(void) showPassedSeasonHint:(int)hideDelay title:(NSString*)title scoreDelay:(int)scoreDelay messageDelay:(int)messageDelay
{
    MBProgressHUD *hud = [self getPassedSeasonHint: hideDelay];
    [self showSeasonHud: hud title:title scoreDelay:scoreDelay messageDelay:messageDelay];
}

-(MBProgressHUD*) getPassedSeasonHint: (int)hideDelay
{
    MBProgressHUD *hud = (MBProgressHUD*)[[ViewHelper getTopView] viewWithTag:SeasonHintHudTag];
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:[ViewHelper getTopView] animated:YES];
        hud.tag = SeasonHintHudTag;
        hud.userInteractionEnabled = NO;
        
        hud.mode = MBProgressHUDModeText;
        hud.dimBackground = YES;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay: hideDelay];
    }
    return hud;
}

-(void) showSeasonHud: (MBProgressHUD*)hud title:(NSString*)title scoreDelay:(int)scoreDelay messageDelay:(int)messageDelay
{
    if (!hud) {
        hud = (MBProgressHUD*)[[ViewHelper getTopView] viewWithTag:SeasonHintHudTag];
    }
    if (!hud) return;
    
    hud.labelText = title;
    
    NSString* message = nil;
    if (VIEW.gameView.vanishAmountLabel.number >= ACTION.gameState.clearanceScore) {
        if (ACTION.gameState.currentChapter != [[APPStandUserDefaults objectForKey:User_ChapterIndex] intValue]) {
            message = [NSString stringWithFormat:@"Season %d already unlocked :)", ACTION.gameState.currentChapter + 1];
        } else {
            [APPStandUserDefaults setObject: @(ACTION.gameState.currentChapter + 1) forKey:User_ChapterIndex];  // do no put this in delay, important!!!
            [VIEW.chaptersView.lineScrollView setCurrentIndex: [[APPStandUserDefaults objectForKey:User_ChapterIndex] intValue]];
            
            message = [NSString stringWithFormat:@"Season %d now unlocked :)", [[APPStandUserDefaults objectForKey:User_ChapterIndex] intValue]];
        }
        
    } else {
        message = [NSString stringWithFormat:@"No new season unlocked :("];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(scoreDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        hud.detailsLabelText = [NSString stringWithFormat:@"You got %.0f, clearance is %d", VIEW.gameView.vanishAmountLabel.number, ACTION.gameState.clearanceScore];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(messageDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        hud.labelText = message;
        hud.detailsLabelText = nil;
    });
}


-(void) showClearanceScore:(int)clearanceScore
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[ViewHelper getTopView] animated:YES];
    hud.userInteractionEnabled = NO;
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = [NSString stringWithFormat: @"This Season Clearance Score is %d", clearanceScore];
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay: 1 + RANDOM(3)];
}

@end
