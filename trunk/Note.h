//
//  Note.h
//  Music Editor
//
//  Created by Konstantine Prevas on 5/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AudioToolbox/AudioToolbox.h>
#import "KeySignature.h"

static int NO_ACC = -100;
static int SHARP = 1;
static int NATURAL = 0;
static int FLAT = -1;

@interface Note : NSObject <NSCopying>{
	int duration;
	BOOL dotted;
	int octave;
	int pitch;
	int accidental;
	
	Note *tieTo;
	Note *tieFrom;
}

- (id)initWithPitch:(int)_pitch octave:(int)_octave 
	duration:(int)_duration dotted:(BOOL)_dotted accidental:(int)_accidental;
- (id)initRestWithDuration:(int)_duration dotted:(BOOL)_dotted;
		
- (int)getDuration;
- (BOOL)getDotted;
- (int)getPitch;
- (int)getOctave;
- (int)getAccidental;
- (BOOL)isRest;

- (float)getEffectiveDuration;

- (void)setDuration:(int)_duration;
- (void)setDotted:(BOOL)_dotted;
- (void)setOctave:(int)_octave;
- (void)setPitch:(int)_pitch;
- (void)setAccidental:(int)_accidental;

- (float)addToMIDITrack:(MusicTrack *)musicTrack atPosition:(float)pos
	withKeySignature:(KeySignature *)sig accidentals:(NSMutableDictionary *)accidentals
	onChannel:(int)channel;

- (void)tieTo:(Note *)note;
- (Note *)getTieTo;
- (void)tieFrom:(Note *)note;
- (Note *)getTieFrom;

- (void)transposeBy:(int)transposeAmount;

- (void)collapseOnTo:(Note *)note;
- (NSArray *)removeDuration:(float)maxDuration;
+ (Note *)tryToFill:(float)maxDuration copyingNote:(Note *)src;

@end
