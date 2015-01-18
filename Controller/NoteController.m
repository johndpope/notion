//
//  NoteController.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "NoteController.h"
#import "ScoreController.h"
#import "MeasureController.h"
#import "NoteBase.h"
#import "Note.h"
#import "Rest.h"
#import "Chord.h"
#import "Measure.h"
#import "Staff.h"
#import "ScoreView.h"
#import <Chomp/Chomp.h>

NSMutableDictionary *cachedNoteWidths = nil;

@implementation NoteController

+(BOOL)isSelected:(NoteBase *)note inSelection:(id)selection{
	if(note == selection){
		return true;
	}
	if([selection respondsToSelector:@selector(containsObject:)] &&
	   [selection containsObject:note]){
		return true;
	}
	return false;
}

+ (float) widthOf:(NoteBase *)note{
	return (100.0 / [note getDuration]) * ([note getDotted] ? 1.5 : 1);	
}

+ (float) widthOf:(NoteBase *)note inMeasure:(Measure *)measure{
	if(cachedNoteWidths == nil){
		cachedNoteWidths = [[NSMutableDictionary dictionary] retain];
	}
	NSNumber *cachedWidth = [cachedNoteWidths objectForKey:[NSNumber numberWithInt:note]];
	if(cachedWidth != nil){
		return [cachedWidth floatValue];
	}
	float width = [self widthOf:note];
	NSPoint notePosition = [measure getNotePosition:note];
	float noteStart = notePosition.x;
	float noteEnd = notePosition.x + notePosition.y;
	int measureIndex = [[[measure getStaff] getMeasures] indexOfObject:measure];
	NSEnumerator *staffs = [[[[measure getStaff] getSong] staffs] objectEnumerator];
	int max = 0;
	id staff;
	while(staff = [staffs nextObject]){
		if([[staff getMeasures] count] > measureIndex){
			Measure *measure = [staff getMeasureAtIndex:measureIndex];
			int numNotes = [measure getNumberOfNotesStartingAfter:noteStart before:noteEnd];
			if(numNotes > max) max = numNotes;
		}
	}
	width = width + max * [MeasureController minNoteSpacing];
	[cachedNoteWidths setObject:[NSNumber numberWithFloat:width] forKey:[NSNumber numberWithInt:note]];
}

+ (float) xOf:(NoteBase *)note{
	Measure *measure = [[note getStaff] getMeasureContainingNote:note];
	return [[measure getControllerClass] xOfIndex:[[measure getNotes] indexOfObject:note] inMeasure:measure];
}

+ (BOOL)doNoteDeletion:(NoteBase *)note{
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
	return NO;
}

+ (NSString *)getCommandListFor:(NoteBase *)note at:(NSPoint)location mode:(NSDictionary *)mode{
	NSMutableArray *commands = [NSMutableArray array];
	[commands addObject:@"click - select note"];
	[commands addObject:@"DELETE - delete note"];
	if([note respondsToSelector:@selector(setPitch:finished:)]){
		[commands addObject:@"drag - change pitch"];
	}
	if([note respondsToSelector:@selector(setAccidental:)]){
		[commands addObject:@"P ; / - change accidental"];
	}
	if([note respondsToSelector:@selector(setDotted:)]){
		if([note getDotted]){
			[commands addObject:@". - make not dotted"];
		} else {
			[commands addObject:@". - make dotted"];
		}
	}
	if([note respondsToSelector:@selector(tieFrom:)] && ![note isKindOfClass:[Rest class]]){
		if([note getTieFrom] == nil){
			if([[note getStaff] findPreviousNoteMatching:note inMeasure:[[note getStaff] getMeasureContainingNote:note]] != nil){
				[commands addObject:@"[ - tie to previous note"];
			}
		} else {
			[commands addObject:@"[ - break tie"];
		}
	}
	return [commands componentsJoinedByString:@"\n"];
}

