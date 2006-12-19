//
//  self.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "MeasureController.h"
#import "Measure.h"
#import "MEWindowController.h"
#import "ScoreController.h"
#import "StaffController.h"
#import "NoteController.h"
#import "ChordController.h"
#import "ClefController.h"
#import "KeySignatureController.h"
#import "TimeSignatureController.h"
#import "ClefTarget.h"
#import "Clef.h"
#import "Rest.h"

@implementation MeasureController

+ (float)minNoteSpacing{
	return 15.0;
}

+ (float)repeatAreaWidth:(Measure *)measure{
	return 15.0;
}

+ (float) clefAreaX:(Measure *)measure{
	return [self repeatAreaWidth:measure];
}

+ (float) timeSigAreaX:(Measure *)measure{
	return [self clefAreaX:measure] + [ClefController widthOf:[measure getClef]];
}

+ (float) keySigAreaX:(Measure *)measure{
	return [self timeSigAreaX:measure] + [TimeSignatureController widthOf:[measure getTimeSignature]];
}

+ (float)noteAreaStart:(Measure *)measure{
	return [self repeatAreaWidth:measure] + 
			[ClefController widthOf:[measure getClef]] + 
			[KeySignatureController widthOf:[measure getKeySignature]] + 
			[TimeSignatureController widthOf:[measure getTimeSignature]];
}

+ (float)isolatedWidthOf:(Measure *)measure{
	if(measure == nil) return 0;
	float width = [self minNoteSpacing];
	NSEnumerator *notes = [[measure getNotes] objectEnumerator];
	id note;
	while(note = [notes nextObject]){
		width += [NoteController widthOf:note] + [self minNoteSpacing];
	}
	if(width < 150.0) width = 150.0;
	width += [self noteAreaStart:measure] + [self repeatAreaWidth:measure];
	return width;
}

+ (float)widthOf:(Measure *)measure{
	float max = 0;
	int index = [[[measure getStaff] getMeasures] indexOfObject:measure];
	NSEnumerator *staffs = [[[[measure getStaff] getSong] staffs] objectEnumerator];
	id staff;
	while(staff = [staffs nextObject]){
		if([[staff getMeasures] count] > index){
			float width = [self isolatedWidthOf:[[staff getMeasures] objectAtIndex:index]];
			if(width > max) max = width;
		}
	}
	return max;	
}

+ (float)xOf:(Measure *)measure{
	NSEnumerator *measures = [[[measure getStaff] getMeasures] objectEnumerator];
	float x = [ScoreController xInset];
	id currMeasure;
	while((currMeasure = [measures nextObject]) && currMeasure != measure){
		x += [self widthOf:currMeasure];
	}
	return x;
}

+ (NSRect)boundsOf:(Measure *)measure{
	NSRect bounds;
	NSRect staffBounds = [StaffController boundsOf:[measure getStaff]];
	bounds.origin.x = [self xOf:measure];
	bounds.origin.y = staffBounds.origin.y;
	bounds.size.width = [self widthOf:measure];
	bounds.size.height = staffBounds.size.height;
	return bounds;
}

+ (NSRect)innerBoundsOf:(Measure *)measure{
	NSRect bounds = [self boundsOf:measure];
	bounds.size.height -= 100;
	bounds.origin.y = [StaffController baseOf:[measure getStaff]] - bounds.size.height;
	return bounds;
}

+ (int)positionAt:(NSPoint)location inMeasure:(Measure *)measure{
	Staff *staff = [measure getStaff];
	return ([StaffController baseOf:staff] - [StaffController topOf:staff] - location.y) / [StaffController lineHeightOf:staff];
}

+ (int)octaveAt:(NSPoint)location inMeasure:(Measure *)measure{
	return [[measure getEffectiveClef] getOctaveForPosition:[self positionAt:location inMeasure:measure]];
}

+ (int)pitchAt:(NSPoint)location inMeasure:(Measure *)measure{
	return [[measure getEffectiveClef] getPitchForPosition:[self positionAt:location inMeasure:measure]];
}

