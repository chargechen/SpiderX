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
-(void)setPosition:(CGPoint)position;
+(id)createIn:(CCNode*)parent;
-(id)initPlayer:(CCNode*)parent;
@end
