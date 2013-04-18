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
        playerStreak= [CCMotionStreak streakWithFade:0.5 minSeg:0.2 width:texture.contentSize.height color:ccc3(255,255,255) textureFilename:@"streak.png"];
        
        CCActionInterval *colorAction = [CCRepeatForever actionWithAction:[CCSequence actions:
                                                                           [CCTintTo actionWithDuration:0.2f red:255 green:0 blue:0],
                                                                           [CCTintTo actionWithDuration:0.2f red:0 green:255 blue:0],
                                                                           [CCTintTo actionWithDuration:0.2f red:0 green:0 blue:255],
                                                                           [CCTintTo actionWithDuration:0.2f red:0 green:255 blue:255],
                                                                           [CCTintTo actionWithDuration:0.2f red:255 green:255 blue:0],
                                                                           [CCTintTo actionWithDuration:0.2f red:255 green:0 blue:255],
                                                                           [CCTintTo actionWithDuration:0.2f red:255 green:255 blue:255],nil
                                                                           ]
                                         ];
        [playerStreak runAction:colorAction];
        
        [parent addChild:self z:1 tag:1];
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

@end
