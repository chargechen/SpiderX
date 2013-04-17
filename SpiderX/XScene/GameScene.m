//
//  GameScene.m
//  SpiderX
//
//  Created by 陈 卓权 on 13-3-24.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
#import "SimpleAudioEngine.h"
#import "GameOverScene.h"
#import "Effect.h"
#import "Config.h"
#import "SpiderEnemy.h"
#define bulletCount 100
#define marginLeft 10
@interface GameScene(){
    CGSize screenSize;
}
@end
@implementation GameScene
@synthesize listener;
@synthesize pv_averagePower;
@synthesize pv_peakPower;
+(id)scene
{
    CCScene *scene =[CCScene node];
    CCLayer *layer = [GameScene node];
    [scene addChild:layer];
    return scene;
}
-(id)init
{
    if(self=[super init])
    {
        screenSize = [[CCDirector sharedDirector]winSize];
        enemy_items = [[NSMutableArray alloc]init];
        
        [Effect sharedExplosion];
        [SpiderEnemy sharedEnemy];
        pv_averagePower = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        pv_averagePower.frame = CGRectMake(2, 46, 51, 3);
        pv_averagePower.tag=2;
        [[CCDirector sharedDirector].view addSubview:pv_averagePower];
//        [[[CCDirector sharedDirector] openGLView] addSubview:pv_averagePower];
        pv_peakPower = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        pv_peakPower.frame = CGRectMake(2, 146, 51, 103);
        pv_averagePower.tag=3;
        [[CCDirector sharedDirector].view addSubview:pv_peakPower];
//        [[[CCDirector sharedDirector] openGLView] addSubview:pv_peakPower];
        
        [[SCListener sharedListener] listen];
                
        self.listener = [SCListener sharedListener];
        [self schedule:@selector(checkForVoiceBomb:) interval:0.1];
        totalTime =0;
        [Config sharedConfig].scoreValue =0;
        playerlife = 3;
        self.isAccelerometerEnabled = YES;
        [self initPlayer];
        self.isTouchEnabled =YES;
        [self schedule:@selector(addEnemyToGameLayer) interval:1];
        [self scheduleUpdate];
        [self initSpiders];
        [self initBackground];
        //初始化子弹数组
        bullets = [[CCArray alloc] initWithCapacity:bulletCount];
        
        CCLabelTTF *yourlife = [CCLabelTTF labelWithString:@"YOUR LIVES:" fontName:@"Marker Felt" fontSize:18];
        CCLabelTTF *yourScore = [CCLabelTTF labelWithString:@"SCORE:" fontName:@"Marker Felt" fontSize:18];
    
        
        lifeLabel = [CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%i",playerlife] charMapFile:@"fps_images.png" itemWidth:12 itemHeight:32 startCharMap:'.'];
        scoreLable = [CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%i",0] charMapFile:@"fps_images.png" itemWidth:12 itemHeight:32 startCharMap:'.'];
        [lifeLabel setPosition:ccp(screenSize.width-lifeLabel.contentSize.width,screenSize.height-lifeLabel.contentSize.height/2)];
        
        [scoreLable setPosition:ccp(yourScore.contentSize.width+marginLeft,screenSize.height-scoreLable.contentSize.height/2)];
        [yourScore setPosition:ccp(yourScore.contentSize.width/2,screenSize.height-yourScore.contentSize.height/2+2)];
        
        [yourlife setPosition:ccp(screenSize.width-yourlife.contentSize.width/2-lifeLabel.contentSize.width-marginLeft,screenSize.height-yourlife.contentSize.height/2+2)];
        
//        scoreLable.anchorPoint = CGPointMake(0.5f, 1.0f);
//        lifeLabel.anchorPoint =CGPointMake(0.5f, 1.0f);

        [self addChild:scoreLable z:-1];
        [self addChild:lifeLabel z:40];
        [self addChild:yourlife z:40];
        [self addChild:yourScore z:40];
//        CCMenuItem *shootMenuItem =[CCMenuItemImage itemWithNormalImage:@"ButtonPlus.png" selectedImage:@"ButtonPlusSel.png" target:self selector:@selector(startShoot)];
//        shootMenuItem.position = CGPointZero;
//        CCMenu *shootMenu = [CCMenu menuWithItems:shootMenuItem, nil];
//        shootMenu.position = ccp(screenSize.width-30,screenSize.height/2);
//        [self addChild:shootMenu z:70 tag:70];
        
//        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Cyber Advance.mp3" loop:YES];
    }
    return self;
}

// 无限滚动地图，采用两张图循环加载滚动
-(void)initBackground
{
    m_backSky =nil;
    m_backSky = [CCSprite spriteWithFile:@"bg01.jpg"];
    
    [m_backSky setAnchorPoint:ccp(0,0)];
    
    m_backSkyHeight = m_backSky.contentSize.height;
    [self addChild:m_backSky z:-10];
    
    if ([UIScreen instancesRespondToSelector:@selector(scale)])
    {
        if ([[UIScreen mainScreen] scale]>1.0)
        {
            m_backTileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"level01-hd.tmx"];
        } else
        {
            m_backTileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"level01.tmx"];
        }
    }
    else //保护下
    {
        m_backTileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"level01.tmx"];
    }
    [self addChild:m_backTileMap z:-9];
    // Tile map
    m_backTileMapHeight = m_backTileMap.mapSize.height *m_backTileMap.tileSize.height;

    m_backSkyHeight -= 48;
    m_backTileMapHeight -= 200;
    [m_backSky runAction:[CCMoveBy actionWithDuration:3 position:ccp(0,-48)]];
    [m_backTileMap runAction:[CCMoveBy actionWithDuration:3 position:ccp(0,-200)]];
    
    [self schedule:@selector(movingBackground) interval:3];    
}
// 这里就是视差背景了
-(void)movingBackground
{
    [m_backSky runAction:[CCMoveBy actionWithDuration:3 position:ccp(0,-48)]];
    [m_backTileMap runAction:[CCMoveBy actionWithDuration:3 position:ccp(0,-200)]];    
    // 每次移动48
    m_backSkyHeight -= 48;
    
    // 每次移动200
    m_backTileMapHeight -= 200;
    // 图的顶部到达屏幕顶部时
    if (m_backSkyHeight <= screenSize.height) {
        if (!m_isBackSkyReload) {
            
            // 如果另一张图还没加载则create一个
            m_backSkyRe =[CCSprite spriteWithFile:@"bg01.jpg"];
            [m_backSkyRe setAnchorPoint:ccp(0,0)];
            [self addChild:m_backSkyRe z:-10];
            [m_backSkyRe setPosition:ccp(0,screenSize.height)];            
            // 反转标志位
            m_isBackSkyReload = true;
        }
        // 第二张图紧接着第一张图滚动
        [m_backSkyRe runAction:[CCMoveBy actionWithDuration:3 position:ccp(0,-48)]];
    }
    
    // 第一张图完全经过屏幕
    if (m_backSkyHeight <= 0) {
        m_backSkyHeight = m_backSky.contentSize.height;
        // 移除第一张的精灵
        [self removeChild:m_backSky cleanup:true];        
        // 指向第二张图的精灵
        m_backSky = m_backSkyRe;
        
        // 第二张的精灵指针置空
        m_backSkyRe = nil;
        
        // 反转标志位
        m_isBackSkyReload = false;
    }
    
    if (m_backTileMapHeight <= screenSize.height) {
        if (!m_isBackTileReload) {
            m_backTileMapRe = [CCTMXTiledMap tiledMapWithTMXFile:@"level01.tmx"];
            [self addChild:m_backTileMapRe z:-9];
            [m_backTileMapRe setPosition:ccp(0,screenSize.height)];
            m_isBackTileReload = true;
        }
        [m_backTileMapRe runAction:[CCMoveBy actionWithDuration:3 position:ccp(0,-200)]];
    }
    
    if (m_backTileMapHeight <= 0) {
        m_backTileMapHeight = m_backTileMap.mapSize.height*m_backTileMap.tileSize.height;
        [self removeChild:m_backTileMap cleanup:true];
        m_backTileMap = m_backTileMapRe;
        m_backTileMapRe = nil;
        m_isBackTileReload = false;
    }
}



