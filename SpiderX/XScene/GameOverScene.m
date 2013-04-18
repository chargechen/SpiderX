//
//  GameOverScene.m
//  SpiderX
//
//  Created by Charge on 13-4-9.
//
//

#import "GameOverScene.h"
#import "GameScene.h"
#import "Config.h"
#define SPIDER_HIGH_SCORE_PLAYER @"SPIDER_HIGH_SCORE_PLAYER"
#define SPIDER_HIGH_SCORE @"SPIDER_HIGH_SCORE"
@implementation GameOverScene
{
    CGSize winSize;
}

+(id)scene
{
    CCScene *scene =[CCScene node];
    CCLayer *layer = [GameOverScene node];
    [scene addChild:layer];
    return scene;
}

-(id)init
{
   
    if(self=[super init])
    {
        
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        winSize = [CCDirector sharedDirector].winSize;
                
        CCSprite *sp = [CCSprite spriteWithFile:@"bg01.jpg"] ;
        [self addChild:sp z:0 tag:1];
        [sp setAnchorPoint:ccp(0,0)];
        
        CCSprite *logo = [CCSprite spriteWithFile:@"gameOver.png"] ;
        [logo setPosition:ccp((winSize.width-logo.contentSize.width)/2, 300)];
        [logo setAnchorPoint:ccp(0,0)];
        [self addChild:logo z:10 tag:300];
        
        CCSprite *playAgainNormal = [CCSprite spriteWithFile:@"menu.png" rect:CGRectMake(378,0,126,33)];
              CCSprite *playAgainSelected = [CCSprite spriteWithFile:@"menu.png" rect:CGRectMake(378,33,126,33)];
              CCSprite *playAgainDisabled = [CCSprite spriteWithFile:@"menu.png" rect:CGRectMake(378,66,126,33)];
     
        CCMenuItemSprite *playAgain =[CCMenuItemSprite itemWithNormalSprite:playAgainNormal selectedSprite:playAgainSelected disabledSprite:playAgainDisabled target:self selector:@selector(playAgain)];
        CCMenu *menu = [CCMenu menuWithItems:playAgain, nil];
        
        [self addChild:menu z:1 tag:2];
        [menu setPosition:ccp(winSize.width/2,60)];

        //读取纪录
        int highScore =[[NSUserDefaults standardUserDefaults] integerForKey:SPIDER_HIGH_SCORE];
        CCLabelTTF* highScoreText = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"HIGHEST SCORE:%d",highScore] fontName:@"Marker Felt" fontSize:18];
        highScoreText.position = CGPointMake(winSize.width-highScoreText.contentSize.width,winSize.height-highScoreText.contentSize.height);
        highScoreText.anchorPoint =ccp(0,0);
        [self addChild:highScoreText z:30 tag:55];

        NSString* highScorePlayer =[[NSUserDefaults standardUserDefaults] objectForKey:SPIDER_HIGH_SCORE_PLAYER];
        if(!highScorePlayer){
            highScorePlayer =@"";
        }
        CCLabelTTF* highScorePlayerText = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"PLAYER:%@",highScorePlayer] fontName:@"Marker Felt" fontSize:20];
        highScorePlayerText.position = CGPointMake(winSize.width-highScorePlayerText.contentSize.width,winSize.height-highScorePlayerText.contentSize.height-highScoreText.contentSize.height);
        highScorePlayerText.anchorPoint =ccp(0,0);
        [self addChild:highScorePlayerText z:30 tag:54];
        highScorePlayerText.color = ccc3(255, 255, 0);
        
        //本场分数
        int score= [Config sharedConfig].scoreValue;
        CCLabelTTF* scoreText = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"YOU SCORE:%d",score] fontName:@"Marker Felt" fontSize:40];
        scoreText.position = CGPointMake(winSize.width/2,winSize.height/2);
        [self addChild:scoreText z:30 tag:59];
        
        if(score>highScore){
            UITextField *nameInput = [[UITextField alloc] initWithFrame:CGRectMake((winSize.width-250)/2,winSize.height-200, 250, 60)];
            nameInput.placeholder =@"enter your name";
            nameInput.backgroundColor =[UIColor yellowColor];
            nameInput.autocorrectionType =UITextAutocorrectionTypeNo;
            nameInput.tag =60;
            nameInput.returnKeyType =UIReturnKeyDone;
            nameInput.delegate = self;
            [[CCDirector sharedDirector].view addSubview:nameInput];
            UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
            tapGr.cancelsTouchesInView = NO;
            
            [[CCDirector sharedDirector].view addGestureRecognizer:tapGr];
        }

    }
    return self;
}
-(void)dealloc
{
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewTapped:(id)sender{
    [[[CCDirector sharedDirector].view viewWithTag:60] resignFirstResponder];
        [[CCDirector sharedDirector].view removeGestureRecognizer:sender];
}
-(void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary* info = notification.userInfo;
    
    UITextField* input = (UITextField*)[[CCDirector sharedDirector].view viewWithTag:60];
    CGRect inputRect =  input.frame;
    inputRect.origin =[self convertToWorldSpace:inputRect.origin];
    
    NSValue *aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyBoardRect;
    
    [aValue getValue:&keyBoardRect];

    if (inputRect.origin.y +inputRect.size.height >= keyBoardRect.origin.y)
    {
        CGPoint destPos = inputRect.origin;
        destPos.y -= inputRect.size.height-( keyBoardRect.origin.y-inputRect.origin.y)+20;
        [UIView animateWithDuration:0.5 animations:^{
            input.frame = CGRectMake(destPos.x, destPos.y, inputRect.size.width, inputRect.size.height);
        }];
    }
}

#pragma mark - UITextFieldDelegate
//-(void)textFieldDidBeginEditing:(UITextField *)textField{
//
//
//}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *name = textField.text;
    if(![name isEqual:@""]){
        [[NSUserDefaults standardUserDefaults] setObject:name forKey:SPIDER_HIGH_SCORE_PLAYER];
        [[NSUserDefaults standardUserDefaults]setInteger:[Config sharedConfig].scoreValue forKey:SPIDER_HIGH_SCORE];
        [[NSUserDefaults standardUserDefaults] synchronize];
        CCLabelTTF *scoreLabel =(CCLabelTTF*)[self getChildByTag:55];
        [scoreLabel setString:[NSString stringWithFormat:@"HIGHEST SCORE:%d",[Config sharedConfig].scoreValue]];
        CCLabelTTF *nameLabel =(CCLabelTTF*)[self getChildByTag:54];
        [nameLabel setString:[NSString stringWithFormat:@"PLAYER:%@",name]];
        scoreLabel.position =CGPointMake(winSize.width-scoreLabel.contentSize.width,winSize.height-scoreLabel.contentSize.height);
       nameLabel.position= CGPointMake(winSize.width-nameLabel.contentSize.width,winSize.height-nameLabel.contentSize.height-scoreLabel.contentSize.height);
        
        [[[CCDirector sharedDirector].view viewWithTag:60]removeFromSuperview];
    }
    [textField resignFirstResponder];
    return  YES;
}

-(void)playAgain
{
    [[[CCDirector sharedDirector].view viewWithTag:60] removeFromSuperview];
    CCScene * scene = [GameScene scene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionTurnOffTiles transitionWithDuration:1.2 scene:scene]];
}
@end
