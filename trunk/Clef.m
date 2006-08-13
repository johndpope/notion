//
//  Clef.m
//  Music Editor
//
//  Created by Konstantine Prevas on 5/7/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "Clef.h"
@class ClefDraw;

@implementation Clef

- (id)initWithPitchOffset:(int)_pitchOff withOctaveOffset:(int)_octOff{
	if(self = [super init]){
		pitchOffset = _pitchOff;
		octaveOffset = _octOff;
	}
	return self;
}

+ (Clef *)trebleClef{
	static Clef *treble;
	if(treble == nil){
		treble = [[[Clef alloc] initWithPitchOffset:2 withOctaveOffset:4] retain];
	}
	return treble;
}

+ (Clef *)bassClef{
	static Clef *bass;
	if(bass == nil){
		bass = [[[Clef alloc] initWithPitchOffset:4 withOctaveOffset:2] retain];
	}
	return bass;
}

+ (Clef *)getClefAfter:(Clef *)clef{
	if([clef isEqual:[self trebleClef]]){
		return [self bassClef];
	} else{
		return [self trebleClef];
	}
}

- (int)getPositionForPitch:(int)pitch withOctave:(int)octave{
	return (octave * 7) + pitch - (octaveOffset * 7 + pitchOffset);
}

- (int)getPitchForPosition:(int)position{
	return ((octaveOffset * 7 + pitchOffset) + position) % 7;
}

- (int)getOctaveForPosition:(int)position{
	int adjPos = position;
	if(position < 0 && (-(position + pitchOffset)) % 7 != 6) adjPos--;
	int octave = ((adjPos + pitchOffset) / 7);
	if(position < 0 && ((-position-pitchOffset) % 7) > 0) octave--;
	return octaveOffset + octave;
}

- (int)getTranspositionFrom:(Clef *)clef{
	return ([self getOctaveForPosition:0] - [clef getOctaveForPosition:0]) * 7;
}

- (Class)getViewClass{
	return [ClefDraw class];
}

@end