-(void) initPlayer{
    player =[Xplayer createIn:self];
    [player setPosition:CGPointMake(screenSize.width/2,0)];
    CCCallFuncN *call = [CCCallFuncN actionWithTarget:self selector:@selector(startScheduleForCollision)];
    CCBlink *bl = [CCBlink actionWithDuration:2 blinks:5];
    [player runAction:[CCSequence actions:bl, call,nil]];
}

#pragma -
#pragma mark voiceDelegate
-(void) checkForVoiceBomb:(ccTime)delta
{
    AudioQueueLevelMeterState *levels = [listener levels];
    
    Float32 peak = levels[0].mPeakPower;
    
    Float32 average = levels[0].mAveragePower;
    
    if (![listener isListening]) // If listener has paused or stopped…
        
        return; // …bail.
    
    pv_averagePower.progress=average;
    
    pv_peakPower.progress=peak;
    if(peak>=1){
        for(int i =0,len=[spiders count];i<len;i++)
        {
            CCSprite *curSpider =[spiders objectAtIndex:i];
            if ([curSpider numberOfRunningActions] == 0)
            {
                // This spider isn't even moving so we can skip checking it.
                continue;
            }
            CCParticleSystem *emitter_=[CCParticleSystemQuad particleWithFile:@"ExplodingRing.plist"];
            [self addChild:emitter_ z:10];
            
            
            Effect *effect = [Effect create];
            [effect explode:self at:curSpider.position];

            [self removeChild:curSpider cleanup:YES];
            [spiders removeObject:curSpider];
            
            CCSprite* tempSpider = [CCSprite spriteWithFile:@"balls.png"];
            CGSize size = [tempSpider texture].contentSize;
            tempSpider.position = CGPointMake(size.width*i +size.width*0.5f, screenSize.height +size.height);
            [self addChild:tempSpider z:0 tag:2];
            [spiders addObject:tempSpider];
            
        }
        //            [spiders removeAllObjects];
        
        //        [self initSpiders];
    }

}

