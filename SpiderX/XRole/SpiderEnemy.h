//
//  SpiderEnemy.h
//  SpiderX
//
//  Created by 陈 卓权 on 13-4-15.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "UnitSprite.h"
typedef struct {
    int type;
    NSString* textureName;
    NSString* bulletType;
    int hp;
    int moveType;
    int scoreValue;
}EnemyType;
extern EnemyType EnemyUnit[];
@interface SpiderEnemy :UnitSprite {
}
+(void) sharedEnemy;
+(id)create:(EnemyType)type;
-(id)enemyInit:(EnemyType)type;
-(void)update:(float) dt;
-(void)shoot;
-(void)hurt ;
-(void)destroy;
-(bool)isActive;
-(int)getMoveType;
@end
