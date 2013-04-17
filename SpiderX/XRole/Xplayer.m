//
//  Xplayer.m
//  SpiderX
//
//  Created by Charge on 13-4-4.
//
//

#import "Xplayer.h"
#import "Effect.h"
@implementation Xplayer
+(id) create {
    return [[[self alloc] initPlayer] autorelease];
}

-(id) initPlayer{
    CGSize screenSize = [[CCDirector sharedDirector]winSize];
    CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage: @"ship.png"];
    float imageHeight = texture.contentSize.height;
    if((self =  [[super initWithTexture:texture] autorelease])){
        playerStreak= [CCMotionStreak streakWithFade:0.2 minSeg:2 width:46 color:ccc3(255,255,255) texture:texture];
        self.position =CGPointMake(screenSize.width/2, imageHeight/2);
        playerStreak.position =CGPointMake(screenSize.width/2, imageHeight/2);
        [self.parent addChild:self z:0 tag:1];
        [self.parent addChild:playerStreak z:0 tag:2];
    }
    return self;
}

-(void) destroy
{
    Effect *effect = [Effect create];
    [effect sparkExplode:self.parent at:self.position];
    
    // 敌机爆炸，从敌机数组删除
    //    enemy_items->removeObject(this);
    [self removeFromParentAndCleanup:YES];
    [playerStreak removeFromParentAndCleanup:YES];
    self = nil;
}
-(void)setPosition:(CGPoint)position
{
    self.position =position;
    playerStreak.position = position;
}

-(void)dealloc
{
    [super dealloc];
    playerStreak = nil;
}
@end
