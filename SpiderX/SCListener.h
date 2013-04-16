//
//  SCListener.h
//  SpiderX
//
//  Created by Charge on 13-4-8.
//
//
#import <Foundation/Foundation.h>

#import <AudioToolbox/AudioQueue.h>

#import <AudioToolbox/AudioServices.h>


@interface SCListener : NSObject {
    
    AudioQueueLevelMeterState *levels;
    
    
    
    AudioQueueRef queue;
    
    AudioStreamBasicDescription format;
    
    Float64 sampleRate;
    
}


+ (SCListener *)sharedListener;


- (void)listen;

- (BOOL)isListening;

- (void)pause;

- (void)stop;


- (Float32)averagePower;

- (Float32)peakPower;

- (AudioQueueLevelMeterState *)levels;


@end