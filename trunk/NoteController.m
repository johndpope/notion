//
//  self.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "NoteController.h"
#import "ScoreController.h"
#import "MeasureController.h"
#import "NoteBase.h"
#import "Chord.h"
#import "Measure.h"
#import "ScoreView.h"

@implementation NoteController

+ (float) widthOf:(NoteBase *)note{
	return (72.0 / [note getDuration]) * ([note getDotted] ? 1.5 : 1);	
}

+ (float) widthOf:(NoteBase *)note inMeasure:(Measure *)measure{
	float width = [self widthOf:note];
	float noteStart = [measure getNoteStartDuration:note];
	float noteEnd = [measure getNoteEndDuration:note];
	int measureIndex = [[[measure getStaff] getMeasures] indexOfObject:measure];
	NSEnumerator *staffs = [[[[measure getStaff] getSong] staffs] objectEnumerator];
	int max = 0;
	id staff;
	while(staff = [staffs nextObject]){
		if([[staff getMeasures] count] > measureIndex){
			Measure *measure = [[staff getMeasures] objectAtIndex:measureIndex];
			int numNotes = [measure getNumberOfNotesStartingAfter:noteStart before:noteEnd];
			if(numNotes > max) max = numNotes;
		}
	}
	return width + max * [MeasureController minNoteSpacing];	
}

+ (float) xOf:(NoteBase *)note inMeasure:(Measure *)measure{
	return [MeasureController xOfIndex:[[measure getNotes] indexOfObject:note] inMeasure:measure];
}

+ (BOOL)handleKeyPress:(NSEvent *)event at:(NSPoint)location on:(NoteBase *)note mode:(NSDictionary *)mode view:(ScoreView *)view{
	if([[event characters] rangeOfString:[NSString stringWithFormat:@"%C", NSDeleteCharacter]].location != NSNotFound){
		[[note undoManager] setActionName:@"deleting note"];
		Chord *chord = [[note getStaff] getChordContainingNote:note];
		if(chord == nil){
			Measure *measure = [[note getStaff] getMeasureContainingNote:note];
			if(measure != nil){
				[measure removeNoteAtIndex:[[measure getNotes] indexOfObject:note] temporary:NO];
				return YES;			
			}			
		} else {
			Measure *measure = [[note getStaff] getMeasureContainingNote:chord];
			if(measure != nil){
				[measure removeNote:note fromChordAtIndex:[[measure getNotes] indexOfObject:chord]];
				return YES;
			}			
		}
	}
	return NO;
}

+ (void)handleMouseClick:(NSEvent *)event at:(NSPoint)location on:(NoteBase *)note mode:(NSDictionary *)mode view:(ScoreView *)view{
	if(([event modifierFlags] & NSShiftKeyMask) && [view selection] != nil){
		[view setSelection:[[note getStaff] notesBetweenNote:[view selection] andNote:note]];
	} else {
		[view setSelection:note];		
	}
}

+ (void)handleDrag:(NSEvent *)event to:(NSPoint)location on:(NoteBase *)note finished:(BOOL)finished mode:(NSDictionary *)mode view:(ScoreView *)view{
	Measure *measure = [[note getStaff] getMeasureContainingNote:note];
	id controller = [measure getControllerClass];
	location.y -= [controller boundsOf:measure].origin.y;
	int pitch = [controller pitchAt:location inMeasure:measure];
	int octave = [controller octaveAt:location inMeasure:measure];
	[note setPitch:pitch finished:finished];
	[note setOctave:octave finished:finished];
}

@end
