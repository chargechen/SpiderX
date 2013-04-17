//
//  Xbullet.m
//  SpiderX
//
//  Created by 陈 卓权 on 13-4-17.
//
//

#import "Xbullet.h"

@implementation Xbullet
+(id)create
{
    return [[[self alloc] initBullet] autorelease];
}

-(id)initBullet
{
    if((self =[super initWithFile:@"bullet.png"]))
    {
        
    }
    return self;
}

-(void)destroy
{
    [self removeFromParentAndCleanup:YES];
}
@end
