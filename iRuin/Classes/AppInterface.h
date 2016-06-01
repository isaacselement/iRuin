/**
*  AppInterface.h
*
*  Note:
*      Every *.m file import this AppInterface.h file , and every *.h should be import one here
*      Important !!! Do not import this AppInterface.h in any header(*.h) file .
*
*/

#import "AppDelegate.h"
#import "IRuinApplication.h"

#import "AppConfig.h"


#pragma mark - Modules

#import "ModulesMacro.h"


#pragma mark - Action

#import "_Scheduled.h"


#import "_Operation.h"



#pragma mark - Data

#import "FileManager.h"

#import "JsonFileManager.h"

#import "HTTPGetRequest.h"

#import "SharedMotionManager.h"


#pragma mark - View


#import "_Color.h"

#import "_Frame.h"

#import "_Components.h"

#import "_ActionExecutor.h"

#import "ExplodesExecutor.h"



#pragma mark - Helper

#import "_NSCategories.h"
#import "NSObject+KeyValueHelper.h"

#import "_ViewHelper.h"

#import "_DateHelper.h"

#import "_CharacterHelper.h"

#import "_CollectionHelper.h"



#pragma mark - Frameworks & Libraries

/** Frameworks & Libraries */
#import <QuartzCore/QuartzCore.h>

#import <AVFoundation/AVFoundation.h>

#import "SSZipArchive.h"

#import "TextFormatter.h"
#import "AudioHandler.h"
#import "AudiosExecutor.h"
#import "MXAudioPlayerFadeOperation.h"


// Third-Party
#import "FBShimmeringView.h"
#import "PPSSignatureView.h"
#import "MBProgressHUD.h"





#pragma mark - Data
/** Data */
#import "DataManager.h"
#import "AppUserDefaults.h"



#pragma mark - Action
/** Action */
#import "ActionManager.h"

#import "GameEvent.h"

#import "GameState.h"



// event
#import "BaseEvent.h"
#import "ChainableEvent.h"

#import "RouteEvent.h"

#import "TouchEvent.h"

#import "MoveEvent.h"
#import "PullEvent.h"
#import "SwipeEvent.h"


// state
#import "BaseState.h"
#import "ChainableState.h"

#import "RouteState.h"

#import "TouchState.h"

#import "MoveState.h"
#import "PullState.h"
#import "SwipeState.h"









#pragma mark - View
/** View */

// effect
#import "GameEffect.h"

#import "BaseEffect.h"
#import "ChainableEffect.h"

#import "RouteEffect.h"

#import "TouchEffect.h"

#import "MoveEffect.h"
#import "PullEffect.h"
#import "SwipeEffect.h"





// Global
#import "ViewManager.h"
#import "FrameManager.h"
#import "GameController.h"

// GameView
#import "GameView.h"
#import "ChaptersView.h"
#import "ContainerView.h"

#import "TimerView.h"

#import "ScoreLabel.h"


#import "SymbolView.h"
#import "GradientImageView.h"

#import "InteractiveImageView.h"

#import "ImageLabelLineScrollCell.h"

// LineScrollView
#import "LineScrollView.h"
#import "LineScrollViewCell.h"

#import "InformedView.h"

#import "EmissionLayer.h"




#pragma mark - Helper
/** Helper */
#import "EventHelper.h"
#import "StateHelper.h"
#import "ConfigHelper.h"
#import "EffectHelper.h"
#import "FilterHelper.h"
#import "SearchHelper.h"
#import "ScheduledHelper.h"
#import "PositionsHelper.h"

#import "ConfigValueHandler.h"

#import "NSArray+KVC.h"


