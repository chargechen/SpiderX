//
//  XRock.m
//  SpiderX
//
//  Created by 陈 卓权 on 13-4-17.
//
//

#import "XRock.h"
#import "Effect.h"
@implementation XRock
+(id)create
{
    return [[[self alloc] initRock] autorelease];
}

-(id)initRock
{
    if((self =[super initWithFile:@"stone1.png"]))
    {

    }
    return self;
}

-(void)destroy
{
//    [fire removeFromParentAndCleanup:YES];
    fire.duration =0.4;
    fire =nil;
    Effect *effect = [Effect create];
    //        effect.scale =0.5;
    [effect sparkExplode:self.parent at:self.position];
    [self removeFromParentAndCleanup:YES];
    self =nil;
}
-(void)setPosition:(CGPoint)position
{
    [super setPosition:position];
    if(fire ==nil){
        fire=[[Effect create] fire:self.parent at:position];
    }
    fire.position = position;
}
@end
