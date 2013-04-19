//
//  Effect.m
//  SpiderX
//
//  Created by Charge on 13-4-9.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "Effect.h"


@implementation Effect
+(id)create
{
    return [[[self alloc] init] autorelease];
}
-(void)explode:(CCNode *)parent at:(CGPoint)pos
{
    CCParticleExplosion *effect =[CCParticleExplosion node];
    effect.autoRemoveOnFinish =YES;
    effect.position =pos;
    effect.scale =self.scale;
    [parent addChild:effect z:200];
    
}
-(void)sparkExplode:(CCNode *)parent at:(CGPoint)pos
{
    // 第一帧
    CCSpriteFrame *pFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"explosion_01.png"];
    CCSprite *explosion=[CCSprite spriteWithSpriteFrame:pFrame];
    [parent addChild:explosion];
    [explosion setPosition:pos];
//    CGSize cs =explosion.contentSize;
    CCCallFuncN *removeFunc = [CCCallFuncN actionWithTarget:self selector:@selector(killSprite:)];
    CCAnimation *animation =[[CCAnimationCache sharedAnimationCache]animationByName:@"Explosion"];
    [explosion runAction:[CCSequence actions:[CCAnimate actionWithAnimation: animation],removeFunc,nil]];
   
    [self spark:pos parent:parent scale:1.2 duration:0.7];
}
-(CCParticleFire*)fire:(CCNode*)parent at:(CGPoint)pos
{
    CCParticleFire *effect =[CCParticleFire node];
//    effect.startSize=10;
//    effect.EmissionRate= 60;
    effect.life=0.5;
    effect.position =pos;
    effect.scale =self.scale;
    [parent addChild:effect z:200];
    return effect;
}
//动画加入缓存
+(void)sharedExplosion
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"explosion.plist"];
    
    CCArray *animFrames = [CCArray array];
        
    for (int i = 1; i < 35; ++i) {
        CCSpriteFrame *frame =[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"explosion_%02d.png",i]];
        [animFrames addObject:frame];
    }
    
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:(NSArray*)animFrames delay:0.04];
    [[CCAnimationCache sharedAnimationCache] addAnimation:animation name:@"Explosion"];
    // 帧动画命名    
}

// 闪光动画
-(void) spark:(CGPoint) pos parent:(CCNode *)parent scale:(float) scale duration:(float) duration
{
    // spark 精灵
    CCSprite *one = [CCSprite spriteWithFile:@"explode1.jpg"];
    CCSprite *two = [CCSprite spriteWithFile:@"explode2.jpg"];
    CCSprite *three = [CCSprite spriteWithFile:@"explode3.jpg"];
    
    // 混合模式
    ccBlendFunc cb = { GL_SRC_ALPHA, GL_ONE };
    [one setBlendFunc:cb];
    [two setBlendFunc:cb];
    [three setBlendFunc:cb];

    [one setPosition:pos];
    [two setPosition:pos];
    [three setPosition:pos];
    [parent addChild:one];
    [parent addChild:two];
    [parent addChild:three];

    [one setScale:scale];
    [two setScale:scale];
    [three setScale:scale];

    [three setRotation:(CCRANDOM_0_1()*360)];
    
    CCRotateBy *left = [CCRotateBy actionWithDuration:duration angle:-45];
    CCRotateBy *right = [CCRotateBy actionWithDuration:duration angle:45];
    CCScaleBy *scaleBy = [CCScaleBy actionWithDuration:duration scale:3];
    CCFadeOut *fadeOut = [CCFadeOut actionWithDuration:duration];
    
    CCCallFuncN *removeFunc1 = [CCCallFuncN actionWithTarget:self selector:@selector(killSprite:)];
    CCCallFuncN *removeFunc2 = [CCCallFuncN actionWithTarget:self selector:@selector(killSprite:)];
    CCCallFuncN *removeFunc3 = [CCCallFuncN actionWithTarget:self selector:@selector(killSprite:)];
    CCSequence *seqOne =[CCSequence actions:fadeOut,removeFunc1,nil];
    CCSequence *seqTwo =[CCSequence actions:fadeOut,removeFunc2,nil];
    CCSequence *seqThree =[CCSequence actions:fadeOut,removeFunc3,nil];
    [one runAction:left];
    [two runAction:right];

    [one runAction:scaleBy];
    [two runAction:scaleBy];
    [three runAction:scaleBy];
   
    [one runAction:seqOne];
    [two runAction:seqTwo];
    [three runAction:seqThree];

}


-(void)killSprite:(id)p
{
    NSAssert([p isKindOfClass:[CCSprite class]], @"sender is not a CCSprite!");
    CCSprite* curSprite = (CCSprite*)p;

    [curSprite removeFromParentAndCleanup:YES];
    curSprite =nil;
}
@end
