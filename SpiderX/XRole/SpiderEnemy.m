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
#import "Xbullet.h"
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
    {0,@"E0.png",@"W2.png",1,0,1},
    {1,@"E1.png",@"W2.png",2,0,2},
    {2,@"E2.png",@"W2.png",4,2,4},
    {3,@"E3.png",@"W2.png",6,3,6},
    {4,@"E4.png",@"W2.png",10,2,8},
    {5,@"E5.png",@"W2.png",15,2,10},
};

+(id) create:(EnemyType) type
{
    return [[[self alloc] enemyInit:type] autorelease];
}
+(void) sharedEnemy
{
    NSString *enemyList = @"";
    if ([UIScreen instancesRespondToSelector:@selector(scale)])  //todo tmx文件自适应高清屏
    {
        if ([[UIScreen mainScreen] scale]>1.0)
        {
            enemyList =@"Enemy-hd.plist";
        } else
        {
            enemyList =@"Enemy.plist";
        }
    }
    else //保护下
    {
        enemyList =@"Enemy.plist";
    }
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:enemyList textureFilename:@"Enemy.png"];
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
        if(type.type==5){
            [self schedule:@selector(shoot) interval:m_delayTime];

        }
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
	
	Xbullet* bullet = [Xbullet createWithFile:@"stone.png"];
    //	bullet.scale = 0.3f;
	bullet.position = initialPoint;
	[self.parent addChild:bullet];
    [enemy_bullet addObject:bullet];
	
	[bullet runAction:[CCMoveTo actionWithDuration:1.0f position:endPoint]];
}

-(void)hurt
{
    m_HP --;  
    [super hurt];
}
-(int)getScore
{
    return m_scoreValue;
}

-(void)destroy
{
    Effect *effect = [Effect create];
    [effect sparkExplode:self.parent at:self.position];

    // 敌机爆炸，从敌机数组删除
//    enemy_items->removeObject(this);
    [self removeFromParentAndCleanup:YES];
    self =nil;
//        [enemy_items removeObject:self];

}
@end
