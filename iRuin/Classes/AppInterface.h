/**
*  AppInterface.h
*
*  Note:
*      Every *.m file import this AppInterface.h file , and every *.h should be import one here
*      Important !!! Do not import this AppInterface.h in any header(*.h) file .
*
*/

#import "AppDelegate.h"

#import "AppConfig.h"


#pragma mark - Frameworks & Libraries

/** Frameworks & Libraries */
#import <QuartzCore/QuartzCore.h>

#import <AVFoundation/AVFoundation.h>


// Modules
#import "Modules.h"

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

#import "ConfigHelper.h"



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


#import "InteractiveView.h"
#import "InteractiveImageView.h"

#import "ImageLabelLineScrollCell.h"

// LineScrollView
#import "LineScrollView.h"
#import "LineScrollViewCell.h"







#pragma mark - Helper
/** Helper */

#import "StateHelper.h"
#import "EffectHelper.h"
#import "ScheduledHelper.h"

#import "SearchHelper.h"
#import "PositionsHelper.h"

#import "FilterHelper.h"

#import "ExplodesExecutor.h"




