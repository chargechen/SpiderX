//
//  Xbullet.m
//  SpiderX
//
//  Created by 陈 卓权 on 13-4-17.
//
//

#import "Xbullet.h"
#import "Config.h"
#define defaultFile @"bullet.png"
@implementation Xbullet
+(id)create
{
    return [[[self alloc] initBullet:defaultFile] autorelease];
}
+(id)createWithFile:(NSString*)file
{
    return [[[self alloc] initBullet:file] autorelease];
}

-(id)initBullet:(NSString*)file
{
    if((self =[super initWithFile:file]))
    {
        
    }
    return self;
}

-(void)destroy
{
    [self removeFromParentAndCleanup:YES];
    self =nil;
}
@end
