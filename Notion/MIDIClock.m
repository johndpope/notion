//
//  MIDIClock.m
//  MIKMIDI
//
//  Created by Chris Flesner on 11/26/14.
//  Copyright (c) 2014 Mixed In Key. All rights reserved.
//

#import "MIDIClock.h"
#import <mach/mach_time.h>

@interface MIDIClock ()
@property (nonatomic) MIDITimeStamp timeStampZero;
@property (nonatomic) Float64 musicTimeStampsPerMIDITimeStamp;
@property (nonatomic) Float64 midiTimeStampsPerMusicTimeStamp;
@end


@implementation MIDIClock

#pragma mark - Lifecycle



//+ (instancetype )clock {
//    static MIDIClock *_MidiEngine = NULL;
//    if (_MidiEngine == NULL)
//        _MidiEngine = [[MIDIClock alloc] init];
//    return _MidiEngine;
//}

#pragma mark - Time Stamps

- (void)setMusicTimeStamp:(MusicTimeStamp)musicTimeStamp withTempo:(Float64)tempo atMIDITimeStamp:(MIDITimeStamp)midiTimeStamp {
    Float64 secondsPerMIDITimeStamp = [[self class] secondsPerMIDITimeStamp];
    Float64 secondsPerMusicTimeStamp = 1.0 / (tempo / 60.0);
    Float64 midiTimeStampsPerMusicTimeStamp = secondsPerMusicTimeStamp / secondsPerMIDITimeStamp;
    
    self.timeStampZero = midiTimeStamp - (musicTimeStamp * midiTimeStampsPerMusicTimeStamp);
    self.midiTimeStampsPerMusicTimeStamp = midiTimeStampsPerMusicTimeStamp;
    self.musicTimeStampsPerMIDITimeStamp = secondsPerMIDITimeStamp / secondsPerMusicTimeStamp;
}

- (MusicTimeStamp)musicTimeStampForMIDITimeStamp:(MIDITimeStamp)midiTimeStamp {
    return (midiTimeStamp - self.timeStampZero) * self.musicTimeStampsPerMIDITimeStamp;
}

- (MIDITimeStamp)midiTimeStampForMusicTimeStamp:(MusicTimeStamp)musicTimeStamp {
    return (musicTimeStamp * self.midiTimeStampsPerMusicTimeStamp) + self.timeStampZero;
}

#pragma mark - Class Methods

+ (Float64)secondsPerMIDITimeStamp {
    static Float64 secondsPerMIDITimeStamp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mach_timebase_info_data_t timeBaseInfoData;
        mach_timebase_info(&timeBaseInfoData);
        secondsPerMIDITimeStamp = (timeBaseInfoData.numer / timeBaseInfoData.denom) / 1.0e9;
    });
    return secondsPerMIDITimeStamp;
}

+ (Float64)midiTimeStampsPerTimeInterval:(NSTimeInterval)timeInterval {
    return (1.0 / [self secondsPerMIDITimeStamp]) * timeInterval;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    MIDIClock *clock = [[[self class] alloc] init];
    clock.timeStampZero = self.timeStampZero;
    clock.musicTimeStampsPerMIDITimeStamp = self.musicTimeStampsPerMIDITimeStamp;
    clock.midiTimeStampsPerMusicTimeStamp = self.midiTimeStampsPerMusicTimeStamp;
    return clock;
}

@end
