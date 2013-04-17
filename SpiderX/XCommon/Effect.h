//
//  Effect.h
//  SpiderX
//
//  Created by Charge on 13-4-9.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Effect : CCNode {
}
+(id)create;
+(void)sharedExplosion;
-(void)explode:(CCNode*)parent at:(CGPoint)pos;
-(void)sparkExplode:(CCNode*)parent at:(CGPoint)pos;
-(void) spark:(CGPoint) pos parent:(CCNode *)parent scale:(float) scale duration:(float) duration;
-(void)killSprite:(id)p;
@end
