//
//  Xbullet.h
//  SpiderX
//  子弹
//  Created by 陈 卓权 on 13-4-17.
//
//

#import "UnitSprite.h"

@interface Xbullet : UnitSprite
{
}
+(id)create;
+(id)createWithFile:(NSString*)file;
-(id)initBullet:(NSString*)file;
@end
