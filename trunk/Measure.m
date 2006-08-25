//
//  Measure.m
//  Music Editor
//
//  Created by Konstantine Prevas on 5/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "Measure.h"
#import "Note.h"
#import "Clef.h"
#import "Staff.h"
#import "TimeSignature.h"
@class MeasureDraw;

@implementation Measure

- (id)initWithStaff:(Staff *)_staff{
	if((self = [super init])){
		notes = [[NSMutableArray array] retain];
		staff = _staff;
	}
	return self;
}

- (Staff *)getStaff{
	return staff;
}

- (NSUndoManager *)undoManager{
	return [[[[self getStaff] getSong] document] undoManager];
}

- (void)sendChangeNotification{
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"modelChanged" object:self]];
}

- (NSMutableArray *)getNotes{
	return notes;
}

- (NoteBase *)getFirstNote{
	return [notes objectAtIndex:0];
}

- (void)prepUndo{
	[[[self undoManager] prepareWithInvocationTarget:self] setNotes:[NSMutableArray arrayWithArray:notes]];	
}

- (void)setNotes:(NSMutableArray *)_notes{
	[self prepUndo];
	if(![notes isEqual:_notes]){
		[notes release];
		notes = [_notes retain];
		[staff cleanEmptyMeasures];
	}
	[self sendChangeNotification];
}

- (float)getTotalDuration{
	float totalDuration = 0;
	NSEnumerator *notesEnum = [notes objectEnumerator];
	id note;
	while(note = [notesEnum nextObject]){
		totalDuration += [note getEffectiveDuration];
	}
	return totalDuration;
}

- (void)addNote:(NoteBase *)_note atIndex:(float)index tieToPrev:(BOOL)tieToPrev{
	[self prepUndo];
	Note *note = [self addNotes:[NSArray arrayWithObject:_note] atIndex:index];
	Measure *measure = [staff getMeasureContainingNote:note];
	if(tieToPrev){
		Note *tie = [staff findPreviousNoteMatching:note inMeasure:measure];
		[note tieFrom:tie];
		[tie tieTo:note];
	}
	if([measure isFull]) [staff getMeasureAfter:measure];
}

- (NoteBase *)addNotes:(NSArray *)_notes atIndex:(float)index{
	NSEnumerator *notesEnum = [_notes reverseObjectEnumerator];
	NoteBase *note;
	index = ceil(index);
	
	// break tie if necessary
	Note *prevNote = nil, *nextNote = nil;
	if(index-1 >= 0){
		prevNote = [notes objectAtIndex:index-1];
		nextNote = [prevNote getTieTo];
	} else if(index < [notes count]){
		nextNote = [notes objectAtIndex:index];
		prevNote = [nextNote getTieFrom];		
	}
	if(prevNote != nil && nextNote != nil){
		if([prevNote isEqualTo:[_notes objectAtIndex:0]]){
			[prevNote tieTo:[_notes objectAtIndex:0]];
			[[_notes objectAtIndex:0] tieFrom:prevNote];
		} else{
			[prevNote tieTo:nil];
		}
		if([nextNote isEqualTo:[_notes lastObject]]){
			[[_notes lastObject] tieTo:nextNote];
			[nextNote tieFrom:[_notes lastObject]];
		} else{
			[nextNote tieFrom:nil];
		}
	}
	
	while(note = [notesEnum nextObject]){
		[notes insertObject:note atIndex:index];
	}
	if(index >= [notes count]) return nil;
	Note *rtn = [notes objectAtIndex:index];
	float totalDuration = [self getTotalDuration];
	float maxDuration = [[self getEffectiveTimeSignature] getMeasureDuration];
	while(totalDuration > maxDuration){
		note = [notes lastObject];
		_notes = [NSMutableArray arrayWithObject:note];
		totalDuration -= [note getEffectiveDuration];
		if(totalDuration < maxDuration){
			float durationToFill = maxDuration - totalDuration;
			_notes = [note removeDuration:(durationToFill)];
			int index = [notes count] - 1;
			NoteBase *lastNote = note;
			while(durationToFill > 0){
				Note *fill = [NoteBase tryToFill:durationToFill copyingNote:note];
				[notes insertObject:fill atIndex:index];
				[fill tieTo:lastNote];
				[lastNote tieFrom:fill];
				if(rtn == lastNote) rtn = fill;
				lastNote = fill;
				totalDuration += [fill getEffectiveDuration];
				durationToFill -= [fill getEffectiveDuration];
			}
		}
		[notes removeLastObject];
		Measure *nextMeasure = [staff getMeasureAfter:self];
		[nextMeasure prepUndo];
		[nextMeasure addNotes:_notes atIndex:0];
	}
	return rtn;
}

