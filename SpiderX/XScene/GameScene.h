//
//  GameScene.h
//  SpiderX
//  游戏界面
//  Created by 陈 卓权 on 13-3-24.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SCListener.h"
#import "Xplayer.h"
#import "PDColoredProgressView.h"

#import "ColoredCircleSprite.h"
#import "SneakyButton.h"
#import "SneakyButtonSkinnedBase.h"
#import "SneakyJoystick.h"
#import "SneakyJoystickSkinnedBase.h"

#import "SneakyExtensions.h"
@interface GameScene : CCLayer {
    //主人公
    Xplayer *player;                
    //重力加速度
    CGPoint playerVelocity;
    
    //陨石
    CCArray* rocks;                 
    //陨石运动持续时间
    float rockMoveDuration;
    //运动的陨石数量
    int numRocksMoved;
    
    //分数面板
    CCLabelAtlas *scoreLable;       
    //生命面板
    CCLabelAtlas *lifeLabel;
    //combo面板
//    CCLabelAtlas *comboLabel;
    CCLabelBMFont *comboLabel;
    
    CCLabelTTF   *comboText;
    
    //游戏时间
    ccTime _totalTime;
    //剩余生命
    int playerlife;

    //是否进入了COMBO模式
    BOOL isComboMode;
    int comboScore;
    
    //背景地图
    CCSprite * m_backSky;
    float m_backSkyHeight;
    CCSprite *m_backSkyRe;
    CCTMXTiledMap *m_backTileMap;
    float m_backTileMapHeight;
    CCTMXTiledMap *m_backTileMapRe;
    bool m_isBackSkyReload;
    bool m_isBackTileReload;
    
    //摇杆控制器
    SneakyButton* fireButton;
	SneakyJoystick* joystick;
    ccTime nextShotTime;
    
    //大招效果
    CCParticleSystem *_emitter;
}
//声音监听器
@property (nonatomic,strong) SCListener *listener;
//音频平均能量
@property (nonatomic,strong) UIProgressView *pv_averagePower;
//音频最低能量
@property (nonatomic,strong) UIProgressView *pv_peakPower;
//生命值槽
@property (nonatomic,strong) PDColoredProgressView *hp_Power;
+(id) scene;
@end
