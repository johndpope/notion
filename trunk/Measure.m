//
//  Measure.m
//  Music Editor
//
//  Created by Konstantine Prevas on 5/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Chomp/Chomp.h>
#import "Measure.h"
#import "Note.h"
#import "Chord.h"
#import "Clef.h"
#import "DrumKit.h"
#import "Staff.h"
#import "TimeSignature.h"
@class MeasureDraw;
@class DrumMeasureDraw;
@class MeasureController;
@class DrumMeasureController;

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
	if(((int)(index * 2)) % 2 == 0){
		if(![_note canBeInChord]){
			[self addNote:_note atIndex:(index - 0.5) tieToPrev:tieToPrev];
		} else {
			[[self undoManager] setActionName:@"changing note to chord"];
			[self addNote:_note toChordAtIndex:index];
		}
	} else{
		Note *firstAddedNote = [self addNotes:[NSArray arrayWithObject:_note] atIndex:index consolidate:NO];
		Measure *measure = [staff getMeasureContainingNote:firstAddedNote];
		if(tieToPrev){
			Note *tie = [staff findPreviousNoteMatching:firstAddedNote inMeasure:measure];
			[firstAddedNote tieFrom:tie];
			[tie tieTo:firstAddedNote];
		}
		if([measure isFull]) [staff getMeasureAfter:measure];
	}
}

- (NoteBase *)addNotes:(NSArray *)_notes atIndex:(float)index consolidate:(BOOL)consolidate{
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
	if(prevNote != nil && nextNote != nil && ![_notes containsObject:prevNote] && ![_notes containsObject:nextNote]){
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
	
	NoteBase *lastNoteAdded = nil;
	while(note = [notesEnum nextObject]){
		if(consolidate && [note getTieFrom] != nil && [notes containsObject:[note getTieFrom]]){
			[self consolidateNote:note];
		} else{
			[notes insertObject:note atIndex:index];
			lastNoteAdded = note;
		}
	}
	if(consolidate && [lastNoteAdded getTieTo] != nil && [notes containsObject:[lastNoteAdded getTieTo]]){
		[notes removeObject:[lastNoteAdded getTieTo]];
		[self consolidateNote:[lastNoteAdded getTieTo]];
	}
	if(index >= [notes count]) return nil;
	NoteBase *rtn = [notes objectAtIndex:index];
	return [self refreshNotes:rtn];
}

- (void)consolidateNote:(NoteBase *)note{
	NoteBase *oldNote = [note getTieFrom];
	int index = [notes indexOfObject:oldNote];
	NoteBase *noteToAdd = [note copy];
	float targetDuration = [oldNote getEffectiveDuration] + [note getEffectiveDuration];
	[noteToAdd tryToFill:targetDuration];

	NSMutableArray *remainingNotes = [NSMutableArray array];
	float totalDuration = [noteToAdd getEffectiveDuration];
	NoteBase *lastNote = noteToAdd;
	while(totalDuration < targetDuration){
		NoteBase *additionalNote = [lastNote copy];
		[additionalNote tryToFill:(targetDuration - totalDuration)];
		[lastNote tieTo:additionalNote];
		[additionalNote tieFrom:lastNote];
		lastNote = additionalNote;
		totalDuration += [additionalNote getEffectiveDuration];
		[remainingNotes addObject:additionalNote];
	}
	
	[noteToAdd tieFrom:[oldNote getTieFrom]];
	[[oldNote getTieFrom] tieTo:noteToAdd];
	
	if([remainingNotes count] > 0){		
		[[remainingNotes lastObject] tieTo:[note getTieTo]];
		[[note getTieTo] tieFrom:[remainingNotes lastObject]];
	
		[notes insertObjects:remainingNotes atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index + 1, [remainingNotes count])]];
	} else {
		[[note getTieTo] tieFrom:noteToAdd];
		[noteToAdd tieTo:[note getTieTo]];
	}
	
	[notes replaceObjectAtIndex:index withObject:noteToAdd];
}