- (void)grabNotesFromNextMeasure{
	if([staff getLastMeasure] == self) return;
	Measure *nextMeasure = [staff getMeasureAfter:self];
	[nextMeasure prepUndo];
	float totalDuration = [self getTotalDuration];
	float maxDuration = [[self getEffectiveTimeSignature] getMeasureDuration];
	while(totalDuration < maxDuration && ![nextMeasure isEmpty]){
		float durationToFill = maxDuration - totalDuration;
		NoteBase *nextNote = [nextMeasure getFirstNote];
		[nextMeasure removeNoteAtIndex:0 temporary:YES];
		if([nextNote getEffectiveDuration] <= durationToFill){
			[notes addObject:nextNote];
			totalDuration += [nextNote getEffectiveDuration];
		} else{
			//TODO: move tie stuff on to Note?
			NSMutableArray *_notes = [nextNote removeDuration:durationToFill];
			[nextMeasure addNotes:_notes atIndex:0];
			[nextMeasure grabNotesFromNextMeasure];
			Note *tieFrom = [nextNote getTieFrom];
			Note *note = nextNote;
			Note *lastNote = note;
			while(durationToFill > 0){
				note = [NoteBase tryToFill:durationToFill copyingNote:note];
				[notes addObject:note];
				[note tieTo:lastNote];
				[note tieFrom:tieFrom];
				[tieFrom tieTo:note];
				tieFrom = nil;
				[lastNote tieFrom:note];
				lastNote = note;
				totalDuration += [note getEffectiveDuration];
				durationToFill -= [note getEffectiveDuration];			
			}
			totalDuration = [self getTotalDuration];
		}
	}
}

- (void)removeNoteAtIndex:(float)x temporary:(BOOL)temp{
	[self prepUndo];
	NoteBase *note = [notes objectAtIndex:floor(x)];
	if(!temp){
		[note prepareForDelete];
	}
	[notes removeObjectAtIndex:floor(x)];
	[self grabNotesFromNextMeasure];
	if(!temp){
		[staff cleanEmptyMeasures];
		[self sendChangeNotification];
	}
}

- (BOOL)isEmpty{
	return [notes count] == 0;
}

- (BOOL)isFull{
	float totalDuration = 0.0;
	NSEnumerator *notesEnum = [notes objectEnumerator];
	id note;
	while(note = [notesEnum nextObject]){
		totalDuration += [note getEffectiveDuration];
	}
	return totalDuration == [[self getEffectiveTimeSignature] getMeasureDuration];
}

- (Clef *)getClef{
	return clef;
}

- (Clef *)getEffectiveClef{
	return [staff getClefForMeasure:self];
}

- (void)setClef:(Clef *)_clef{
	if(![clef isEqual:_clef]){
		[clef release];
		clef = [_clef retain];
	}
}

- (KeySignature *)getKeySignature{
	return keySig;
}

- (KeySignature *)getEffectiveKeySignature{
	return [staff getKeySignatureForMeasure:self];
}

- (void)setKeySignature:(KeySignature *)_sig{
	if(![keySig isEqual:_sig]){
		[keySig release];
		keySig = [_sig retain];
	}
}

