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
#import "Xbullet.h"
#import "XRock.h"

#define bulletCount 100
#define marginLeft 10
#define MAX_VOICE 1
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
        //初始化游戏数据
        screenSize = [[CCDirector sharedDirector]winSize];
        enemy_items = [[NSMutableArray alloc]init];
        bullets = [[CCArray alloc] initWithCapacity:bulletCount];
        _totalTime =0;
        score =0;
        [Config sharedConfig].scoreValue =0;
        playerlife = 3;
        
        [Effect sharedExplosion];
        [SpiderEnemy sharedEnemy];
        
        //语音相关
        pv_averagePower = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        pv_averagePower.frame = CGRectMake(2, 46, 51, 3);
        pv_averagePower.tag=2;
        
        pv_peakPower = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        pv_peakPower.frame = CGRectMake(2, 146, 51, 103);
        pv_averagePower.tag=3;
        
        [[CCDirector sharedDirector].view addSubview:pv_averagePower];
        [[CCDirector sharedDirector].view addSubview:pv_peakPower];
        
        [[SCListener sharedListener] listen];
        self.listener = [SCListener sharedListener];
        [self schedule:@selector(checkForVoiceBomb:) interval:0.1];
        
        self.isAccelerometerEnabled = YES; //允许对重力的感应
        [self initPlayer];
        self.isTouchEnabled =YES;
        
        [self schedule:@selector(addEnemyToGameLayer) interval:1]; //每隔1秒生成1个敌人
        [self scheduleUpdate];
        [self initRocks];
        [self initBackground];
        
        //游戏里提示的label
        CCLabelTTF *yourlife = [CCLabelTTF labelWithString:@"YOUR LIVES:" fontName:@"Marker Felt" fontSize:18];
        CCLabelTTF *yourScore = [CCLabelTTF labelWithString:@"SCORE:" fontName:@"Marker Felt" fontSize:18];
        
        lifeLabel = [CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%i",playerlife] charMapFile:@"fps_images.png" itemWidth:12 itemHeight:32 startCharMap:'.'];
        scoreLable = [CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%i",0] charMapFile:@"fps_images.png" itemWidth:12 itemHeight:32 startCharMap:'.'];
        [lifeLabel setPosition:ccp(screenSize.width-lifeLabel.contentSize.width,screenSize.height-lifeLabel.contentSize.height/2)];
        [scoreLable setPosition:ccp(yourScore.contentSize.width+marginLeft,screenSize.height-scoreLable.contentSize.height/2)];
        [yourScore setPosition:ccp(yourScore.contentSize.width/2,screenSize.height-yourScore.contentSize.height/2+2)];
        [yourlife setPosition:ccp(screenSize.width-yourlife.contentSize.width/2-lifeLabel.contentSize.width-marginLeft,screenSize.height-yourlife.contentSize.height/2+2)];

        [self addChild:scoreLable z:-1];
        [self addChild:lifeLabel z:40];
        [self addChild:yourlife z:40];
        [self addChild:yourScore z:40];
        
//        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Cyber Advance.mp3" loop:YES];   //背景音乐开启后声音录入失效
    }
    return self;
}