- (NoteBase *)refreshNotes:(NoteBase *)rtn{
	float totalDuration = [self getTotalDuration];
	float maxDuration = [[self getEffectiveTimeSignature] getMeasureDuration];
	NSMutableArray *notesToPush = [NSMutableArray array];
	//	while we have too many notes
	while(totalDuration > maxDuration){
		float toRemove = totalDuration - maxDuration;
		NoteBase *lastNote = [notes lastObject];
//			if the last note is longer than we need to remove
		if([lastNote getEffectiveDuration] > toRemove){
//				remove the last note
			[notes removeLastObject];
//				get a note which is as close as possible to (but still less than) the amount we need to remove
			NoteBase *noteToPush = [lastNote copy];
			[noteToPush tryToFill:toRemove];
//				get an array of notes resulting from removing that note from the original note
			NSArray *remainingNotes = [lastNote subtractDuration:[noteToPush getEffectiveDuration]];
//				tie the last of those notes to the note we're adding
			[[remainingNotes lastObject] tieTo:noteToPush];
			[noteToPush tieFrom:[remainingNotes lastObject]];
//				add the last note to the next measure
			[notesToPush insertObject:noteToPush atIndex:0];
//				tie the last note to whatever the old note was tied to
			[noteToPush tieTo:[lastNote getTieTo]];
			[[lastNote getTieTo] tieFrom:noteToPush];
//				tie the first note from whatever the old note was tied from
			[[remainingNotes objectAtIndex:0] tieFrom:[lastNote getTieFrom]];
			[[lastNote getTieFrom] tieTo:[remainingNotes objectAtIndex:0]];
//				add the array of notes to this measure
			[notes addObjectsFromArray:remainingNotes];
//				if we just removed the first note added, update the pointer
			if(lastNote == rtn){
				rtn = [remainingNotes objectAtIndex:0];
			}
		} else {
//				remove the last note
			[notes removeLastObject];
//				add it to the next measure
			[notesToPush insertObject:lastNote atIndex:0];
		}
		totalDuration = [self getTotalDuration];
	}
	
	if([notesToPush count] > 0){
		Measure *nextMeasure = [staff getMeasureAfter:self];
		[nextMeasure prepUndo];
		[nextMeasure addNotes:notesToPush atIndex:0 consolidate:YES];
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
		NoteBase *noteToAdd;
		if([nextNote getEffectiveDuration] <= durationToFill){
			noteToAdd = nextNote;
		} else{
			noteToAdd = [nextNote copy];
			[noteToAdd tryToFill:durationToFill];
			NSArray *remainingNotes = [nextNote subtractDuration:[noteToAdd getEffectiveDuration]];
			[nextMeasure addNotes:remainingNotes atIndex:0 consolidate:YES];
			[nextMeasure grabNotesFromNextMeasure];
			[noteToAdd tieFrom:[nextNote getTieFrom]];
			[[nextNote getTieFrom] tieTo:noteToAdd];
			[noteToAdd tieTo:[remainingNotes objectAtIndex:0]];
			[[remainingNotes objectAtIndex:0] tieFrom:noteToAdd];
			[[remainingNotes lastObject] tieTo:[nextNote getTieTo]];
			[[nextNote getTieTo] tieFrom:[remainingNotes lastObject]];
		}
		if([noteToAdd getTieFrom] != nil && [notes containsObject:[noteToAdd getTieFrom]]){
			[self consolidateNote:noteToAdd];
		} else{
			[notes addObject:noteToAdd];				
		}
		totalDuration = [self getTotalDuration];
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

- (void)addNote:(NoteBase *)newNote toChordAtIndex:(float)index{
	NoteBase *note = [notes objectAtIndex:index];
	if([note isKindOfClass:[Chord class]]){
		[note addNote:newNote];
	} else{
		[newNote setDuration:[note getDuration]];
		[newNote setDotted:[note getDotted]];
		NSMutableArray *chordNotes = [NSMutableArray arrayWithObjects:note, newNote, nil];
		Chord *chord = [[[Chord alloc] initWithStaff:staff withNotes:chordNotes] autorelease];
		[notes replaceObjectAtIndex:index withObject:chord];
	}
}

- (void)removeNote:(NoteBase *)note fromChordAtIndex:(float)index{
	NoteBase *chord = [notes objectAtIndex:index];
	if([chord isKindOfClass:[Chord class]]){
		if([[chord getNotes] containsObject:note]){
			if([[chord getNotes] count] > 2){
				[chord removeNote:note];
			} else{
				Note *otherNote = nil;
				NSEnumerator *chordNotes = [[chord getNotes] objectEnumerator];
				while(otherNote = [chordNotes nextObject]){
					if(otherNote != note){
						[notes replaceObjectAtIndex:index withObject:otherNote];
						break;
					}
				}
			}
		}
	} else{
		[self removeNoteAtIndex:index temporary:NO];
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

- (int)indexInStaff{
	return [[[self getStaff] getMeasures] indexOfObject:self];
}

- (BOOL)isStartRepeat{
	return [[[self getStaff] getSong] repeatStartsAt:[self indexInStaff]];
}

- (BOOL)isEndRepeat{
	return [[[self getStaff] getSong] repeatEndsAt:[self indexInStaff]];
}

- (int)getNumRepeats{
	return [[[self getStaff] getSong] numRepeatsEndingAt:[self indexInStaff]];
}

- (void)setStartRepeat:(BOOL)_startRepeat{
	if(_startRepeat){
		[[self undoManager] setActionName:@"inserting repeat"];
		[[[self getStaff] getSong] startNewRepeatAt:[self indexInStaff]];		
	} else {
		[[self undoManager] setActionName:@"removing repeat"];
		[[[self getStaff] getSong] removeRepeatStartingAt:[self indexInStaff]];
	}
}

- (void)setEndRepeat:(int)_numRepeats{
	if([self isEndRepeat]){
		[[self undoManager] setActionName:@"setting repeat number"];
	} else {		
		[[self undoManager] setActionName:@"inserting repeat"];
		[[[self getStaff] getSong] endRepeatAt:[self indexInStaff]];
	}
	[[[self getStaff] getSong] setNumRepeatsEndingAt:[self indexInStaff] to:_numRepeats];
}

- (void)removeEndRepeat{
	[[self undoManager] setActionName:@"removing repeat"];
	[[[self getStaff] getSong] removeEndRepeatAt:[self indexInStaff]];
}

- (BOOL)followsOpenRepeat{
	return [[[self getStaff] getSong] repeatIsOpenAt:[self indexInStaff]];
}

- (Clef *)getClef{
	return clef;
}

- (DrumKit *)getDrumKit{
	return drumKit;
}

- (Clef *)getEffectiveClef{
	return [staff getClefForMeasure:self];
}

- (void)setClef:(Clef *)_clef{
	if(![clef isEqual:_clef]){
		[[[self undoManager] prepareWithInvocationTarget:self] setClef:clef];
		[clef release];
		clef = [_clef retain];
		[self sendChangeNotification];
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
		[[[self undoManager] prepareWithInvocationTarget:self] setKeySignature:keySig];
		[keySig release];
		keySig = [_sig retain];
		[self updateKeySigPanel];
		[self sendChangeNotification];
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

- (void)updateTimeSigPanel{
	TimeSignature *sig = [self getEffectiveTimeSignature];
	int top = [sig getTop];
	int bottom = [sig getBottom];
	[timeSigTopStep setIntValue:top];
	[timeSigTopText setIntValue:top];
	[timeSigBottom selectItemWithTitle:[NSString stringWithFormat:@"%d", bottom]];
	[[timeSigPanel superview] setNeedsDisplay:YES];
}

- (void)timeSignatureChangedFrom:(float)oldTotal to:(float)newTotal top:(int)top bottom:(int)bottom{
	if(newTotal < oldTotal){
		[self prepUndo];
		[self refreshNotes:nil];
	} else{
		[self prepUndo];
		[self grabNotesFromNextMeasure];
	}
	[self updateTimeSigPanel];
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
	[[self undoManager] setActionName:@"changing key signature"];
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

- (void)updateKeySigPanel{
	int index;
	BOOL minor;
	KeySignature *sig = [self getEffectiveKeySignature];
	[keySigLetter selectItemAtIndex:[sig getIndexFromA]];
	if([sig isMinor]){
		[keySigMajMin selectItemAtIndex:1];
	} else{
		[keySigMajMin selectItemAtIndex:0];
	}
}

- (IBAction)timeSigTopChanged:(id)sender{
	[[self undoManager] setActionName:@"changing time signature"];
	int value = [sender intValue];
	if(value < 1) value = 1;
	[timeSigTopStep setIntValue:value];
	[timeSigTopText setIntValue:value];
	[staff timeSigChangedAtMeasure:self top:[timeSigTopText intValue] bottom:[[[timeSigBottom selectedItem] title] intValue]];
}

- (IBAction)timeSigBottomChanged:(id)sender{
	[[self undoManager] setActionName:@"changing time signature"];
	[staff timeSigChangedAtMeasure:self top:[timeSigTopText intValue] bottom:[[[timeSigBottom selectedItem] title] intValue]];
}

- (void)timeSigDelete{
	[staff timeSigDeletedAtMeasure:self];
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
	[coder encodeObject:drumKit forKey:@"drumKit"];
	if(keySig != nil){
		[coder encodeInt:[keySig getNumFlats] forKey:@"keySigFlats"];
		[coder encodeInt:[keySig getNumSharps] forKey:@"keySigSharps"];
		[coder encodeBool:[keySig isMinor] forKey:@"keySigMinor"];
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
		drumKit = [coder decodeObjectForKey:@"drumKit"];
		int flats = [coder decodeIntForKey:@"keySigFlats"];
		int sharps = [coder decodeIntForKey:@"keySigSharps"];
		BOOL minor = [coder decodeBoolForKey:@"keySigMinor"];
		if(flats > 0){
			[self setKeySignature:[KeySignature getSignatureWithFlats:flats minor:minor]];
		} else if(sharps > 0){
			[self setKeySignature:[KeySignature getSignatureWithSharps:sharps minor:minor]];
		} else if([coder decodeBoolForKey:@"keySigC"]){
			[self setKeySignature:[KeySignature getSignatureWithFlats:0 minor:NO]];
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
	if([staff isDrums]){
		return [DrumMeasureDraw class];
	}
	return [MeasureDraw class];
}

- (Class)getControllerClass{
	if([staff isDrums]){
		return [DrumMeasureController class];
	}
	return [MeasureController class];
}

@end
