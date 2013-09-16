//
//  GameOverScene.h
//  SpiderX
//  结束界面
//  Created by Charge on 13-4-9.
//
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCLayer.h"

@interface GameOverScene : CCLayer<UITextFieldDelegate>
+(id) scene;
-(void)playAgain;
@end
