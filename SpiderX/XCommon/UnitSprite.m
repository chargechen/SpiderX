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
-(void)hurt
{
    CCTintTo *turnRed =[CCTintTo actionWithDuration:0.2f red:255 green:0 blue:0];
    CCTintTo *turnNormal =[CCTintTo actionWithDuration:0.2f red:255 green:255 blue:255];
    CCSequence* sequence = [CCSequence actions:turnRed, turnNormal,nil];
    [self runAction:sequence];
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
