//
//  ChordController.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 10/1/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "ChordController.h"
#import "Chord.h"
#import "Measure.h"
#import "NoteBase.h"
#import "MeasureController.h"

@implementation ChordController

+ (float) widthOf:(Chord *)chord{
	NoteBase *note = [[chord getNotes] objectAtIndex:0];
	return [[note getControllerClass] widthOf:note];
}

+ (float) widthOf:(Chord *)chord inMeasure:(Measure *)measure{
	NoteBase *note = [[chord getNotes] objectAtIndex:0];
	return [[note getControllerClass] widthOf:note inMeasure:measure];
}

+ (float) xOf:(Chord *)chord inMeasure:(Measure *)measure{
	return [MeasureController xOfIndex:[[measure getNotes] indexOfObject:chord] inMeasure:measure];
}

+ (BOOL)isOverNote:(NSPoint)location inChord:(Chord *)chord inMeasure:(Measure *)measure{
	return [self noteAt:location inChord:chord inMeasure:measure] != nil;
}

+ (NoteBase *)noteAt:(NSPoint)location inChord:(Chord *)chord inMeasure:(Measure *)measure{
	NSEnumerator *notes = [[chord getNotes] objectEnumerator];
	id note;
	while(note = [notes nextObject]){
		if([MeasureController isOverNote:note at:location inMeasure:measure]){
			return note;
		}
	}
	return nil;
}

+ (BOOL)handleKeyPress:(NSEvent *)event at:(NSPoint)location on:(Chord *)chord mode:(NSDictionary *)mode view:(ScoreView *)view{
	if([[event characters] rangeOfString:[NSString stringWithFormat:@"%C", NSDeleteCharacter]].location != NSNotFound){
		[[chord undoManager] setActionName:@"deleting note"];
		Measure *measure = [[chord getStaff] getMeasureContainingNote:chord];
		[measure removeNoteAtIndex:[[measure getNotes] indexOfObject:chord] temporary:NO];
		return YES;
	}
	return NO;
}

+ (void)handleMouseClick:(NSEvent *)event at:(NSPoint)location on:(Chord *)chord mode:(NSDictionary *)mode view:(ScoreView *)view{
	if(([event modifierFlags] & NSShiftKeyMask) && [view selection] != nil){
		[view setSelection:[[chord getStaff] notesBetweenNote:[view selection] andNote:chord]];
	} else {
		[view setSelection:chord];		
	}
}

@end