- (TimeSignature *)getTimeSignature{
	return [staff getTimeSignatureForMeasure:self];
}

- (BOOL)hasTimeSignature{
	return ![[self getTimeSignature] isKindOfClass:[NSNull class]];
}

- (TimeSignature *)getEffectiveTimeSignature{
	return [staff getEffectiveTimeSignatureForMeasure:self];
}

- (void)timeSignatureChangedFrom:(float)oldTotal to:(float)newTotal top:(int)top bottom:(int)bottom{
	if(newTotal < oldTotal){
		[self addNotes:[NSArray array] atIndex:0];
	} else{
		[self grabNotesFromNextMeasure];
	}
	[timeSigTopStep setIntValue:top];
	[timeSigTopText setIntValue:top];
	[timeSigBottom selectItemWithTitle:[NSString stringWithFormat:@"%d", bottom]];
	[[timeSigPanel superview] setNeedsDisplay:YES];
}

- (BOOL)isShowingKeySigPanel{
	return keySigPanel != nil && ![keySigPanel isHidden];
}

- (NSView *)getKeySigPanel{
	if(keySigPanel == nil){
		[NSBundle loadNibNamed:@"KeySigPanel" owner:self];
		[keySigPanel setHidden:YES];
	}
	return keySigPanel;
}

- (BOOL)isShowingTimeSigPanel{
	return timeSigPanel != nil && ![timeSigPanel isHidden];
}

- (NSView *)getTimeSigPanel{
	if(timeSigPanel == nil){
		[NSBundle loadNibNamed:@"TimeSigPanel" owner:self];
		[timeSigPanel setHidden:YES];
	}
	return timeSigPanel;
}

- (NoteBase *)getNoteBefore:(NoteBase *)source{
	int index = [notes indexOfObject:source];
	if(index != NSNotFound && index > 0){
		return [notes objectAtIndex:index-1];
	}
	return nil;
}

- (float)getNoteStartDuration:(NoteBase *)note{
	float start = 0;
	NSEnumerator *notesEnum = [notes objectEnumerator];
	id currNote;
	while((currNote = [notesEnum nextObject]) && currNote != note){
		start += [currNote getEffectiveDuration];
	}
	return start;
}

- (float)getNoteEndDuration:(NoteBase *)note{
	return [self getNoteStartDuration:note] + [note getEffectiveDuration];
}

- (int)getNumberOfNotesStartingAfter:(float)startDuration before:(float)endDuration{
	float duration = 0;
	int count = 0;
	NSEnumerator *notesEnum = [notes objectEnumerator];
	id currNote;
	while((currNote = [notesEnum nextObject]) && duration < endDuration){
		if(duration > startDuration){
			count++;
		}
		duration += [currNote getEffectiveDuration];
	}
	return count;
}

- (void)transposeBy:(int)transposeAmount{
	NSEnumerator *notesEnum = [notes objectEnumerator];
	id note;
	while(note = [notesEnum nextObject]){
		[note transposeBy:transposeAmount];
	}
}

- (IBAction)keySigChanged:(id)sender{
	KeySignature *newSig;
	if([[[keySigMajMin selectedItem] title] isEqual:@"major"]){
		newSig = [KeySignature getMajorSignatureAtIndexFromA:[keySigLetter indexOfSelectedItem]];
		if(newSig == nil){
			newSig = [KeySignature getMinorSignatureAtIndexFromA:[keySigLetter indexOfSelectedItem]];
			[keySigMajMin selectItemWithTitle:@"minor"];
		}
	} else{
		newSig = [KeySignature getMinorSignatureAtIndexFromA:[keySigLetter indexOfSelectedItem]];
		if(newSig == nil){
			newSig = [KeySignature getMajorSignatureAtIndexFromA:[keySigLetter indexOfSelectedItem]];
			[keySigMajMin selectItemWithTitle:@"major"];
		}
	}
	[self setKeySignature:newSig];
	[[keySigPanel superview] setNeedsDisplay:YES];
}

