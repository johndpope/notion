//
//  NoteBase.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/31/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "NoteBase.h"
#import "NoteController.h"

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

- (Staff *)getStaff{
	return staff;
}

- (void)setStaff:(Staff *)_staff{
	staff = _staff;
}

- (NSUndoManager *)undoManager{
	return [[[[self getStaff] getSong] document] undoManager];
}

- (void)sendChangeNotification{
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"modelChanged" object:self]];
}

- (float)getEffectiveDuration{
	float effDuration = 3.0 / (float)[self getDuration];
	if([self getDotted]) effDuration *= 1.5;
	return effDuration;
}

- (BOOL)canBeInChord{
	return YES;
}

- (BOOL)isTriplet{
	return [self getDuration] % 3 == 0;
}

- (BOOL)isPartOfFullTriplet{
	return [self getContainingTriplet] != nil;
}

- (BOOL)isDrawBars{
	return NO;
}

- (NSArray *)getContainingTriplet{
	// find first triplet note in sequence leading up to this note
	NoteBase *curr = self;
	NoteBase *prev;
	for(prev = [staff noteBefore:curr]; prev != nil && [prev isTriplet]; prev = [staff noteBefore:curr]){
		curr = prev;
	}
	BOOL foundSelf = NO;
	float tripletDuration = 0;
	NSMutableArray *triplet = [NSMutableArray array];
	// try to construct a full triplet
	while([curr isTriplet]){
		if(curr == self){
			foundSelf = YES;
		}
		[triplet addObject:curr];
		tripletDuration += [curr getEffectiveDuration];
		// tripletDuration / 3.0 gives the "real" effective duration
		// reciprocal of that is the denominator of the duration
		// a full triplet has been completed if the denominator is a power of 2.
		float denom = 3.0 / tripletDuration;
		int denomAsInt = (int)denom;
		if((denom - floor(denom) < 0.005) &&
		   (denomAsInt & (denomAsInt - 1)) == 0){
			if(foundSelf){
				return triplet;
			}
			[triplet removeAllObjects];
			tripletDuration = 0;
		}
		curr = [staff noteAfter:curr];
	}
	return nil;	
}

- (float)addToMIDITrack:(MusicTrack *)musicTrack atPosition:(float)pos
	   withKeySignature:(KeySignature *)sig accidentals:(NSMutableDictionary *)accidentals
			  transpose:(int)transposition onChannel:(int)channel{
	[self doesNotRecognizeSelector:_cmd];
	return 0;
}

- (void)transposeBy:(int)transposeAmount{
	[self doesNotRecognizeSelector:_cmd];
}

- (void)prepareForDelete{
	
}

- (NSArray *)subtractDuration:(float)maxDuration{
	NSMutableArray *remainingNotes = [NSMutableArray array];
	float remainingDuration = [self getEffectiveDuration] - maxDuration;
	NoteBase *lastNote = nil;
	while(remainingDuration > 0){
		NoteBase *newNote = [self copy];
		[newNote tryToFill:remainingDuration];
		remainingDuration -= [newNote getEffectiveDuration];
		[remainingNotes addObject:newNote];
		[lastNote tieTo:newNote];
		[newNote tieFrom:lastNote];
		lastNote = newNote;
	}
	return remainingNotes;
}

- (void)tryToFill:(float)maxDuration{
	if(maxDuration >= 4.5){
		duration = 1;
		dotted = YES;
	} else if(maxDuration >= 3){
		duration = 1;
		dotted = NO;
	} else if(maxDuration >= 2.25){
		duration = 2;
		dotted = YES;
	} else if(maxDuration >= 1.5){
		duration = 2;
		dotted = NO;
	} else if(maxDuration >= 1.0){
		duration = 3;
		dotted = NO;
	} else if(maxDuration >= 0.975){
		duration = 4;
		dotted = YES;
	} else if(maxDuration >= 0.75){
		duration = 4;
		dotted = NO;
	} else if(maxDuration >= 0.5){
		duration = 6;
		dotted = NO;
	} else if(maxDuration >= 0.5625){
		duration = 8;
		dotted = YES;
	} else if(maxDuration >= 0.375){
		duration = 8;
		dotted = NO;
	} else if(maxDuration >= 0.25){
		duration = 12;
		dotted = NO;
	} else if(maxDuration >= 0.28125){
		duration = 16;
		dotted = YES;
	} else if(maxDuration >= 0.1875){
		duration = 16;
		dotted = NO;
	} else if(maxDuration >= 0.125){
		duration = 24;
		dotted = NO;
	} else if(maxDuration >= 0.140625){
		duration = 32;
		dotted = YES;
	} else if(maxDuration >= 0.09375){
		duration = 32;
		dotted = NO;
	} else if(maxDuration >= 0.0625){
		duration = 48;
		dotted = NO;
	}
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

- (Class)getControllerClass{
	return [NoteController class];
}

@end
