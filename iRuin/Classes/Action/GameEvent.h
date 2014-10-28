#import <Foundation/Foundation.h>

@interface GameEvent : NSObject


-(void) gameStartWithChapter: (int)chapterIndex;

-(void) gameBack;

-(void) gamePause;

-(void) gameRefresh;


@end