+ (BOOL)handleKeyPress:(NSEvent *)event at:(NSPoint)location on:(NoteBase *)note mode:(NSDictionary *)mode view:(ScoreView *)view{
	if([[event characters] rangeOfString:[NSString stringWithFormat:@"%C", NSDeleteCharacter]].location != NSNotFound){
		if([[view selection] respondsToSelector:@selector(containsObject:)] && [[view selection] containsObject:note]){
			[[self doSelf] doNoteDeletion:[[view selection] each]];
			[view setSelection:nil];
			[[note undoManager] setActionName:@"deleting notes"];
			return YES;
		} else {
			[view setSelection:nil];
			return [self doNoteDeletion:note];
		}
	}
	if([note respondsToSelector:@selector(setAccidental:)]){
		if([[event charactersIgnoringModifiers] rangeOfString:[NSString stringWithFormat:@"p"]].location != NSNotFound){
			if([note getAccidental] == SHARP){
				[note setAccidental:NO_ACC];
				[[note undoManager] setActionName:@"removing accidental"];
			} else {
				[note setAccidental:SHARP];
				[[note undoManager] setActionName:@"changing accidental"];
			}
			return YES;
		}
		if([[event charactersIgnoringModifiers] rangeOfString:[NSString stringWithFormat:@";"]].location != NSNotFound){
			if([note getAccidental] == NATURAL){
				[note setAccidental:NO_ACC];
				[[note undoManager] setActionName:@"removing accidental"];
			} else {
				[note setAccidental:NATURAL];
				[[note undoManager] setActionName:@"changing accidental"];
			}
			return YES;
		}
		if([[event charactersIgnoringModifiers] rangeOfString:[NSString stringWithFormat:@"/"]].location != NSNotFound){
			if([note getAccidental] == FLAT){
				[note setAccidental:NO_ACC];
				[[note undoManager] setActionName:@"removing accidental"];
			} else {
				[note setAccidental:FLAT];
				[[note undoManager] setActionName:@"changing accidental"];
			}
			return YES;
		}
	}
	if([note respondsToSelector:@selector(setDotted:)]){
		if([[event charactersIgnoringModifiers] rangeOfString:[NSString stringWithFormat:@"."]].location != NSNotFound){
			if([note getDotted]){
				[note setDotted:NO];
				[[note undoManager] setActionName:@"removing dotted duration"];
			} else {
				[note setDotted:YES];
				[[note undoManager] setActionName:@"setting dotted duration"];
			}
			return YES;
		}
	}
	if([note respondsToSelector:@selector(tieFrom:)]){
		if([[event charactersIgnoringModifiers] rangeOfString:[NSString stringWithFormat:@"["]].location != NSNotFound){
			if([note getTieFrom] != nil){
				[[note undoManager] setActionName:@"breaking note tie"];
				[[note getTieFrom] tieTo:nil];
				[note tieFrom:nil];
				return YES;
			} else {
				Measure *measure = [[note getStaff] getMeasureContainingNote:note];
				Note *tie = [[note getStaff] findPreviousNoteMatching:note inMeasure:measure];
				if(tie != nil){
					[note tieFrom:tie];
					[tie tieTo:note];
					[[note undoManager] setActionName:@"tying notes"];
					return YES;
				}
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

+ (void)dragNote:(NoteBase *)note to:(NSPoint)location finished:(BOOL)finished{
	if([note respondsToSelector:@selector(setPitch:octave:finished:)]){
		Measure *measure = [[note getStaff] getMeasureContainingNote:note];
		id controller = [measure getControllerClass];
		location.y -= [controller boundsOf:measure].origin.y;
		int pitch = [controller pitchAt:location inMeasure:measure];
		int octave = [controller octaveAt:location inMeasure:measure];
		[note setPitch:pitch octave:octave finished:finished];	
	}
}

+ (void)handleDrag:(NSEvent *)event from:(NSPoint)fromLocation to:(NSPoint)location on:(NoteBase *)note finished:(BOOL)finished mode:(NSDictionary *)mode view:(ScoreView *)view{
	if([[view selection] respondsToSelector:@selector(containsObject:)] && [[view selection] containsObject:note]){
		NSEnumerator *notes = [[view selection] objectEnumerator];
		id selectNote;
		while(selectNote = [notes nextObject]){
			if([selectNote respondsToSelector:@selector(getLastPitch)] && [selectNote respondsToSelector:@selector(getLastOctave)]){
				Measure *measure = [[selectNote getStaff] getMeasureContainingNote:note];
				id controller = [measure getControllerClass];
				int lastPosition = [[measure getEffectiveClef] getPositionForPitch:[selectNote getLastPitch] withOctave:[selectNote getLastOctave]];
				NSPoint fakeLocation;
				fakeLocation.x = location.x;
				fakeLocation.y = location.y - fromLocation.y + [controller yOfPosition:lastPosition inMeasure:measure];
				[self dragNote:selectNote to:fakeLocation finished:finished];
			}
		}
		[[note undoManager] setActionName:@"dragging notes"];
	} else {
		[self dragNote:note to:location finished:finished];
		[[note undoManager] setActionName:@"dragging note"];
	}
}

+ (void)clearCaches{
	[cachedNoteWidths removeAllObjects];
}

@end
