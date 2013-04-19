//
//  XRock.h
//  SpiderX
//
//  Created by 陈 卓权 on 13-4-17.
//
//

#import "UnitSprite.h"

@interface XRock : UnitSprite
{
    CCParticleFire *fire;
}
+(id)create;
-(id)initRock;
-(void)setPosition:(CGPoint)position;
@end
