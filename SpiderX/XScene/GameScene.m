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
    CGRect m_screenRec;
    CONTROL_TYPE controlType;
}
@end
@implementation GameScene
@synthesize listener;
@synthesize pv_averagePower;
@synthesize pv_peakPower;
@synthesize hp_Power;
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
        m_screenRec =CGRectMake(0, 0, screenSize.width, screenSize.height+10);
        
        enemy_items = [[NSMutableArray alloc]init];
        enemy_bullet =[[NSMutableArray alloc]init];
        
        bullets = [[CCArray alloc] initWithCapacity:bulletCount];
        _totalTime =0;
        [Config sharedConfig].scoreValue =0;
        controlType=[Config sharedConfig].controlType;
        
        playerlife = 3;
                
        [Effect sharedExplosion];
        [SpiderEnemy sharedEnemy];
        
        //语音相关
//        pv_averagePower = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
//        pv_averagePower.frame = CGRectMake(2, 46, 51, 103);
//        pv_averagePower.tag=2;
        
        pv_peakPower = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        pv_peakPower.frame = CGRectMake(2, 146, 51, 103);
        pv_peakPower.tag=3;
        
//        [[CCDirector sharedDirector].view addSubview:pv_averagePower];
        [[CCDirector sharedDirector].view addSubview:pv_peakPower];
        
        __unsafe_unretained GameScene *selfCtl = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[SCListener sharedListener] listen];
            selfCtl.listener = [SCListener sharedListener];
            [selfCtl schedule:@selector(checkForVoiceBomb:) interval:0.1];
        });
        
        self.isAccelerometerEnabled = YES; //允许对重力的感应
         hp_Power =[[PDColoredProgressView alloc] initWithProgressViewStyle: UIProgressViewStyleDefault];
        hp_Power.tag = 4;
        [hp_Power setTintColor:[UIColor greenColor]];
        [[CCDirector sharedDirector].view addSubview:hp_Power];
        [self initPlayer];
        
        if(controlType==2){ //JoystickMode
            [self addFireButton];
            [self addJoystick];
        }
     
        [self addTouchDelegate:controlType];
        
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
#pragma mark
#pragma mark addJoystick
-(void) addFireButton
{    
	fireButton = [SneakyButton button];
	fireButton.isHoldable = YES;
	
	SneakyButtonSkinnedBase* skinFireButton = [SneakyButtonSkinnedBase skinnedButton];
	skinFireButton.defaultSprite = [CCSprite spriteWithFile:@"bullet.png"];
	skinFireButton.pressSprite = [CCSprite spriteWithFile:@"e_bullet.png"];
    skinFireButton.pressSprite.rotation =180;
    skinFireButton.pressSprite.scaleY=1.5;
	skinFireButton.button = fireButton;
    
    skinFireButton.position = CGPointMake(screenSize.width-30-skinFireButton.contentSize.width/2, screenSize.height-80);
    [self addChild:skinFireButton];
}
-(void) addJoystick
{
	float stickRadius = 330;
    
	joystick = [SneakyJoystick joystickWithRect:CGRectMake(0, 0, stickRadius, stickRadius)];
	joystick.autoCenter = YES;
	
	// Now with fewer directions
	joystick.isDPad = YES;
	joystick.numberOfDirections = 8;
	
	SneakyJoystickSkinnedBase* skinStick = [SneakyJoystickSkinnedBase skinnedJoystick];
	skinStick.backgroundSprite = [CCSprite spriteWithFile:@"stone1.png"];
    skinStick.backgroundSprite.scale =0.8f;
	skinStick.backgroundSprite.color = ccMAGENTA;
	skinStick.thumbSprite = [CCSprite spriteWithFile:@"ship.png"];
//	skinStick.thumbSprite.scale = 0.6f;
    skinStick.position = CGPointMake(skinStick.contentSize.width/2+30, screenSize.height-50);
	skinStick.joystick = joystick;
	[self addChild:skinStick];
}

#pragma mark
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

#pragma mark
#pragma mark player
-(void) initPlayer{
    player =[Xplayer createIn:self];
    CCCallFuncN *call = [CCCallFuncN actionWithTarget:self selector:@selector(startScheduleForCollision)];
    CCBlink *bl = [CCBlink actionWithDuration:2 blinks:5];
    [player runAction:[CCSequence actions:bl, call,nil]];
    
    hp_Power.frame =CGRectMake((screenSize.width-player.contentSize.width*0.7)/2, screenSize.height-player.contentSize.height-8,player.contentSize.width*0.7, 5);
    hp_Power.progress =[player getHp];
}