+ (float)indexAt:(NSPoint)location inMeasure:(Measure *)measure{
	float x = location.x;
	float currX = 0;
	NSEnumerator *notes = [[measure getNotes] objectEnumerator];
	id note;
	float index = -0.5;
	currX += [self minNoteSpacing] + [self noteAreaStart:measure];
	while((note = [notes nextObject]) && currX < x){
		index += 0.5;
		currX += 12;
		if(currX >= x) break;
		currX += [NoteController widthOf:note inMeasure:measure] + [self minNoteSpacing] - 12;
		index += 0.5;
	}
	return index;	
}

+ (float)xOfIndex:(float)index inMeasure:(Measure *)measure{
	float measureX = [self xOf:measure];
	float x = measureX + [self minNoteSpacing] + [self noteAreaStart:measure];
	if([[measure getNotes] count] > 0){
		NSEnumerator *notes = [[measure getNotes] objectEnumerator];
		id note = [notes nextObject];
		while(index >= 1 && note){
			x += [NoteController widthOf:note inMeasure:measure] + [self minNoteSpacing];
			note = [notes nextObject];
			index -= 1;
		}
		if(note == nil) note = [[measure getNotes] lastObject];
		if(index < 0){
			x -= [self minNoteSpacing];
		} else if(index > 0){
			if(note == [[measure getNotes] lastObject]){
				x += [NoteController widthOf:note inMeasure:measure] + [self minNoteSpacing];
			} else{
				x += [NoteController widthOf:note inMeasure:measure] / 2;
			}
		}
	}
	if(x + [self minNoteSpacing] > measureX + [self widthOf:measure]){
		x = measureX + [self widthOf:measure] - [self minNoteSpacing];
	}
	return x;	
}

+ (float)yOfPosition:(int)position inMeasure:(Measure *)measure{
	NSRect measureBounds = [MeasureController innerBoundsOf:measure];
	float lineHeight = [StaffController lineHeightOf:[measure getStaff]];
	return measureBounds.origin.y + measureBounds.size.height - lineHeight * position;
}

+ (BOOL) isOverStartRepeat:(NSPoint)location inMeasure:(Measure *)measure{
	return location.x <= [self repeatAreaWidth:measure];
}

+ (BOOL) isOverClef:(NSPoint)location inMeasure:(Measure *)measure{
	return ![self isOverStartRepeat:location inMeasure:measure] &&
		location.x <= [self repeatAreaWidth:measure] + [ClefController widthOf:[measure getClef]];
}

+ (BOOL) isOverTimeSig:(NSPoint)location inMeasure:(Measure *)measure{
	return ![self isOverStartRepeat:location inMeasure:measure] &&
		![self isOverClef:location inMeasure:measure] &&
		location.x <= [self repeatAreaWidth:measure] + 
		[ClefController widthOf:[measure getClef]] + 
		[TimeSignatureController widthOf:[measure getTimeSignature]];
}

+ (BOOL) isOverKeySig:(NSPoint)location inMeasure:(Measure *)measure{
	return ![self isOverStartRepeat:location inMeasure:measure] &&
		![self isOverClef:location inMeasure:measure] &&
		![self isOverTimeSig:location inMeasure:measure] &&
			location.x <= [self repeatAreaWidth:measure] + 
			[ClefController widthOf:[measure getClef]] + 
			[TimeSignatureController widthOf:[measure getTimeSignature]] + 
			[KeySignatureController widthOf:[measure getKeySignature]];
}

+ (BOOL) isOverEndRepeat:(NSPoint)location inMeasure:(Measure *)measure{
	return location.x >= [self widthOf:measure] - [self repeatAreaWidth:measure];
}

+ (NSPoint) keySigPanelLocationFor:(Measure *)measure{
	NSPoint location;
	location.x = [MeasureController xOf:measure] + [ClefController widthOf:[measure getClef]] + [TimeSignatureController widthOf:[measure getTimeSignature]];
	location.y = [StaffController topOf:[measure getStaff]];
	return location;
}

+ (NSPoint) timeSigPanelLocationFor:(Measure *)measure{
	NSPoint location;
	location.x = [MeasureController xOf:measure] + [ClefController widthOf:[measure getClef]];
	location.y = [StaffController topOf:[measure getStaff]];
	return location;
}

