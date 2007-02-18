//
//  ChordDraw.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 10/1/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "ChordDraw.h"
#import "Chord.h"
#import "Note.h"
#import "MeasureDraw.h"
#import "NoteDraw.h"
#import "NoteController.h"

@implementation ChordDraw

+ (BOOL)isStemUpwardsInIsolation:(Chord *)chord inMeasure:(Measure *)measure{
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

+ (float) topOf:(Chord *)chord inMeasure:(Measure *)measure{
	NSRect body = [self bodyRectFor:[chord highestNote] atIndex:0 inMeasure:measure];
	float top = body.origin.y;
	if([self isStemUpwards:chord inMeasure:measure]){
		top -= 30;
	}
	return top;
}

+ (float) bottomOf:(Chord *)chord inMeasure:(Measure *)measure{
	NSRect body = [self bodyRectFor:[chord lowestNote] atIndex:0 inMeasure:measure];
	float bottom = body.origin.y + body.size.height;
	if(![self isStemUpwards:chord inMeasure:measure]){
		bottom += 30;
	}
	return bottom;
}

+ (float)stemStartYForNote:(Chord *)chord inMeasure:(Measure *)measure upwards:(BOOL)up{
	NoteBase *note;
	if(up){
		note = [chord highestNote];
	} else{
		note = [chord lowestNote];
	}
	return [[note getViewClass] stemStartYForNote:note inMeasure:measure upwards:up];
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
	return NO;
}

+ (float)stemXForNote:(Chord *)chord inMeasure:(Measure *)measure upwards:(BOOL)up{
	if([[chord getNotes] count] > 0){
		NoteBase *note = [[chord getNotes] objectAtIndex:0];
		NSRect body = [[note getViewClass] bodyRectFor:note atIndex:[[measure getNotes] indexOfObject:chord] inMeasure:measure];
		return up ? body.origin.x + body.size.width - 0.5 : body.origin.x + 0.5;
	}
	return 0;
}

+(void)draw:(Chord *)chord inMeasure:(Measure *)measure atIndex:(float)index target:(id)target selection:(id)selection{
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
	BOOL stemUpwards = [self isStemUpwards:chord inMeasure:measure];
	BOOL highlight = target == chord || [NoteController isSelected:chord inSelection:selection];
	BOOL drawStem = ![chord isDrawBars] || [measure isIsolated:chord];
	float highestBody = -MAXFLOAT, lowestBody = MAXFLOAT;
	float stemX, threeX = MAXFLOAT;
	while(note = [notes nextObject]){
		NSRect body = [[note getViewClass] bodyRectFor:note atIndex:index inMeasure:measure];
		float bodyCenter = body.origin.y + body.size.height / 2;
		if(highestBody < bodyCenter){
			highestBody = bodyCenter;
		}
		if(lowestBody > bodyCenter){
			lowestBody = bodyCenter;
		}
		stemX = stemUpwards ? body.origin.x + body.size.width - 0.5 : body.origin.x + 0.5;
		if(threeX == MAXFLOAT){
			threeX = body.origin.x + 2;
		}
		[[note getViewClass] draw:note inMeasure:measure atIndex:index 
						 isTarget:(target == note || highlight) 
						 isOffset:[self isOffset:note inChord:chord inMeasure:measure]
			  isInChordWithOffset:hasOffset
					  stemUpwards:stemUpwards
						 drawStem:(drawStem && ((stemUpwards && note == [chord highestNote]) ||
												(!stemUpwards && note == [chord lowestNote])))
					  drawTriplet:NO];
	}
	if([chord getDuration] > 2){
		if(highlight){
			[[NoteDraw mouseOverColor] set];
		}
		[NSBezierPath setDefaultLineWidth:1.5];
		[NSBezierPath strokeLineFromPoint:NSMakePoint(stemX, lowestBody) toPoint:NSMakePoint(stemX, highestBody)];
		[NSBezierPath setDefaultLineWidth:1.0];
		[[NSColor blackColor] set];
	}
	if([chord isTriplet]){
		if(![chord isPartOfFullTriplet]){
			float threeY = stemUpwards ? highestBody + 6 : lowestBody - 20;
			[@"3" drawAtPoint:NSMakePoint(threeX, threeY) withAttributes:nil];
		} else{
			[NoteDraw drawTriplet:chord];
		}
	}
}

@end
