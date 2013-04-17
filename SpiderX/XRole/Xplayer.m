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
+(id) createIn:(CCNode *)parent {
    return [[[self alloc] initPlayer:parent] autorelease];
}

-(id) initPlayer:(CCNode*)parent{
    CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage: @"ship.png"];
    if((self =  [super initWithTexture:texture])){
        playerStreak= [CCMotionStreak streakWithFade:0.2 minSeg:2 width:texture.contentSize.height color:ccc3(255,255,255) texture:texture];
        [self setAnchorPoint:ccp(0,0)];
        [playerStreak setAnchorPoint:ccp(0,0)];
        [parent addChild:self z:0 tag:1];
        [parent addChild:playerStreak z:0 tag:2];
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
    [super setPosition:position];
    playerStreak.position = position;
}

-(void)dealloc
{
    [super dealloc];
    playerStreak = nil;
}
@end
