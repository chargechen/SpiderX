//
//  GameScene.h
//  SpiderX
//
//  Created by 陈 卓权 on 13-3-24.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SCListener.h"
#import "Xplayer.h"
@interface GameScene : CCLayer {
    Xplayer *player;
//    CCMotionStreak *playerStreak;
    CGPoint playerVelocity;
    
    CCArray* spiders;
    float spiderMoveDuration;
    int numSpidersMoved;
    CCLabelAtlas *scoreLable;
    CCLabelAtlas *lifeLabel;
    ccTime totalTime;
    int playerlife;
    
    CCArray *bullets;
    float impactDistanceSquared;
    
    CCSprite * m_backSky;
    float m_backSkyHeight;
    CCSprite *m_backSkyRe;
    CCTMXTiledMap *m_backTileMap;
    float m_backTileMapHeight;
    CCTMXTiledMap *m_backTileMapRe;
    bool m_isBackSkyReload;
    bool m_isBackTileReload;
}
@property (nonatomic,strong) SCListener *listener;
@property (nonatomic,strong) UIProgressView *pv_averagePower;

@property (nonatomic,strong) UIProgressView *pv_peakPower;
+(id) scene;

@end
