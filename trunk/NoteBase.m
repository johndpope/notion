//
//  NoteBase.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/31/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "NoteBase.h"


@implementation NoteBase

- (int)getDuration{
	return duration;
}
- (BOOL)getDotted{
	return dotted;
}

- (void)setDuration:(int)_duration{
	duration = _duration;
}
- (void)setDotted:(BOOL)_dotted{
	dotted = _dotted;
}

- (float)getEffectiveDuration{
	float effDuration = 1.0 / (float)duration;
	if(dotted) effDuration *= 1.5;
	return effDuration;
}

- (float)addToMIDITrack:(MusicTrack *)musicTrack atPosition:(float)pos
	   withKeySignature:(KeySignature *)sig accidentals:(NSMutableDictionary *)accidentals
			  onChannel:(int)channel{
	[self doesNotRecognizeSelector:_cmd];
	return 0;
}

- (void)transposeBy:(int)transposeAmount{
	[self doesNotRecognizeSelector:_cmd];
}

- (void)prepareForDelete{
	
}

- (NSArray *)removeDuration:(float)maxDuration{
	NSMutableArray *notes = [NSMutableArray arrayWithObject:self];
	float remainingDuration = [self getEffectiveDuration] - maxDuration;
	NoteBase *note = [NoteBase tryToFill:remainingDuration copyingNote:self];
	[self setDuration:[note getDuration]];
	[self setDotted:[note getDotted]];
	remainingDuration -= [self getEffectiveDuration];
	NoteBase *lastNote = self;
	while(remainingDuration > 0){
		note = [NoteBase tryToFill:remainingDuration copyingNote:self];
		[notes addObject:note];
		[lastNote tieTo:note];
		[note tieFrom:lastNote];
		lastNote = note;
		remainingDuration -= [note getEffectiveDuration];
	}
	return notes;
}

+ (NoteBase *)tryToFill:(float)maxDuration copyingNote:(NoteBase *)src{
	int duration;
	BOOL dotted;
	if(maxDuration >= 1.5){
		duration = 1;
		dotted = YES;
	} else if(maxDuration >= 1){
		duration = 1;
		dotted = NO;
	} else if(maxDuration >= 0.75){
		duration = 2;
		dotted = YES;
	} else if(maxDuration >= 0.5){
		duration = 2;
		dotted = NO;
	} else if(maxDuration >= 0.325){
		duration = 4;
		dotted = YES;
	} else if(maxDuration >= 0.25){
		duration = 4;
		dotted = NO;
	} else if(maxDuration >= 0.1875){
		duration = 8;
		dotted = YES;
	} else if(maxDuration >= 0.125){
		duration = 8;
		dotted = NO;
	} else if(maxDuration >= 0.09375){
		duration = 16;
		dotted = YES;
	} else if(maxDuration >= 0.0625){
		duration = 16;
		dotted = NO;
	} else if(maxDuration >= 0.046875){
		duration = 32;
		dotted = YES;
	} else if(maxDuration >= 0.03125){
		duration = 32;
		dotted = NO;
	} else return nil;
	NoteBase *note = [[src copy] autorelease];
	[note setDuration:duration];
	[note setDotted:dotted];
	return note;
}

// -- tie methods - do nothing by default

- (void)tieTo:(NoteBase *)note{
	
}

- (NoteBase *)getTieTo{
	return nil;
}

- (void)tieFrom:(NoteBase *)note{
	
}

- (NoteBase *)getTieFrom{
	return nil;
}

- (Class)getViewClass{
	[self doesNotRecognizeSelector:_cmd];
	return [NSObject class];
}

@end
