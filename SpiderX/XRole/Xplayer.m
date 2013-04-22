//
//  Xplayer.m
//  SpiderX
//
//  Created by Charge on 13-4-4.
//
//

#import "Xplayer.h"
#import "Effect.h"
#import "Config.h"
#import "Xbullet.h"
#define ORIGIN_HP 10
@implementation Xplayer
+(id) createIn:(CCNode *)parent {
    return [[[self alloc] initPlayer:parent] autorelease];
}

-(id) initPlayer:(CCNode*)parent{
    CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage: @"ship.png"];
    if((self =  [super initWithTexture:texture])){
        playerStreak= [CCMotionStreak streakWithFade:0.2 minSeg:0.1 width:texture.contentSize.height color:ccc3(255,255,255) textureFilename:@"ship.png"];
        
//        CCActionInterval *colorAction = [CCRepeatForever actionWithAction:[CCSequence actions:
//                                                                           [CCTintTo actionWithDuration:0.2f red:255 green:0 blue:0],
//                                                                           [CCTintTo actionWithDuration:0.2f red:0 green:255 blue:0],
//                                                                           [CCTintTo actionWithDuration:0.2f red:0 green:0 blue:255],
//                                                                           [CCTintTo actionWithDuration:0.2f red:0 green:255 blue:255],
//                                                                           [CCTintTo actionWithDuration:0.2f red:255 green:255 blue:0],
//                                                                           [CCTintTo actionWithDuration:0.2f red:255 green:0 blue:255],
//                                                                           [CCTintTo actionWithDuration:0.2f red:255 green:255 blue:255],nil
//                                                                           ]
//                                         ];
//        [playerStreak runAction:colorAction];
        
        [parent addChild:self z:1 tag:1];
        [parent addChild:playerStreak z:0 tag:2];
        [self setPosition:CGPointMake([[CCDirector sharedDirector] winSize].width/2,texture.contentSize.height/2)];
        [playerStreak setPosition:self.position];
        
        m_active =true;
        m_HP = ORIGIN_HP;
        
        if( [Config sharedConfig].controlType ==GESTURE_CONTROL){
            [self schedule:@selector(shoot) interval:0.2];
            
        }
        
    }
    return self;
}

-(void) destroy
{
    Effect *effect = [Effect create];
    [effect sparkExplode:self.parent at:self.position];
    [playerStreak removeFromParentAndCleanup:YES];
    [self removeFromParentAndCleanup:YES];
    playerStreak = nil;
    self = nil;
}

-(void)setPosition:(CGPoint)position
{
    [super setPosition:position];
    playerStreak.position = position;
}
-(void)update:(float)dt
{
    if (m_HP <= 0) {
        m_active = false;
    }
}
-(bool)isActive
{
    return m_active;
}
-(void)hurt
{
    m_HP --;
    [super hurt];
}
-(void)shoot
{
    CGPoint pos =self.position;
	
	CGPoint initialPoint = ccp(pos.x,pos.y+self.contentSize.height);
	CGPoint endPoint = ccp(pos.x,pos.y+600);
	
	Xbullet* bullet = [Xbullet createWithFile:@"bullet.png"];
    //	bullet.scale = 0.3f;
	bullet.position = initialPoint;
	[self.parent addChild:bullet];
    
    [bullets addObject:bullet];
	
	[bullet runAction:[CCMoveTo actionWithDuration:1.0f position:endPoint]];
}

-(int)getHp
{
    return m_HP;
}
@end
