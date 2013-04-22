//
//  GameStartScene.m
//  SpiderX
//
//  Created by 陈 卓权 on 13-4-22.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "GameStartScene.h"
#import "GameScene.h"
#import "Config.h"

@implementation GameStartScene
{
    CGSize screenSize;
}

+(id)scene
{
    CCScene *scene =[CCScene node];
    CCLayer *layer = [GameStartScene node];
    [scene addChild:layer];
    return scene;
}
-(void)playStart{
    [[[CCDirector sharedDirector].view viewWithTag:60] removeFromSuperview];
    [[[CCDirector sharedDirector].view viewWithTag:100]removeFromSuperview];
    CCScene * scene = [GameScene scene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.2 scene:scene]];

}
-(id)init
{
    if(self=[super init])
    {
        [Config sharedConfig].controlType =GESTURE_CONTROL; //default control mode
        screenSize = [[CCDirector sharedDirector]winSize];
  
        CCSprite *newGameNormal = [CCSprite spriteWithFile:@"menu.png" rect:CGRectMake(0, 0, 126, 33)];
        CCSprite *newGameSelected = [CCSprite spriteWithFile:@"menu.png" rect:CGRectMake(0, 33, 126, 33)];
        CCSprite *newGameDisabled = [CCSprite spriteWithFile:@"menu.png" rect:CGRectMake(0, 33*2, 126, 33)];
        
        CCMenuItemSprite *newGame =[CCMenuItemSprite itemWithNormalSprite:newGameNormal selectedSprite:newGameSelected disabledSprite:newGameDisabled target:self selector:@selector(playStart)];
        CCMenu *startMenu = [CCMenu menuWithItems:newGame, nil];
        
        [self addChild:startMenu z:1 tag:2];
        [startMenu setPosition:ccp(screenSize.width/2,screenSize.height/2)];
        
        CCMenuItemImage *btnOn =[CCMenuItemImage itemWithNormalImage:@"manual.png" selectedImage:@"manual.png"];
        CCMenuItemImage *btnOff =[CCMenuItemImage itemWithNormalImage:@"gravity.png" selectedImage:@"gravity.png"];
        
        CCMenuItemToggle *btnSnd= [CCMenuItemToggle itemWithTarget:self selector:@selector(doSndSwtch:) items:btnOn, btnOff, nil];
        
        CCMenu *menu = [CCMenu menuWithItems:btnSnd,nil];
        menu.position = ccp(screenSize.width/2,startMenu.position.y-60);
        [self addChild:menu z:1900 tag:100];
        
    }
    return self;
}

#pragma -
#pragma mark switchBtn
-(void)doSndSwtch: (id) sender{
    if([sender selectedIndex]==0)
    {
        [Config sharedConfig].controlType =GESTURE_CONTROL;
    }else{
        [Config sharedConfig].controlType =GRAVITY_CONTROL;
    }
}
@end
