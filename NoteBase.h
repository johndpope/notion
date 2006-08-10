//
//  NoteBase.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/31/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AudioToolbox/AudioToolbox.h>
@class KeySignature;

@interface NoteBase : NSObject {
	int duration;
	BOOL dotted;
}

- (int)getDuration;
- (BOOL)getDotted;

- (void)setDuration:(int)_duration;
- (void)setDotted:(BOOL)_dotted;

- (float)getEffectiveDuration;

- (float)addToMIDITrack:(MusicTrack *)musicTrack atPosition:(float)pos
	   withKeySignature:(KeySignature *)sig accidentals:(NSMutableDictionary *)accidentals
			  onChannel:(int)channel;

- (void)transposeBy:(int)transposeAmount;

- (NSArray *)removeDuration:(float)maxDuration;
+ (NoteBase *)tryToFill:(float)maxDuration copyingNote:(NoteBase *)src;

- (Class)getViewClass;

@end