#pragma mark spider
-(void) initSpiders
{
    CCSprite* tempSpider = [CCSprite spriteWithFile:@"balls.png"];
    float imageWidth = [tempSpider texture].contentSize.width;
    int numSpiders = screenSize.width / imageWidth;

    spiders = [[CCArray alloc] initWithCapacity:numSpiders];
    for (int i = 0; i < numSpiders; i++)
    {
        CCSprite* spider = [CCSprite spriteWithFile:@"balls.png"];
        [self addChild:spider z:0 tag:2];
        // Also add the spider to the spiders array.
        [spiders addObject:spider];
    }
    // call the method to reposition all spiders
    [self resetSpiders];
    impactDistanceSquared = imageWidth/2 * imageWidth/2;
}

-(void) resetSpiders
{
    CCSprite* tempSpider = [spiders lastObject];
    CGSize size = [tempSpider texture].contentSize;
    int numSpiders = [spiders count];
    for (int i = 0; i < numSpiders; i++)
    {
        CCSprite *spider = [spiders objectAtIndex:i];
        spider.position = CGPointMake(size.width*i +size.width*0.5f, screenSize.height +size.height);
        [spider stopAllActions];
    }
    [self unschedule:@selector(spidersUpdate:)];
    [self schedule:@selector(spidersUpdate:) interval:0.7f];
    numSpidersMoved = 0;
    spiderMoveDuration = 1.0f;
}