#pragma mark
#pragma mark 检测声音大于阈值则发起大招
-(void) checkForVoiceBomb:(ccTime)delta
{
    AudioQueueLevelMeterState *levels = [listener levels];
    
    Float32 peak = levels[0].mPeakPower;
    
//    Float32 average = levels[0].mAveragePower;
    
    if (![listener isListening])
        
        return; 
    
//    pv_averagePower.progress=average;
    
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
            [self removeRock:curRock];
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
        rock.position = CGPointMake(size.width*i +size.width*0.5f, screenSize.height+size.height);
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
#pragma mark
#pragma mark touch Event

-(void)addTouchDelegate:(CONTROL_TYPE)type
{
    switch (type) {
        case GRAVITY_CONTROL:
            self.isTouchEnabled =YES;
            break;
        case JOYSTICK_CONTROL:
            break;
        case GESTURE_CONTROL:
            [[CCDirector sharedDirector].touchDispatcher addTargetedDelegate:self priority:0 swallowsTouches:YES];
            break;
        default:
            break;
    }
}
-(void)removeTouchDelegate:(CONTROL_TYPE)type
{
    switch (type) {
        case GRAVITY_CONTROL:
            self.isTouchEnabled =NO;
            break;
        case JOYSTICK_CONTROL:
            break;
        case GESTURE_CONTROL:
            [[CCDirector sharedDirector].touchDispatcher removeDelegate:self];
            break;
        default:
            break;
    }
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}
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
-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(player){
        CGPoint viewLocation =[touch locationInView: [ touch view]];
        CGPoint location = [[CCDirector sharedDirector] convertToGL:viewLocation];
        [player setPosition:location];
        hp_Power.center = ccp(viewLocation.x,viewLocation.y-player.contentSize.height/2-8);
    }
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{

}

#pragma mark
- (void) pointTo:(float) angleInRadians
{
	player.rotation = CC_RADIANS_TO_DEGREES(angleInRadians);
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
    bullet.rotation =CC_RADIANS_TO_DEGREES(angleInRadians);
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

    [self addChild:tempRock z:0 tag:2];
    tempRock.position = CGPointMake(size.width*removeIndex +size.width*0.5f, screenSize.height+size.height);

//    [rocks addObject:tempRock];
    [rocks insertObject:tempRock atIndex:removeIndex];
}

#pragma mark
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
        if (!CGRectIntersectsRect(m_screenRec,[enemy boundingBox])) {
            [enemy destroy];
            [enemy_items removeObject:enemy];
            break;
        }
    }
    
    Xbullet* bulletToRemove = nil;
    XRock* rockToRemove = nil;
//    SpiderEnemy* enemyToRemove =nil;
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
//                    enemyToRemove = enemy;
                    [enemy hurt];
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
            [Config sharedConfig].scoreValue +=  2;//加分
        }
//        if(enemyToRemove!=nil){
//            [enemyToRemove destroy];
//            [enemy_items removeObject:enemyToRemove];
//        }
        if(bulletToRemove!=nil){
            [self removeBullet:bulletToRemove];
        }
    }
    for(Xbullet *e_bullet in enemy_bullet)
    {
        if([self collide:e_bullet and:player]){
            if (player) {
                [e_bullet destroy];
                [enemy_bullet removeObject:e_bullet];
                [player hurt];
                break;
            }
            if (!CGRectIntersectsRect(m_screenRec,[e_bullet boundingBox])) {
                [e_bullet destroy];
                [enemy_bullet removeObject:e_bullet];
                break;
            }
        }
    }
}

-(void) startScheduleForCollision{
    [self schedule:@selector(checkForCollision) interval:1/60];
}

-(void) checkForCollision
{
    for(XRock *rock in rocks)
    {
        if ([rock numberOfRunningActions] == 0)
        {
            continue;   //没在动的直接忽略
        }
        if([self collide:rock and:player]){
            if (player) {
                [player hurt];
                [self removeRock:rock];
                break;
            }
        }
        if (rock.position.y<0 &&!CGRectIntersectsRect(m_screenRec, [rock boundingBox])) {
            [self removeRock:rock];
            break;
        }
    }
}
#pragma mark
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

-(void) gameOver
{
    [[[CCDirector sharedDirector].view viewWithTag:4] removeFromSuperview];
    [[[CCDirector sharedDirector].view viewWithTag:3] removeFromSuperview];
//    [[[CCDirector sharedDirector].view viewWithTag:2] removeFromSuperview];
    CCScene * scene = [GameOverScene scene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.2 scene:scene]];
}
#pragma mark
-(void)resetGame{
//    _totalTime = 0;
//    score= 0;
    [self initPlayer];
    
    hp_Power.hidden =NO;
    [self addTouchDelegate:controlType];
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
    playerVelocity.y = playerVelocity.y * deceleration + acceleration.y * sensitivity;
    if (playerVelocity.x > maxVelocity)
    {
        playerVelocity.x = maxVelocity;
    }
    else if (playerVelocity.x < - maxVelocity)
    {
        playerVelocity.x = - maxVelocity;
    }
    if(playerVelocity.y > maxVelocity)
    {
        playerVelocity.y =maxVelocity;
    }
    else if (playerVelocity.y < -maxVelocity)
    {
        playerVelocity.y = -maxVelocity;
    }
}

