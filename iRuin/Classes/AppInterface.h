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

#import "Modules.h"


//InAppIMSDK
#import "InAppIMSDK.h"
#import "IAIExtDef.h"
#import "IAITopNavSkin.h"
#import "CConfigs.h"
#import "AllSDKManager.h"
#import "IAISimpleRoomInfo.h"



#pragma mark - Data
/** Data */
#import "DataManager.h"



#pragma mark - Action
/** Action */
#import "ActionManager.h"

#import "GameEvent.h"

#import "GameState.h"



// event
#import "BaseEvent.h"
#import "ChainableEvent.h"

#import "MoveEvent.h"

#import "TouchEvent.h"

#import "ExplodeEvent.h"
#import "DotsEvent.h"
#import "PullEvent.h"
#import "SwipeEvent.h"


// state
#import "BaseState.h"
#import "ChainableState.h"

#import "MoveState.h"

#import "TouchState.h"

#import "ExplodeState.h"
#import "DotsState.h"
#import "PullState.h"
#import "SwipeState.h"









#pragma mark - View
/** View */

// effect
#import "BaseEffect.h"
#import "ChainableEffect.h"

#import "MoveEffect.h"

#import "TouchEffect.h"

#import "ExplodeEffect.h"
#import "DotsEffect.h"
#import "PullEffect.h"
#import "SwipeEffect.h"





// Global
#import "ViewManager.h"
#import "FrameManager.h"
#import "GameController.h"

// GameView
#import "ChaptersView.h"
#import "GameView.h"
#import "HeaderView.h"
#import "ContainerView.h"
#import "SymbolView.h"

#import "InteractiveImageView.h"

// LineScrollView
#import "LineScrollView.h"
#import "LineScrollViewCell.h"










#pragma mark - Helper
/** Helper */

#import "StateHelper.h"
#import "EffectHelper.h"


#import "SearchHelper.h"
#import "PositionsHelper.h"

#import "FilterHelper.h"

#import "ExplodesExecutor.h"