-(void) spidersUpdate:(ccTime)delta
{
    for (int i = 0; i < 10; i++)
    {
        int randomSpiderIndex = CCRANDOM_0_1() * [spiders count];
        CCSprite* spider = [spiders objectAtIndex:randomSpiderIndex];
        
        if ([spider numberOfRunningActions] == 0)
        {
            
            [self runSpiderMoveSequence:spider];
            break;
        }
    }
}

-(void) runSpiderMoveSequence:(CCSprite*)spider {
    
    numSpidersMoved++;
    if (numSpidersMoved % 4 == 0 && spiderMoveDuration > 2.0f) {
        spiderMoveDuration -= 0.1f;
    }

// TODO 降低难度
//    CGPoint belowScreenPosition = player?player.position:CGPointMake(spider.position.x,
//    -[spider texture].contentSize.height);
    CGPoint belowScreenPosition = CGPointMake(spider.position.x, -[spider texture].contentSize.height);

    CCMoveTo* move = [CCMoveTo actionWithDuration:spiderMoveDuration
                                         position:belowScreenPosition];
    CCCallFuncN* callDidDrop = [CCCallFuncN actionWithTarget:self selector:@selector(spiderDidDrop:)];
    CCSequence* sequence = [CCSequence actions:move, callDidDrop, nil];
    [spider runAction:sequence];
}

-(void) spiderDidDrop:(id)sender
{
    // Make sure sender is actually of the right class.
    NSAssert([sender isKindOfClass:[CCSprite class]], @"sender is not a CCSprite!");
    CCSprite* spider = (CCSprite*)sender;
    // move the spider back up outside the top of the screen
    CGPoint pos = spider.position;
    pos.y = screenSize.height + [spider texture].contentSize.height;
    spider.position = pos;
}
#pragma -
#pragma mark touch Event

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [self convertTouchToNodeSpace:[touches anyObject]];
    
//    CGSize size = [[CCDirector sharedDirector] winSize];
    CGPoint center = player.position;
    
    float angle = (float)M_PI/2 - atanf((location.y - center.y) / (location.x - center.x));
    if(location.x < center.x)
    {
        angle = (float)M_PI + angle;
    }
    
    [self shoot:angle];

}
//- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *) event
//{
//    CGPoint location = [self convertTouchToNodeSpace:[touches anyObject]];
//    
//    CGSize size = [[CCDirector sharedDirector] winSize];
//    CGPoint center = ccp(size.width/2, size.height/2);
//    
//    float angle = (float)M_PI/2 - atanf((location.y - center.y) / (location.x - center.x));
//    if(location.x < center.x)
//    {
//        angle = (float)M_PI + angle;
//    }
//    
//    [self pointTo:angle];
//}

#pragma -
#pragma shootAction
- (void) pointTo:(float) angleInRadians
{
	player.rotation = CC_RADIANS_TO_DEGREES(angleInRadians);
    for (CCNode *bullet in bullets) {
        bullet.rotation =CC_RADIANS_TO_DEGREES(angleInRadians);
    }
}
- (void) shoot:(float) angleInRadians
{
	
//	CGSize size = [[CCDirector sharedDirector] winSize];
	CGPoint center = player.position;
	
	CGPoint initialPoint = ccp(center.x + sinf(angleInRadians)*50.0f,
							   center.y + cosf(angleInRadians)*50.0f);
	CGPoint endPoint = ccp(center.x + sinf(angleInRadians)*600.0f,
						   center.y + cosf(angleInRadians)*600.0f);
	
	CCSprite* bullet = [CCSprite spriteWithFile:@"bullet.png"];
//	bullet.scale = 0.3f;
	bullet.position = initialPoint;
	[self addChild:bullet];
	[bullets addObject:bullet];
	
	CCActionInterval* action = [CCSequence actions:
								[CCMoveTo actionWithDuration:1.0f position:endPoint],
								[CCCallFuncN actionWithTarget:self selector:@selector(removeBullet:)],
								nil];
	[bullet runAction:action];
    [self pointTo:angleInRadians];
//	[[OALSimpleAudio sharedInstance] playEffect:SHOOT_SOUND];
}
-(void) removeBullet:(CCNode*) bullet
{
	[bullets removeObject:bullet];
	[self removeChild:bullet cleanup:YES];
}
- (void) removeSpider:(CCNode*) spider
{
    int removeIndex=[spiders indexOfObject:spider];
	[spiders removeObject:spider];
	[self removeChild:spider cleanup:YES];
    CCSprite* tempSpider = [CCSprite spriteWithFile:@"balls.png"];
    CGSize size = [tempSpider texture].contentSize;

    tempSpider.position = CGPointMake(size.width*removeIndex +size.width*0.5f, screenSize.height +size.height);
    [self addChild:tempSpider z:0 tag:2];
    [spiders addObject:tempSpider];
}

