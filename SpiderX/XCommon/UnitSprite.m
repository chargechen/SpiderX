//
//  UnitSprite.m
//  SpiderX
//
//  Created by 陈 卓权 on 13-4-16.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "UnitSprite.h"


@implementation UnitSprite
-(void)destroy
{
}
-(void) hurt
{
}
-(CGRect) collideRect
{
    CGSize size = self.contentSize;
    CGPoint pos =self.position;
    return CGRectMake(pos.x-size.width/2, pos.y - size.height / 4, size.width, size.height / 2);
}
-(bool) isActive
{
    return NO;
}
@end
