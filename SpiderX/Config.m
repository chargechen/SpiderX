//
//  Config.m
//  SpiderX
//
//  Created by 陈 卓权 on 13-4-10.
//
//

#import "Config.h"
static Config* g_config=nil;

@implementation Config
@synthesize scoreValue;
+(Config *)sharedConfig
{
    if (g_config == nil) {
        g_config = [[Config alloc] init];
    }
    return g_config;
}

@end
