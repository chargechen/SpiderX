//
//  Config.h
//  SpiderX
//
//  Created by 陈 卓权 on 13-4-10.
//
//

#import <Foundation/Foundation.h>
NSMutableArray *enemy_items;
NSMutableArray *enemy_bullet;
NSMutableArray *play_bullet;
@interface Config : NSObject
{
    int m_scoreValue;
}
@property(nonatomic,assign)int scoreValue;
+(Config *)sharedConfig;

@end
