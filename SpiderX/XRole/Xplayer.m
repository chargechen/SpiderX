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
        [parent addChild:self z:0 tag:1];
        [parent addChild:playerStreak z:0 tag:2];
        [self setPosition:CGPointMake([[CCDirector sharedDirector] winSize].width/2,texture.contentSize.height/2)];
        [playerStreak setPosition:self.position];
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
-(void)hurt
{
    CCBlink *blink = [CCBlink actionWithDuration:0.5 blinks:1];
    [self runAction:blink];
}
@end