#pragma -
-(bool)collide:(UnitSprite*)a and:(UnitSprite*)b
{
    if(!a || !b)
    {
        return false;
    }
    CGRect aRect = [a collideRect];
    CGRect bRect = [b collideRect];
   if (CGRectIntersectsRect(aRect,bRect)) {
        return true;
    }
    return false;
}

-(void)checkIsCollide
{
    NSMutableArray *eneArray = enemy_items;
    for(SpiderEnemy* enemy in eneArray)
    {
        if([self collide:enemy and:player]){
            if (player) {
                [enemy destroy];
                [player hurt];
            }
        }
    }
//    CCARRAY_FOREACH(enemy_items, units)
//    {
//        UnitSprite *enemy = dynamic_cast<UnitSprite*>(units);
//        CCARRAY_FOREACH(play_bullet, bullets)
//        {
//            UnitSprite *bullet = dynamic_cast<UnitSprite*>(bullets);
//            if (this->collide(enemy, bullet)) {
//                enemy->hurt();
//                bullet->hurt();
//            }
//            if (!(m_screenRec.intersectsRect(bullet->boundingBox()))) {
//                bullet->destroy();
//            }
//        }
//        if (collide(enemy, m_ship)) {
//            if (m_ship->isActive()) {
//                enemy->hurt();
//                m_ship->hurt();
//            }
//            
//        }
//        if (!(m_screenRec.intersectsRect(enemy->boundingBox()))) {
//            enemy->destroy();
//        }
//    }


}

#pragma -
-(void)checkForBulletCollision{
    CCNode* bulletToRemove = nil;
    CCNode* spiderToRemove = nil;
    
    // Naive collision detection algorithm
    for(CCNode* bullet in bullets)
    {
        for(CCNode* spider in spiders)
        {
            float xDistance = spider.position.x - bullet.position.x;
            float yDistance = spider.position.y - bullet.position.y;
            if(xDistance * xDistance + yDistance * yDistance < impactDistanceSquared)
            {
                bulletToRemove = bullet;
                spiderToRemove = spider;
                break;
            }
        }
        if(nil != bulletToRemove)
        {
            break;
        }
    }
    if(nil != bulletToRemove)
    {
        Effect *effect = [Effect create];
//        effect.scale =0.5;
        [effect sparkExplode:self at:spiderToRemove.position];
//        [effect explode:self at:spiderToRemove.position];
        totalTime +=2;//加分
        [self removeBullet:bulletToRemove];
        [self removeSpider:spiderToRemove];
    }
    
}
-(void) startScheduleForCollision{
    [self schedule:@selector(checkForCollision) interval:1/60];
}