#pragma mark
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
            offset = ccp(0, -100 - 150 * CCRANDOM_0_1());
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
        default:
            tempAction =[CCMoveTo actionWithDuration:1 position:ccp(screenSize.width / 2, 0)];
            break;
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
//    _totalTime += delta;   //时间流逝也能得分
//    int currentTime = (int)_totalTime;
//    int preScore= [Config sharedConfig].scoreValue;
//    if(preScore < currentTime){
//        [[Config sharedConfig] setScoreValue:currentTime];
        [scoreLable setString:[NSString stringWithFormat:@"%i",[Config sharedConfig].scoreValue]];
//    }
    
    if(controlType==GRAVITY_CONTROL){
        CGPoint pos = player.position;
        pos.x += playerVelocity.x;
        pos.y += playerVelocity.y;
        
        float imageWidthHalved = [player texture].contentSize.width * 0.5f;
        float leftBorderLimit = imageWidthHalved;
        float rightBorderLimit = screenSize.width - imageWidthHalved;
        float topBorderLimit = screenSize.height -imageWidthHalved;
        float bottomLimit =  imageWidthHalved;
        if (pos.x < leftBorderLimit)
        {
            pos.x = leftBorderLimit;
            playerVelocity.x =0;
        }
        else if (pos.x > rightBorderLimit)
        {
            pos.x = rightBorderLimit;
            playerVelocity.x =0;
        }
        if(pos.y <bottomLimit)
        {
            pos.y = bottomLimit;
            playerVelocity.y=0;
        }
        else if(pos.y >topBorderLimit)
        {
            pos.y = topBorderLimit;
            playerVelocity.y=0;
        }
        [player setPosition:pos];
        hp_Power.center = CGPointMake(pos.x, screenSize.height-player.position.y- player.contentSize.height/2-8);
    }else if (controlType == JOYSTICK_CONTROL)
    {
        _totalTime += delta;
        // Continuous fire
        if (fireButton.active && _totalTime > nextShotTime)
        {
            nextShotTime = _totalTime + 0.2f;
            
            [player shoot];
        }
        
        // Allow faster shooting by quickly tapping the fire button.
        if (fireButton.active == NO)
        {
            nextShotTime = 0;
        }
        
        // Moving the ship with the thumbstick.

        
        CGPoint velocity = ccpMult(joystick.velocity,300);
        if (!(velocity.x == 0 && velocity.y == 0))
        {
            CGPoint pos = CGPointMake(player.position.x + velocity.x * delta, player.position.y + velocity.y * delta);
            if(pos.x>(screenSize.width-player.contentSize.width/2)){
                pos.x =(screenSize.width-player.contentSize.width/2);
            }else if(pos.x<player.contentSize.width/2){
                pos.x =player.contentSize.width/2;
            }
            if(pos.y>screenSize.height-player.contentSize.height/2){
                pos.y =screenSize.height-player.contentSize.height/2;
            }else if(pos.y<player.contentSize.height/2){
                pos.y=player.contentSize.height/2;
            }
            player.position =pos;
            
            hp_Power.center = CGPointMake(pos.x, screenSize.height-player.position.y- player.contentSize.height/2-8);
        }

    
    }
    [self checkIsCollide];
    [self removeSpriteUnit:delta];

}

-(void)removeSpriteUnit:(float) dt
{
    for(SpiderEnemy* enemy in enemy_items)
    {
        [enemy update:dt];
        if(![enemy isActive])
        {
            [Config sharedConfig].scoreValue += [enemy getScore];
            [enemy destroy];
            [enemy_items removeObject:enemy];
            break;
        }
    }
if(player){
    [player update:dt];
    hp_Power.progress =[player getHp]*0.1;
    if(![player isActive])
    {
        [self unschedule:@selector(checkForCollision)];
        [player destroy];
        hp_Power.hidden =YES;
        player =nil;
        playerlife-=1;
        [lifeLabel setString:[NSString stringWithFormat:@"%i",playerlife]];
        [self unscheduleUpdate];
        if(playerlife<=0){  //游戏结束
            [self removeTouchDelegate:controlType];
            
            [self unschedule:@selector(rocksUpdate:)];
            CCLabelTTF* endingText = [CCLabelTTF labelWithString:@"THE END.." fontName:@"Marker Felt" fontSize:40];
            endingText.position = CGPointMake(screenSize.width/2,screenSize.height/2);
            [self addChild:endingText z:30 tag:59];
            
            CCDelayTime *delayTime =[CCDelayTime actionWithDuration:1];
            CCCallFuncN* callFunc = [CCCallFuncN actionWithTarget:self selector:@selector(gameOver)];
            CCSequence* sequence = [CCSequence actions:delayTime,callFunc, nil];
            [self runAction:sequence];
            
        }else{
            [self removeTouchDelegate:controlType];
            [self performSelector:@selector(resetGame) withObject:nil afterDelay:0.5];
        }
        
    }
}
}
-(void) dealloc
{
    [super dealloc];
    [enemy_items release];
    [enemy_bullet release];
    [bullets release];
    [rocks release];
    enemy_items =nil;
    enemy_bullet =nil;
    bullets =nil;
    rocks = nil;
}

@end
