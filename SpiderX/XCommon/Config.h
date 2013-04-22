//
//  Config.h
//  SpiderX
//
//  Created by 陈 卓权 on 13-4-10.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
NSMutableArray *enemy_items;
NSMutableArray *enemy_bullet;
CCArray *bullets;
typedef enum {
    JOYSTICK_CONTROL =2,   //虚拟手柄
    GESTURE_CONTROL =1,     //手势控制
    GRAVITY_CONTROL =0    //重力感应
} CONTROL_TYPE;

@interface Config : NSObject

@property(nonatomic, assign)int scoreValue;
@property(nonatomic, assign)CONTROL_TYPE controlType;
+(Config *)sharedConfig;

@end