-(void) checkForCollision
{
    // Assumption: both player and spider images are squares.
    float playerImageSize = [player texture].contentSize.width;
    float spiderImageSize = [[spiders lastObject] texture].contentSize.width;
    float playerCollisionRadius = playerImageSize * 0.4f;
    float spiderCollisionRadius = spiderImageSize * 0.4f;
    // This collision distance will roughly equal the image shapes.
    float maxCollisionDistance = playerCollisionRadius + spiderCollisionRadius;
    int numSpiders = [spiders count];
    for (int i = 0; i < numSpiders; i++)
    {
        CCSprite* spider = [spiders objectAtIndex:i];
        if ([spider numberOfRunningActions] == 0)
        {
            // This spider isn't even moving so we can skip checking it.
            continue;
        }
        // Get the distance between player and spider.
        float actualDistance = ccpDistance(player.position, spider.position);
        // Are the two objects closer than allowed?
        if (actualDistance < maxCollisionDistance)
        {
            [self unschedule:@selector(checkForCollision)];

            // Game Over (just restart the game for now)
//            [self resetSpiders];
            [player destroy];
            player =nil;
            playerlife-=1;
            [lifeLabel setString:[NSString stringWithFormat:@"%i",playerlife]];
            [self unscheduleUpdate];
            if(playerlife<=0){  //游戏结束
                self.isTouchEnabled =NO;
                //下面的可以删去
                [self unschedule:@selector(spidersUpdate:)];
                CCLabelTTF* endingText = [CCLabelTTF labelWithString:@"YOU LOSE" fontName:@"Marker Felt" fontSize:40];
                endingText.position = CGPointMake(screenSize.width/2,screenSize.height/2);
                [self addChild:endingText z:30 tag:59];
                
                // Standard method to create a button
//                CCMenuItem *starMenuItem =[CCMenuItemImage itemWithNormalImage:@"ButtonPlus.png" selectedImage:@"ButtonPlus.png" target:self selector:@selector(restartGame:)];
//                starMenuItem.position = ccp(60, 60);
//                CCMenu *starMenu = [CCMenu menuWithItems:starMenuItem, nil];
//                starMenu.position = CGPointZero;
//                [self addChild:starMenu z:60 tag:60];
                
                CCDelayTime *delayTime =[CCDelayTime actionWithDuration:1];
                CCCallFuncN* callFunc = [CCCallFuncN actionWithTarget:self selector:@selector(gameOver)];
                CCSequence* sequence = [CCSequence actions:delayTime,callFunc, nil];
                [self runAction:sequence];
                
            }else{
                self.isTouchEnabled =NO;
                [self performSelector:@selector(resetGame) withObject:nil afterDelay:0.5];
            }
            
            //停止敌人运动
//            int numSpiders = [spiders count];
//            for (int i = 0; i < numSpiders; i++)
//            {
//                CCSprite *spider = [spiders objectAtIndex:i];
//                [spider stopAllActions];
//            }
//            [self unschedule:@selector(spidersUpdate:)];

            break;
        }
    }
}
#pragma -
#pragma mark Button Event

-(void)restartGame:(id)sender
{
    [self removeChildByTag:59 cleanup:YES];  //YOU LOSE
    [self removeChildByTag:60 cleanup:YES]; // BUTTON
    playerlife = 3 ;
    [lifeLabel setString:[NSString stringWithFormat:@"%i",playerlife]];
    [self resetSpiders];
    [self resetGame];
}
//-(void)startShoot
//{
//    
//}
-(void) gameOver
{
    [[[CCDirector sharedDirector].view viewWithTag:3] removeFromSuperview];
    [[[CCDirector sharedDirector].view viewWithTag:2] removeFromSuperview];

    CCScene * scene = [GameOverScene scene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.2 scene:scene]];
}
#pragma -
-(void)resetGame{
//    totalTime = 0;
//    score= 0;
    [self initPlayer];
    self.isTouchEnabled =YES;
//    [scoreLable setString:@"0"];
    [self scheduleUpdate];
}
#pragma mark
-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    float deceleration = 0.4f;
    float sensitivity = 6.0f;
    // how fast the velocity can be at most
    float maxVelocity = 100;
    playerVelocity.x = playerVelocity.x * deceleration + acceleration.x * sensitivity;
    if (playerVelocity.x > maxVelocity)
    {
        playerVelocity.x = maxVelocity;
    }
    else if (playerVelocity.x < - maxVelocity)
    {
        playerVelocity.x = - maxVelocity;
    }
}

