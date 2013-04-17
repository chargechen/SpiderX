//
//  UnitSprite.h
//  SpiderX
//
//  Created by 陈 卓权 on 13-4-16.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface UnitSprite : CCSprite {
    
}
-(void)destroy;
-(void) hurt;
-(CGRect) collideRect;
-(bool) isActive;
@end
