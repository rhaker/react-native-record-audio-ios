//
//  RNRecordAudio.h
//  RNRecordAudio
//  Created by Ross Haker on 9/13/15.
//


#import <AVFoundation/AVFoundation.h>
#import <RCTBridge.h>

@interface RNRecordAudio : NSObject <RCTBridgeModule, AVAudioRecorderDelegate>

@end