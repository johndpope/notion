//
//  MIDIUtil.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 3/25/07.
//  Copyright 2007 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AudioToolbox/AudioToolbox.h>
@class Song;

@interface MIDIUtil : NSObject {

}

+ (NSData *)writeSequenceToData:(MusicSequence)seq;
+ (void)readSong:(Song *)song fromMIDI:(NSData *)data;

@end
