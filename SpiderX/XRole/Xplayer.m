//
//  Xplayer.m
//  SpiderX
//
//  Created by Charge on 13-4-4.
//
//

#import "Xplayer.h"

@implementation Xplayer
+(id) create {
    return [[[self alloc] initPlayer] autorelease];
}

-(id) initPlayer{
    
    CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage: @"ship.png"];
    if((self =  [super initWithTexture:texture])){
        return self;
//      float imageHeight = [(Xplayer*)self texture].contentSize.height;
    }
//    playerStreak= [CCMotionStreak streakWithFade:0.2 minSeg:2 width:46 color:ccc3(255,255,255) texture:texture];
    
    
//    self.position =CGPointMake(screenSize.width/2, imageHeight/2);
//    playerStreak.position =CGPointMake(screenSize.width/2, imageHeight/2);
}
@end