#pragma -
#pragma mark Enemy
-(void) addEnemyToGameLayer
{
    int m_index = arc4random()%6;
    SpiderEnemy * enemy = [SpiderEnemy create:EnemyUnit[m_index]];
    
    CGPoint enemyPos = ccp( 80 + (screenSize.width - 160) * CCRANDOM_0_1(), screenSize.height);
    CGSize eSize = enemy.contentSize;
    [enemy setPosition:enemyPos];
    
    CGPoint offset; 
    CCAction *tempAction;
    CCMoveBy *a0;
    CCMoveBy *a1;
    CCCallFuncN *onComplete;
    
    switch ([enemy getMoveType]) {
        case 0:
            
            if (player) {
                offset = player.position;
            }else{
                offset = ccp(screenSize.width / 2, 0);
            }
            tempAction =[CCMoveTo actionWithDuration:1 position:offset];
            break;
            
        case 1:
            offset = ccp( 0,-screenSize.height -eSize.height);
            tempAction = [CCMoveBy actionWithDuration:4 position:offset];
            break;
            
        case 2:
            offset = ccp(0, -100 - 200 * CCRANDOM_0_1());
            a0 = [CCMoveBy actionWithDuration:0.5 position:offset];
            a1 = [CCMoveBy actionWithDuration:1 position:ccp(-50-100*CCRANDOM_0_1(), 0)];
            onComplete = [CCCallFuncN actionWithTarget:self selector:@selector(repeatAction:)];
            tempAction =  [CCSequence actions:a0,a1,onComplete, nil];
            break;
        case 3:
        {
            int newX =((enemyPos.x <= screenSize.width / 2 ) ? 320 : - 320);
            a0 =[CCMoveBy actionWithDuration:4 position:ccp(newX, -240)];
            a1=[CCMoveBy actionWithDuration:4 position:ccp(-newX,-320)];
            tempAction =[CCSequence actions:a0,a1, nil];
            break;
        }
    }
    
    [self addChild:enemy z:enemy.zOrder tag:1000];
    [enemy runAction:tempAction];
    [enemy_items addObject:enemy];
//    enemy_items->addObject(enemy);
}

-(void)repeatAction:(CCNode *)pSender
{
    CCDelayTime *delay = [CCDelayTime actionWithDuration:1];
    CCMoveBy *mv =[CCMoveBy actionWithDuration:1 position:ccp(100+100*CCRANDOM_0_1(),0)];
    CCFiniteTimeAction *seq =[CCSequence actions:delay,mv,delay,mv, nil];
    [pSender runAction:[CCRepeatForever actionWithAction:(CCActionInterval*)seq]];
}
- (void) update:(ccTime)delta
{
    totalTime += delta;
    int currentTime = (int)totalTime;
    if([Config sharedConfig].scoreValue < currentTime){
        [Config sharedConfig].scoreValue = currentTime;
        [scoreLable setString:[NSString stringWithFormat:@"%i",[Config sharedConfig].scoreValue]];
    }
    
    CGPoint pos = player.position;
    pos.x += playerVelocity.x;
    float imageWidthHalved = [player texture].contentSize.width * 0.5f;
    float leftBorderLimit = imageWidthHalved;
    float rightBorderLimit = screenSize.width - imageWidthHalved;
    if (pos.x < leftBorderLimit)
    {
        pos.x = leftBorderLimit;
        playerVelocity = CGPointZero;
    }
    else if (pos.x > rightBorderLimit)
    {
        pos.x = rightBorderLimit;
        playerVelocity = CGPointZero;
    }
    [player setPosition:pos];
    [self checkIsCollide];
    [self checkForBulletCollision];
//    [self checkForCollision];
}
-(void) dealloc
{
//    [spiders release];
    [bullets release];
    spiders = nil;
    [super dealloc];
}

@end
