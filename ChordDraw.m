//
//  ChordDraw.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 10/1/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ChordDraw.h"
#import "Chord.h"
#import "Note.h"
#import "MeasureDraw.h"
#import "NoteDraw.h"

@implementation ChordDraw

+ (BOOL)isStemUpwards:(Chord *)chord inMeasure:(Measure *)measure{
	int numUpwards = 0, numDownwards = 0;
	NSEnumerator *notes = [[chord getNotes] objectEnumerator];
	id note;
	while(note = [notes nextObject]){
		if([[note getViewClass] isStemUpwards:note inMeasure:measure]){
			numUpwards++;
		} else{
			numDownwards++;
		}
	}
	return numUpwards >= numDownwards;
}

+ (BOOL)isOffset:(Note *)note inChord:(Chord *)chord inMeasure:(Measure *)measure{
	int pitch = [note getPitch];
	int octave = [note getOctave];
	NSEnumerator *notes = [[chord getNotes] objectEnumerator];
	id otherNote;
	while(otherNote = [notes nextObject]){
		int otherPitch = [otherNote getPitch];
		int otherOctave = [otherNote getOctave];
		if([self isStemUpwards:chord inMeasure:measure]){
			if((octave == otherOctave && otherPitch == pitch - 1) ||
			   (otherOctave == octave - 1 && otherPitch == 6 && pitch == 0)){
				return ![self isOffset:otherNote inChord:chord inMeasure:measure];
			}			
		} else{
			if((octave == otherOctave && pitch == otherPitch - 1) ||
			   (octave == otherOctave - 1 && pitch == 6 && otherPitch == 0)){
				return ![self isOffset:otherNote inChord:chord inMeasure:measure];
			}			
		}
	}
}

+(void)draw:(Chord *)chord inMeasure:(Measure *)measure atIndex:(float)index isTarget:(BOOL)highlighted{
	NSEnumerator *notes = [[chord getNotes] objectEnumerator];
	id note;
	BOOL hasOffset = NO;
	while(note = [notes nextObject]){
		if([self isOffset:note inChord:chord inMeasure:measure]){
			hasOffset = YES;
			break;
		}
	}
	notes = [[chord getNotes] objectEnumerator];
	while(note = [notes nextObject]){
		[[note getViewClass] draw:note inMeasure:measure atIndex:index isTarget:highlighted 
						 isOffset:[self isOffset:note inChord:chord inMeasure:measure]
			  isInChordWithOffset:hasOffset
					  stemUpwards:[self isStemUpwards:chord inMeasure:measure]];
	}
}

@end
