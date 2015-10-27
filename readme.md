# react-native-record-audio-ios

This is a wrapper for react-native that records audio. The options are to start and stop recording. Supported files include .caf, .m4a, and .wav types. This is for ios only.

# Add it to your project

npm install react-native-record-audio-ios --save

In XCode, in the project navigator, right click Libraries ➜ Add Files to [your project's name]

Go to node_modules ➜ react-native-record-audio-ios and add RNRecordAudio.xcodeproj

In XCode, in the project navigator, select your project. Add libRNRecordAudio.a to your project's Build Phases ➜ Link Binary With Libraries

Click RNRecordAudio.xcodeproj in the project navigator and go the Build Settings tab. Make sure 'All' is toggled on (instead of 'Basic'). Look for Header Search Paths and make sure it contains both $(SRCROOT)/../react-native/React and $(SRCROOT)/../../React - mark both as recursive.

Run your project (Cmd+R)

Setup trouble?

If you get stuck, take a look at Brent Vatne's blog. His blog is my go to reference for this stuff.

# Api Setup
```javascript
var React = require('react-native');

var { NativeModules } = React;

var { RNRecordAudio } = NativeModules;

// Start Recording

RNRecordAudio.startRecord(
    "test.m4a", // filename

    function errorCallback(results) {
        console.log('JS Error: ' + results['errMsg']);
    },

    function successCallback(results) {
        console.log('JS Success: ' + results['successMsg']);
    }
);

// Stop Recording

RNRecordAudio.stopRecord(
    "test.m4a", // filename

    function errorCallback(results) {
        console.log('JS Error: ' + results['errMsg']);
    },

    function successCallback(results) {
        console.log('JS Success: ' + results['successMsg']);
    }
);
```


# Additional Notes

The recorded audio is saved in the app documents directory. The format/file type of the audio should be either a .caf, .wav, or .m4a.

# Error Callback

The following will cause an error callback (use the console.log to see the specific message):

1) Filename not included in api call

2) Filename is a hidden file

3) File is not .caf, .wav, .m4a type

4) If stopping, file does not exist in the app documents directory

5) If stopping, recording is not already in progress

# Acknowledgements

Special thanks to Joshua Sierles for his work and code on react-native-audio. Brent Vatne for his posts on creating a react native packager. Some portions of this code have been based on answers from stackoverflow. This package also owes a special thanks to the tutorial by Jay Garcia at Modus Create on how to create a custom react native module.
