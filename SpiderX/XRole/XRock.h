//
//  XRock.h
//  SpiderX
//  陨石
//  Created by 陈 卓权 on 13-4-17.
//
//

#import "UnitSprite.h"

@interface XRock : UnitSprite
{
    CCParticleFire *fire;  //火焰粒子效果
}
+(id)create;
-(id)initRock;
-(void)setPosition:(CGPoint)position;
@end