+ (NSPoint) repeatPanelLocationFor:(Measure *)measure{
	NSPoint location;
	NSRect bounds = [MeasureController boundsOf:measure];
	location.x = bounds.origin.x + bounds.size.width - 10;
	location.y = [StaffController topOf:[measure getStaff]];
	return location;
}

+ (BOOL)isOverNote:(NoteBase *)note at:(NSPoint)location inMeasure:(Measure *)measure{
	return [self pitchAt:location inMeasure:measure] == [note getPitch] && [self octaveAt:location inMeasure:measure] == [note getOctave];
}

+ (id)targetAtLocation:(NSPoint)location inMeasure:(Measure *)measure mode:(NSDictionary *)mode withEvent:(NSEvent *)event{
	if([[mode objectForKey:@"specialEvent"] isEqualToString:@"paste"]){
		return measure;
	}
	if([self isOverClef:location inMeasure:measure]){
		return [[ClefTarget alloc] initWithMeasure:measure];
	}
	if([self isOverKeySig:location inMeasure:measure]){
		return [[KeySigTarget alloc] initWithMeasure:measure];
	}
	if([self isOverTimeSig:location inMeasure:measure]){
		return [[TimeSigTarget alloc] initWithMeasure:measure];
	}		
	if(location.x <= [self noteAreaStart:measure]){
		return measure;
	}
	float index = [self indexAt:location inMeasure:measure];
	if(((int)(index * 2)) % 2 == 0){
		//on a note
		int pointerMode = [[mode objectForKey:@"pointerMode"] intValue];
		NoteBase *note = [[measure getNotes] objectAtIndex:index];
		if([self canPlaceNoteAt:location inMeasure:measure]){
			if(pointerMode == MODE_NOTE && [note isKindOfClass:[Note class]] && ![self isOverNote:note at:location inMeasure:measure]){
				//above or below a note in add note mode, want to create a chord
				return measure;
			}
			if(pointerMode == MODE_NOTE && [note isKindOfClass:[Chord class]] && ![ChordController isOverNote:location inChord:note inMeasure:measure]){
				return measure;
			}
		}
		if([note isKindOfClass:[Chord class]] && ([event modifierFlags] & NSAlternateKeyMask)){
			return [[note getControllerClass] noteAt:location inChord:note inMeasure:measure];
		}
		return note;
	} else{
		//between notes
		return measure;
	}
}

+ (void)scrollView:(NSView *)view toShowMeasure:(Measure *)measure{
	[view scrollRectToVisible:NSInsetRect([self boundsOf:measure], -30, -30)];
}

+ (BOOL)canPlaceNoteAt:(NSPoint)location inMeasure:(Measure *)measure{
	Clef *clef = [measure getEffectiveClef];
	return [clef positionIsValid:[self positionAt:location inMeasure:measure]];
}

+ (void)handleMouseClick:(NSEvent *)event at:(NSPoint)location on:(Measure *)measure mode:(NSDictionary *)mode view:(ScoreView *)view{
	[view setSelection:nil];
	location.x -= [self xOf:measure];
	location.y -= [self boundsOf:measure].origin.y;
	if([self isOverStartRepeat:location inMeasure:measure]){
		if(![measure isStartRepeat]){
			[measure setStartRepeat:YES];			
		}
	} else if([measure followsOpenRepeat]){
		[measure setEndRepeat:2];
	} else if([measure isEndRepeat] && [self isOverEndRepeat:location inMeasure:measure]){
		[view showRepeatCountPanelFor:[measure getRepeatEndingHere] inMeasure:measure];
	} else {
		int pointerMode = [[mode objectForKey:@"pointerMode"] intValue];
		int duration = [[mode objectForKey:@"duration"] intValue];
		if([[mode objectForKey:@"triplet"] boolValue]){
			duration = duration * 3 / 2;
		}
		BOOL dotted = [[mode objectForKey:@"dotted"] boolValue];
		int accidental = [[mode objectForKey:@"accidental"] intValue];
		BOOL tieToPrev = [[mode objectForKey:@"tieToPrev"] boolValue];
		if(pointerMode == MODE_NOTE){
			int pitch = [self pitchAt:location inMeasure:measure];
			int octave = [self octaveAt:location inMeasure:measure];
			if([self canPlaceNoteAt:location inMeasure:measure]){
				[[measure undoManager] setActionName:@"adding note"];
				Note *note = [[Note alloc] initWithPitch:pitch octave:octave duration:duration dotted:dotted accidental:accidental onStaff:[measure getStaff]];
				[measure addNote:note atIndex:[self indexAt:location inMeasure:measure] tieToPrev:tieToPrev];
				[self scrollView:view toShowMeasure:[[note getStaff] getMeasureContainingNote:note]];			
			}
		}
	}
}

