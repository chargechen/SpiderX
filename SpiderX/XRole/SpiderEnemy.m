//
//  SpiderEnemy.m
//  SpiderX
//
//  Created by 陈 卓权 on 13-4-15.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "SpiderEnemy.h"
#import "Config.h"
#import "Effect.h"
@interface SpiderEnemy ()
{
    bool m_active;
    int m_speed;
    int m_bulletSpeed;
    int m_HP;
    int m_bulletPowerValure;
    int m_moveType;
    int m_scoreValue;
    int m_zOrder;
    float m_delayTime;
    int m_attackMode;

}
@end
@implementation SpiderEnemy
EnemyType EnemyUnit[] = {
    {0,@"E0.png",@"W2.png",1,0,15},
    {1,@"E1.png",@"W2.png",2,0,40},
    {2,@"E2.png",@"W2.png",4,2,60},
    {3,@"E3.png",@"W2.png",6,3,80},
    {4,@"E4.png",@"W2.png",10,2,150},
    {5,@"E5.png",@"W2.png",15,2,200},
};
/**自己的init函数*/
+(id) create:(EnemyType) type
{
    return [[[self alloc] enemyInit:type] autorelease];
}
+(void) sharedEnemy
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Enemy.plist" textureFilename:@"Enemy.png"];
}
-(id)enemyInit:(EnemyType)type
{
   	if ((self = [super initWithSpriteFrameName:type.textureName]))
	{
        m_active =true;
        m_speed = 200;
        m_bulletSpeed = -200;
        m_bulletPowerValure = 1;
        m_zOrder =1000;
        m_delayTime =1+1.2*CCRANDOM_0_1();
        m_attackMode=1;
        
        m_HP = type.hp;
        m_moveType = type.moveType;
        m_scoreValue = type.scoreValue;
//        [self schedule:@selector(shoot) interval:m_delayTime];
    }
	
	return self;    
}

-(void)update:(float)dt
{
    if (m_HP < 0) {
        m_active = false;
    }
}
-(int)getMoveType
{
    return m_moveType;
}
-(bool)isActive
{
    return m_active;
}

-(void)shoot
{
    CGPoint pos =self.position;
	
	CGPoint initialPoint = ccp(pos.x,pos.y);
	CGPoint endPoint = ccp(pos.x,pos.y-600);
	
	CCSprite* bullet = [CCSprite spriteWithFile:@"explode2.jpg"];
    //	bullet.scale = 0.3f;
	bullet.position = initialPoint;
	[self.parent addChild:bullet];
//	[bullets addObject:bullet];
	
	CCActionInterval* action = [CCSequence actions:
								[CCMoveTo actionWithDuration:1.0f position:endPoint],
//								[CCCallFuncN actionWithTarget:self selector:@selector(removeBullet:)],
								nil];
	[bullet runAction:action];
//    CCPoint pos = this->getPosition();
//    Bullet *bullet = new Bullet(m_bulletSpeed, "W2.png", m_attackMode);
//    bullet->autorelease();
//    enemy_bullet->addObject(bullet);
//    getParent()->addChild(bullet, m_zOrder, 900);
//    bullet->setPosition(ccp(pos.x, pos.y - getContentSize().height * 0.2));
}
-(void)hurt
{
    m_HP --;
}
-(void)destroy
{
    [[Config sharedConfig] setScoreValue:m_scoreValue];
    Effect *effect = [Effect create];
    [effect sparkExplode:self.parent at:self.position];

    // 敌机爆炸，从敌机数组删除
//    enemy_items->removeObject(this);
    [self removeFromParentAndCleanup:YES];

}
@end