- (IBAction)keySigClose:(id)sender{
	[keySigPanel setHidden:YES withFade:YES blocking:(sender != nil)];
	if([keySigPanel superview] != nil){
		[keySigPanel removeFromSuperview];
	}
}

- (IBAction)timeSigTopChanged:(id)sender{
	int value = [sender intValue];
	if(value < 1) value = 1;
	[timeSigTopStep setIntValue:value];
	[timeSigTopText setIntValue:value];
	[staff timeSigChangedAtMeasure:self top:[timeSigTopText intValue] bottom:[[[timeSigBottom selectedItem] title] intValue]];
}

- (IBAction)timeSigBottomChanged:(id)sender{
	[staff timeSigChangedAtMeasure:self top:[timeSigTopText intValue] bottom:[[[timeSigBottom selectedItem] title] intValue]];
}

- (IBAction)timeSigClose:(id)sender{
	[timeSigPanel setHidden:YES withFade:YES blocking:(sender != nil)];
	if([timeSigPanel superview] != nil){
		[timeSigPanel removeFromSuperview];
	}
}

- (void)cleanPanels{
	[self timeSigClose:nil];
	[self keySigClose:nil];
}

- (float)addToMIDITrack:(MusicTrack *)musicTrack atPosition:(float)pos onChannel:(int)channel{
	float initPos = pos;
	NSEnumerator *noteEnum = [notes objectEnumerator];
	NSMutableDictionary *accidentals = [NSMutableDictionary dictionary];
	id note;
	while(note = [noteEnum nextObject]){
		pos += [note addToMIDITrack:musicTrack atPosition:pos withKeySignature:[self getEffectiveKeySignature]
				accidentals:accidentals onChannel:channel];
	}
	return pos - initPos;
}

- (void)encodeWithCoder:(NSCoder *)coder{
	[coder encodeObject:staff forKey:@"staff"];
	if(clef == [Clef trebleClef]){
		[coder encodeObject:@"treble" forKey:@"clef"];
	}
	if(clef == [Clef bassClef]){
		[coder encodeObject:@"bass" forKey:@"clef"];
	}
	if(keySig != nil){
		[coder encodeInt:[keySig getNumFlats] forKey:@"keySigFlats"];
		[coder encodeInt:[keySig getNumSharps] forKey:@"keySigSharps"];
		if([keySig getNumFlats] == 0 && [keySig getNumSharps] == 0){
			[coder encodeBool:YES forKey:@"keySigC"];
		}
	}
	[coder encodeObject:notes forKey:@"notes"];
}

- (id)initWithCoder:(NSCoder *)coder{
	if(self = [super init]){
		staff = [coder decodeObjectForKey:@"staff"];
		id deClef = [coder decodeObjectForKey:@"clef"];
		if([deClef isEqualToString:@"treble"]){
			[self setClef:[Clef trebleClef]];
		} else if([deClef isEqualToString:@"bass"]){
			[self setClef:[Clef bassClef]];
		}
		int flats = [coder decodeIntForKey:@"keySigFlats"];
		int sharps = [coder decodeIntForKey:@"keySigSharps"];
		if(flats > 0){
			[self setKeySignature:[KeySignature getSignatureWithFlats:flats]];
		} else if(sharps > 0){
			[self setKeySignature:[KeySignature getSignatureWithSharps:sharps]];
		} else if([coder decodeBoolForKey:@"keySigC"]){
			[self setKeySignature:[KeySignature getSignatureWithFlats:0]];
		}
		[self setNotes:[coder decodeObjectForKey:@"notes"]];
	}
	return self;
}

- (void)dealloc{
	[clef release];
	[keySig release];
	[notes release];
	[anim release];
	clef = nil;
	keySig = nil;
	notes = nil;
	anim = nil;
	[super dealloc];
}

- (Class)getViewClass{
	return [MeasureDraw class];
}

@end
