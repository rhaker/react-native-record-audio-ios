//
//  RNRecordAudio.m
//  RNRecordAudio
//  Created by Ross Haker on 9/13/15.
//

#import "RNRecordAudio.h"

@implementation RNRecordAudio {

    AVAudioSession *recordSession;
    AVAudioRecorder *audioRecorder;

}

// Expose this module to the React Native bridge
RCT_EXPORT_MODULE()

// Persist data
RCT_EXPORT_METHOD(startRecord:(NSString *)fileName
                  errorCallback:(RCTResponseSenderBlock)failureCallback
                  callback:(RCTResponseSenderBlock)successCallback) {

    // Validate the file name has positive length
    if ([fileName length] < 1) {

        // Show failure message
        NSDictionary *resultsDict = @{
                                      @"success" : @NO,
                                      @"errMsg"  : @"Your file does not have a name."
                                      };

        // Javascript error handling
        failureCallback(@[resultsDict]);
        return;

    }

    // Validate the file name has an extension
    NSRange isRange = [fileName rangeOfString:@"." options:NSCaseInsensitiveSearch];

    if(isRange.location == 0) {

        // Show failure message
        NSDictionary *resultsDict = @{
                                      @"success" : @NO,
                                      @"errMsg"  : @"Your file does not have a valid name and extension."
                                      };

        // Javascript error handling
        failureCallback(@[resultsDict]);
        return;

    } else {

        if(isRange.location == NSNotFound) {

            // Show failure message
            NSDictionary *resultsDict = @{
                                          @"success" : @NO,
                                          @"errMsg"  : @"Your file does not have a valid extension."
                                          };

            // Javascript error handling
            failureCallback(@[resultsDict]);
            return;
        }

    }

    // Validate for .caf, .mp3, .aac, , .wav, .aiff
    NSRange isRangeCaf = [fileName rangeOfString:@".caf" options:NSCaseInsensitiveSearch];
    NSRange isRangeM4a = [fileName rangeOfString:@".m4a" options:NSCaseInsensitiveSearch];
    NSRange isRangeWav = [fileName rangeOfString:@".wav" options:NSCaseInsensitiveSearch];

    if ((isRangeCaf.location == NSNotFound) && (isRangeM4a.location == NSNotFound) && (isRangeWav.location == NSNotFound)) {

        // Show failure message
        NSDictionary *resultsDict = @{
                                      @"success" : @NO,
                                      @"errMsg"  : @"File should be either a .caf, .m4a, or .wav"
                                      };

        // Javascript error handling
        failureCallback(@[resultsDict]);
        return;

    }

    // Create an array of directory Paths, to allow us to get the documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    // The documents directory is the first item
    NSString *documentsDirectory = [paths objectAtIndex:0];

    // Create the path that the file will be stored at
    NSString *pathForFile = [NSString stringWithFormat:@"%@/%@", documentsDirectory, fileName];

    NSURL *audioFileURL = [NSURL fileURLWithPath:pathForFile];

    NSDictionary *recordSettings;

    // Set the recording setting based on type of file
    if (isRangeCaf.location != NSNotFound) {

        // caf setttings
        recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:AVAudioQualityHigh], AVEncoderAudioQualityKey,
                          [NSNumber numberWithInt:16], AVEncoderBitRateKey,
                          [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
                          [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                          nil];

    } else if (isRangeM4a.location != NSNotFound) {

        // m4a settings
        recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                          [NSNumber numberWithFloat:16000.0], AVSampleRateKey,
                          [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                          nil];

    } else {

        // default to wav settings
        recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithFloat:44100.0],AVSampleRateKey,
                          [NSNumber numberWithInt:2],AVNumberOfChannelsKey,
                          [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                          [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                          [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                          [NSNumber numberWithBool:0], AVLinearPCMIsBigEndianKey,
                          [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                          [NSData data], AVChannelLayoutKey, nil];

    }

    // Initialize the session for the recording
    NSError *error = nil;
    recordSession = [AVAudioSession sharedInstance];
    [recordSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];

    // Initialize new recorder if existing does not match url
    if(audioRecorder && ![audioRecorder.url isEqual: audioFileURL]) {

        audioRecorder = [[AVAudioRecorder alloc]
                         initWithURL:audioFileURL
                         settings:recordSettings
                         error:&error];

        audioRecorder.delegate = self;
    }

    // Initialize recorder if it does not exists
    if (!audioRecorder) {

        audioRecorder = [[AVAudioRecorder alloc]
                         initWithURL:audioFileURL
                         settings:recordSettings
                         error:&error];

        audioRecorder.delegate = self;
    }

    // Validate no errors in the session initialization
    if (error) {

        // Show failure message
        NSDictionary *resultsDict = @{
                                      @"success" : @NO,
                                      @"errMsg"  : [error localizedDescription]
                                      };

        // Javascript error handling
        failureCallback(@[resultsDict]);
        return;

    } else {

        // prepare the recording
        [audioRecorder prepareToRecord];

    }

    // if recording is in progress, stop
    if (audioRecorder.recording) {

        [audioRecorder stop];
        [recordSession setActive:NO error:nil];

    }

    // start recording
    [recordSession setActive:YES error:nil];
    [audioRecorder record];

    // Craft a success return message
    NSDictionary *resultsDict = @{
                                  @"success" : @YES,
                                  @"successMsg" : @"Successfully started."
                                  };

    // Call the JavaScript sucess handler
    successCallback(@[resultsDict]);

}

// Persist data
RCT_EXPORT_METHOD(stopRecord:(NSString *) fileName
                  errorCallback:(RCTResponseSenderBlock)failureCallback
                  callback:(RCTResponseSenderBlock)successCallback) {

    // Create an array of directory Paths, to allow us to get the documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    // The documents directory is the first item
    NSString *documentsDirectory = [paths objectAtIndex:0];

    // Create the path that the file will be stored at
    NSString *pathForFile = [NSString stringWithFormat:@"%@/%@", documentsDirectory, fileName];

    // Validate that the file exists
    NSFileManager *fileManager = [NSFileManager defaultManager];

    // Check if file exists
    if (![fileManager fileExistsAtPath:pathForFile]){

        // Show failure message
        NSDictionary *resultsDict = @{
                                      @"success" : @NO,
                                      @"errMsg"  : @"File does not exist in app documents directory."
                                      };

        // Javascript error handling
        failureCallback(@[resultsDict]);
        return;

    }

    // Validate that session and recorder exist to stop
    if (recordSession && audioRecorder) {

        // if recording is in progress, stop
        if (audioRecorder.recording) {

            [audioRecorder stop];
            [recordSession setActive:NO error:nil];

            // Craft a success return message
            NSDictionary *resultsDict = @{
                                          @"success" : @YES,
                                          @"successMsg"  : @"Successfully stopped."
                                          };

            // Call the JavaScript sucess handler
            successCallback(@[resultsDict]);
            return;

        } else {

            // Show failure message
            NSDictionary *resultsDict = @{
                                          @"success" : @NO,
                                          @"errMsg"  : @"Recording not in progress. Can not be stopped."
                                          };

            // Javascript error handling
            failureCallback(@[resultsDict]);
            return;
        }

    } else {

        // Show failure message
        NSDictionary *resultsDict = @{
                                      @"success" : @NO,
                                      @"errMsg"  : @"Recording was not ever started. Can not be stopped."
                                      };

        // Javascript error handling
        failureCallback(@[resultsDict]);
        return;

    }


}

@end

