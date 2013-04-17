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
    if((self =[super initWithFile:@"balls.png"]))
    {
        
    }
    return self;
}

-(void)destroy
{
    Effect *effect = [Effect create];
    //        effect.scale =0.5;
    [effect sparkExplode:self.parent at:self.position];
    [self removeFromParentAndCleanup:YES];
}
@end