#pragma -
#pragma mark background
// 采用两张图循环加载来实现地图的无限滚动
-(void)initBackground
{
    m_backSky =nil;
    m_backSky = [CCSprite spriteWithFile:@"bg01.jpg"];
    
    [m_backSky setAnchorPoint:ccp(0,0)];
    
    m_backSkyHeight = m_backSky.contentSize.height;
    [self addChild:m_backSky z:-10];
    
    if ([UIScreen instancesRespondToSelector:@selector(scale)])  //todo tmx文件自适应高清屏
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
// 添加点浮动的图层使背景看起来更生动
-(void)movingBackground
{
    [m_backSky runAction:[CCMoveBy actionWithDuration:3 position:ccp(0,-48)]];
    [m_backTileMap runAction:[CCMoveBy actionWithDuration:3 position:ccp(0,-200)]];    

    m_backSkyHeight -= 48;
    m_backTileMapHeight -= 200;
    
    // 图的顶部到达屏幕顶部时
    if (m_backSkyHeight <= screenSize.height) {
        if (!m_isBackSkyReload) {
            
            // 如果另一张图还没加载则create一个
            m_backSkyRe =[CCSprite spriteWithFile:@"bg01.jpg"];
            [m_backSkyRe setAnchorPoint:ccp(0,0)];
            [self addChild:m_backSkyRe z:-10];
            [m_backSkyRe setPosition:ccp(0,screenSize.height)];            
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
        m_backSkyRe = nil;
        
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

#pragma -
#pragma mark player
-(void) initPlayer{
    player =[Xplayer createIn:self];
    CCCallFuncN *call = [CCCallFuncN actionWithTarget:self selector:@selector(startScheduleForCollision)];
    CCBlink *bl = [CCBlink actionWithDuration:2 blinks:5];
    [player runAction:[CCSequence actions:bl, call,nil]];
}

#pragma -
#pragma mark 检测声音大于阈值则发起大招
-(void) checkForVoiceBomb:(ccTime)delta
{
    AudioQueueLevelMeterState *levels = [listener levels];
    
    Float32 peak = levels[0].mPeakPower;
    
    Float32 average = levels[0].mAveragePower;
    
    if (![listener isListening])
        
        return; 
    
    pv_averagePower.progress=average;
    
    pv_peakPower.progress=peak;
    if(peak>=MAX_VOICE){
        for(int i =0,len=[rocks count];i<len;i++)
        {
            XRock *curRock =[rocks objectAtIndex:i];
            if ([curRock numberOfRunningActions] == 0)
            {
                continue;
            }
            CCParticleSystem *emitter_=[CCParticleSystemQuad particleWithFile:@"ExplodingRing.plist"];
            [self addChild:emitter_ z:10];
            
            
            Effect *effect = [Effect create];
            [effect explode:self at:curRock.position];

            [self removeChild:curRock cleanup:YES];
            [rocks removeObject:curRock];
            XRock* tempRock =[XRock create];
            CGSize size = [tempRock texture].contentSize;
            tempRock.position = CGPointMake(size.width*i +size.width*0.5f, screenSize.height +size.height);
            [self addChild:tempRock z:0 tag:2];
            [rocks addObject:tempRock];
            
        }
    }

}

#pragma mark rock
-(void) initRocks
{
    XRock* tempRock = [XRock create];
    float imageWidth = [tempRock texture].contentSize.width;
    int numRocks = screenSize.width / imageWidth;

    rocks = [[CCArray alloc] initWithCapacity:numRocks];
    for (int i = 0; i < numRocks; i++)
    {
        XRock *rock = [XRock create];
        [self addChild:rock z:0 tag:2];
        [rocks addObject:rock];
    }
    [self resetRocks];
    impactDistanceSquared = imageWidth/2 * imageWidth/2;
}

-(void) resetRocks
{
    XRock* tempRock = [rocks lastObject];
    CGSize size = [tempRock texture].contentSize;
    int numRocks = [rocks count];
    for (int i = 0; i < numRocks; i++)
    {
        XRock *rock = [rocks objectAtIndex:i];
        rock.position = CGPointMake(size.width*i +size.width*0.5f, screenSize.height +size.height);
        [rock stopAllActions];
    }
    [self unschedule:@selector(rocksUpdate:)];
    [self schedule:@selector(rocksUpdate:) interval:0.7f];
    numRocksMoved = 0;
    rockMoveDuration = 1.0f;
}

-(void) rocksUpdate:(ccTime)delta
{
    for (int i = 0; i < 10; i++)
    {
        int randomRockIndex = CCRANDOM_0_1() * [rocks count];
        NSLog(@"%d",[rocks count]);
        XRock* rock = [rocks objectAtIndex:randomRockIndex];
        
        if ([rock numberOfRunningActions] == 0)
        {
            
            [self runRockMoveSequence:rock];
            break;
        }
    }
}

-(void) runRockMoveSequence:(XRock*)rock {
    
    numRocksMoved++;
    if (numRocksMoved % 4 == 0 && rockMoveDuration > 2.0f) {
        rockMoveDuration -= 0.1f;
    }

// TODO 降低难度吧？
    CGPoint belowScreenPosition = player?player.position:CGPointMake(rock.position.x,
    -[rock texture].contentSize.height);
//    CGPoint belowScreenPosition = CGPointMake(rock.position.x, -[rock texture].contentSize.height);

    CCMoveTo* move = [CCMoveTo actionWithDuration:rockMoveDuration
                                         position:belowScreenPosition];
    CCCallFuncN* callDidDrop = [CCCallFuncN actionWithTarget:self selector:@selector(rockDidDrop:)];
    CCSequence* sequence = [CCSequence actions:move, callDidDrop, nil];
    [rock runAction:sequence];
}

-(void) rockDidDrop:(id)sender
{
    NSAssert([sender isKindOfClass:[XRock class]], @"sender is not a CCSprite!");
    XRock* rock = (XRock*)sender;
    // move the rock back up outside the top of the screen
    CGPoint pos = rock.position;
    pos.y = screenSize.height + [rock texture].contentSize.height;
    rock.position = pos;
}
#pragma -
#pragma mark touch Event

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [self convertTouchToNodeSpace:[touches anyObject]];
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
- (void) pointTo:(float) angleInRadians
{
	player.rotation = CC_RADIANS_TO_DEGREES(angleInRadians);
    for (Xbullet *bullet in bullets) {
        bullet.rotation =CC_RADIANS_TO_DEGREES(angleInRadians);
    }
}
- (void) shoot:(float) angleInRadians
{
    CGPoint center = player.position;
	
	CGPoint initialPoint = ccp(center.x + sinf(angleInRadians)*50.0f,
							   center.y + cosf(angleInRadians)*50.0f);
	CGPoint endPoint = ccp(center.x + sinf(angleInRadians)*600.0f,
						   center.y + cosf(angleInRadians)*600.0f);
	
	Xbullet* bullet = [Xbullet create];
	bullet.position = initialPoint;
	[self addChild:bullet];
	[bullets addObject:bullet];
	
	CCActionInterval* action = [CCSequence actions:
								[CCMoveTo actionWithDuration:1.0f position:endPoint],
								[CCCallFuncN actionWithTarget:self selector:@selector(removeBullet:)],
								nil];
	[bullet runAction:action];
    [self pointTo:angleInRadians];
}

-(void) removeBullet:(Xbullet*) bullet
{
	[bullets removeObject:bullet];
    [bullet destroy];
}

- (void) removeRock:(XRock*) rock
{
    int removeIndex=[rocks indexOfObject:rock];
	[rocks removeObject:rock];
    [rock destroy];
    XRock *tempRock =[XRock create];
    CGSize size = [tempRock texture].contentSize;

    tempRock.position = CGPointMake(size.width*removeIndex +size.width*0.5f, screenSize.height +size.height);
    [self addChild:tempRock z:0 tag:2];
    [rocks addObject:tempRock];
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
    for(SpiderEnemy* enemy in enemy_items)
    {
        if([self collide:enemy and:player]){
            if (player) {
                [enemy destroy];
                [enemy_items removeObject:enemy];
                [player hurt];
                break;
            }
        }
    }
    
    Xbullet* bulletToRemove = nil;
    XRock* rockToRemove = nil;
    SpiderEnemy* enemyToRemove =nil;
    for(Xbullet* bullet in bullets)
    {
        for(XRock* rock in rocks)
        {
            if([self collide:bullet and:rock]){
                bulletToRemove = bullet;
                rockToRemove = rock;
                break;
            }
        }
        if(nil != rockToRemove)
        {
            break;
        }
        for(SpiderEnemy* enemy in enemy_items)
        {
                if([self collide:enemy and:bullet]){
                    bulletToRemove = bullet;
                    enemyToRemove = enemy;
                    break;
                }
         }
         if(nil != rockToRemove)
         {
            break;
         }
        
    }
    if(nil != bulletToRemove)
    {
        if(rockToRemove!=nil){
            [self removeRock:rockToRemove];
            _totalTime +=2;//加分
        }
        if(enemyToRemove!=nil){
            [enemyToRemove destroy];
            [enemy_items removeObject:enemyToRemove];
        }
        if(bulletToRemove!=nil){
            [self removeBullet:bulletToRemove];
        }
    }
    
    
//    for(Xbullet* bullet in bullets)
//    {
//        for(XRock* rock in rocks){
//            if([self collide:bullet and:rock]){
//                [self removeRock:rock];
//                [self removeBullet:bullet];
//                _totalTime +=2;//加分
//                    break;
//            }
//        }
//        
//    }
}

#pragma -
//-(void)checkForBulletCollision{
//    Xbullet* bulletToRemove = nil;
//    XRock* rockToRemove = nil;
//    
//    for(Xbullet* bullet in bullets)
//    {
//        for(XRock* rock in rocks)
//        {
//            float xDistance = rock.position.x - bullet.position.x;
//            float yDistance = rock.position.y - bullet.position.y;
//            if(xDistance * xDistance + yDistance * yDistance < impactDistanceSquared)
//            {
//                bulletToRemove = bullet;
//                rockToRemove = rock;
//                break;
//            }
//        }
//        if(nil != bulletToRemove)
//        {
//            break;
//        }
//    }
//    if(nil != bulletToRemove)
//    {
//        Effect *effect = [Effect create];
//        [effect sparkExplode:self at:rockToRemove.position];
//        _totalTime +=2;//加分
//        [self removeBullet:bulletToRemove];
//        [self removeRock:rockToRemove];
//    }
//}
-(void) startScheduleForCollision{
    [self schedule:@selector(checkForCollision) interval:1/60];
}

-(void) checkForCollision
{
    float playerImageSize = [player texture].contentSize.width;
    float rockImageSize = [[rocks lastObject] texture].contentSize.width;
    float playerCollisionRadius = playerImageSize * 0.4f;
    float rockCollisionRadius = rockImageSize * 0.4f;
    float maxCollisionDistance = playerCollisionRadius + rockCollisionRadius;
    int numRocks = [rocks count];
    for (int i = 0; i < numRocks; i++)
    {
        XRock* rock = [rocks objectAtIndex:i];
        if ([rock numberOfRunningActions] == 0)
        {
            continue;
        }
        float actualDistance = ccpDistance(player.position, rock.position);
        if (actualDistance < maxCollisionDistance)
        {
            [self unschedule:@selector(checkForCollision)];

            [player destroy];
            player =nil;
            playerlife-=1;
            [lifeLabel setString:[NSString stringWithFormat:@"%i",playerlife]];
            [self unscheduleUpdate];
            if(playerlife<=0){  //游戏结束
                self.isTouchEnabled =NO;
                
                [self unschedule:@selector(rocksUpdate:)];
                CCLabelTTF* endingText = [CCLabelTTF labelWithString:@"YOU LOSE" fontName:@"Marker Felt" fontSize:40];
                endingText.position = CGPointMake(screenSize.width/2,screenSize.height/2);
                [self addChild:endingText z:30 tag:59];
                
                CCDelayTime *delayTime =[CCDelayTime actionWithDuration:1];
                CCCallFuncN* callFunc = [CCCallFuncN actionWithTarget:self selector:@selector(gameOver)];
                CCSequence* sequence = [CCSequence actions:delayTime,callFunc, nil];
                [self runAction:sequence];
                
            }else{
                self.isTouchEnabled =NO;
                [self performSelector:@selector(resetGame) withObject:nil afterDelay:0.5];
            }
            
            //停止敌人运动
//            int numRocks = [rocks count];
//            for (int i = 0; i < numRocks; i++)
//            {
//                XRock *rock = [rocks objectAtIndex:i];
//                [rock stopAllActions];
//            }
//            [self unschedule:@selector(rocksUpdate:)];

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
    [self resetRocks];
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
    [Config sharedConfig].scoreValue =score;
    CCScene * scene = [GameOverScene scene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.2 scene:scene]];
}
#pragma -
-(void)resetGame{
//    _totalTime = 0;
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
    _totalTime += delta;
    int currentTime = (int)_totalTime;
    if(score < currentTime){
        score = currentTime;
        [scoreLable setString:[NSString stringWithFormat:@"%i",score]];
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
//    [self checkForBulletCollision];
//    [self checkForCollision];
}
-(void) dealloc
{
    [bullets release];
    bullets =nil;
    rocks = nil;
    [super dealloc];
}

@end
