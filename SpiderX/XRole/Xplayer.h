//
//  Xplayer.h
//  SpiderX
//
//  Created by Charge on 13-4-4.
//
//

#import <Foundation/Foundation.h>
#import "UnitSprite.h"
@interface Xplayer:UnitSprite
{
    CCMotionStreak *playerStreak;
}
+(id)create;
-(id)initPlayer;
@end