+ (BOOL)handleKeyPress:(NSEvent *)event at:(NSPoint)location on:(Measure *)measure mode:(NSDictionary *)mode view:(ScoreView *)view{
	location.x -= [self xOf:measure];
	location.y -= [self boundsOf:measure].origin.y;
	if([measure isStartRepeat] && [self isOverStartRepeat:location inMeasure:measure] && 
	   [[event characters] rangeOfString:[NSString stringWithFormat:@"%C", NSDeleteCharacter]].location != NSNotFound){
		[measure setStartRepeat:NO];
		return YES;
	}
	if([measure isEndRepeat] && [self isOverEndRepeat:location inMeasure:measure] &&
	   [[event characters] rangeOfString:[NSString stringWithFormat:@"%C", NSDeleteCharacter]].location != NSNotFound){
		[measure removeEndRepeat];
		return YES;
	}
	if([view selection] != nil && [[event characters] rangeOfString:[NSString stringWithFormat:@"%C", NSDeleteCharacter]].location != NSNotFound){
		if([[view selection] respondsToSelector:@selector(objectAtIndex:)]){
			BOOL handled = [[[[view selection] objectAtIndex:0] getControllerClass] handleKeyPress:event at:location on:[[view selection] objectAtIndex:0] mode:mode view:view];
			if(handled){
				return YES;
			}
		} else {
			BOOL handled = [[[view selection] getControllerClass] handleKeyPress:event at:location on:[view selection] mode:mode view:view];
			if(handled){
				return YES;
			}
		}
	}
	int pointerMode = [[mode objectForKey:@"pointerMode"] intValue];
	int duration = [[mode objectForKey:@"duration"] intValue];
	BOOL dotted = [[mode objectForKey:@"dotted"] boolValue];
	if(pointerMode == MODE_NOTE && [[event characters] isEqualToString:@" "]){
		Rest *rest = [[Rest alloc] initWithDuration:duration dotted:dotted onStaff:[measure getStaff]];
		[measure addNote:rest atIndex:[self indexAt:location inMeasure:measure] tieToPrev:NO];
		if([measure isFull]) [[measure getStaff] getMeasureAfter:measure];
		[self scrollView:view toShowMeasure:[[rest getStaff] getMeasureContainingNote:rest]];
		return YES;
	}
	return NO;
}

+ (void)cleanNoteForPaste:(NoteBase *)note inMeasure:(Measure *)measure preserveTiesWithin:(NSArray *)array{
	[note setStaff:[measure getStaff]];
	if(![array containsObject:[note getTieTo]]){
		[note tieTo:nil];
	}
	if(![array containsObject:[note getTieFrom]]){
		[note tieFrom:nil];
	}
}

+ (void)handlePaste:(id)data at:(NSPoint)location on:(Measure *)measure mode:(NSDictionary *)mode{
	location.x -= [self xOf:measure];
	if([data isKindOfClass:[NoteBase class]]){
		[self cleanNoteForPaste:data inMeasure:measure preserveTiesWithin:nil];
		[measure addNote:data atIndex:[self indexAt:location inMeasure:measure] tieToPrev:NO];	
		[[measure undoManager] setActionName:@"pasting note"];
	} else if([data respondsToSelector:@selector(containsObject:)]){
		[[self doSelf] cleanNoteForPaste:[data each] inMeasure:measure preserveTiesWithin:data];
		[measure addNotes:data atIndex:[self indexAt:location inMeasure:measure]];
		[[measure undoManager] setActionName:@"pasting notes"];
	}
}

@end
