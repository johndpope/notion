//
//  Measure.m
//  Music Editor
//
//  Created by Konstantine Prevas on 5/4/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Measure.h"
#import "Note.h"
#import "Clef.h"
#import "Staff.h"
#import "TimeSignature.h"

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

- (NSMutableArray *)getNotes{
	return notes;
}

- (Note *)getFirstNote{
	return [notes objectAtIndex:0];
}

- (void)setNotes:(NSMutableArray *)_notes{
	if(![notes isEqual:_notes]){
		[notes release];
		notes = [_notes retain];
	}
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

- (Note *)addNotes:(NSArray *)_notes atIndex:(float)index{
	NSEnumerator *notesEnum = [_notes reverseObjectEnumerator];
	Note *note;
	index = ceil(index);
	while(note = [notesEnum nextObject]){
		[notes insertObject:note atIndex:index];
	}
/*	while(![[notes lastObject] isEqual:note]){
		Note *next = [notes objectAtIndex:(index+1.5)];
		if([next isEqual:[note getTieTo]]){
			[next collapseOnTo:note];
			if([next getDuration] == 0){
				[notes removeObject:next];
			} else{
				note = next;
			}
		} else{
			note = nil;
		}
	}*/
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
			Note *lastNote = note;
			while(durationToFill > 0){
				note = [Note tryToFill:durationToFill copyingNote:note];
				[notes insertObject:note atIndex:index];
				[note tieTo:lastNote];
				[lastNote tieFrom:note];
				lastNote = note;
				totalDuration += [note getEffectiveDuration];
				durationToFill -= [note getEffectiveDuration];
			}
		}
		[notes removeLastObject];
		[[staff getMeasureAfter:self] addNotes:_notes atIndex:0];
	}
	return [notes objectAtIndex:index];
}

- (void)grabNotesFromNextMeasure{
	if([staff getLastMeasure] == self) return;
	Measure *nextMeasure = [staff getMeasureAfter:self];
	float totalDuration = [self getTotalDuration];
	float maxDuration = [[self getEffectiveTimeSignature] getMeasureDuration];
	while(totalDuration < maxDuration && ![nextMeasure isEmpty]){
		float durationToFill = maxDuration - totalDuration;
		Note *nextNote = [nextMeasure getFirstNote];
		[nextMeasure removeNoteAtIndex:0 temporary:YES];
		if([nextNote getEffectiveDuration] <= durationToFill){
			[notes addObject:nextNote];
			totalDuration += [nextNote getEffectiveDuration];
		} else{
			NSMutableArray *_notes = [nextNote removeDuration:durationToFill];
			[nextMeasure addNotes:_notes atIndex:0];
			[nextMeasure grabNotesFromNextMeasure];
			Note *tieFrom = [nextNote getTieFrom];
			Note *note = nextNote;
			Note *lastNote = note;
			while(durationToFill > 0){
				note = [Note tryToFill:durationToFill copyingNote:note];
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
	Note *note = [notes objectAtIndex:floor(x)];
	if(!temp){
		[[note getTieTo] tieFrom:[note getTieFrom]];
		[[note getTieFrom] tieTo:[note getTieTo]];
	}
	[notes removeObjectAtIndex:floor(x)];
	[self grabNotesFromNextMeasure];
	if(!temp){
		[staff cleanEmptyMeasures];
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
	return timeSig;
}

- (TimeSignature *)getEffectiveTimeSignature{
	return [staff getTimeSignatureForMeasure:self];
}

- (void)setTimeSignature:(TimeSignature *)_sig{
	if(![timeSig isEqual:_sig]){
		[timeSig release];
		timeSig = [_sig retain];
	}
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

- (Note *)findPreviousNoteMatching:(Note *)source atIndex:(int)index{
	if(index == NSNotFound) index = [notes count];
	index--;
	while(index >= 0){
		Note *note = [notes objectAtIndex:index];
		if([note getOctave] == [source getOctave] &&
			[note getPitch] == [source getPitch]) return note;
		index--;
	}
	return nil;
}

- (float)getNoteStartDuration:(Note *)note{
	float start = 0;
	NSEnumerator *notesEnum = [notes objectEnumerator];
	id currNote;
	while((currNote = [notesEnum nextObject]) && currNote != note){
		start += [currNote getEffectiveDuration];
	}
	return start;
}

- (float)getNoteEndDuration:(Note *)note{
	return [self getNoteStartDuration:note] + [note getEffectiveDuration];
}

- (int)getNumberOfNotesStartingAt:(float)startDuration endingAt:(float)endDuration{
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
	[keySigPanel removeFromSuperview];
}

- (void)timeSigChanged{
	float oldSigTotal = [[self getEffectiveTimeSignature] getMeasureDuration];
	TimeSignature *sig = [TimeSignature timeSignatureWithTop:[timeSigTopText intValue] bottom:[[[timeSigBottom selectedItem] title] intValue]];
	if(![timeSig isEqual:sig]){
		[self setTimeSignature:sig];
		float newSigTotal = [sig getMeasureDuration];
		if(newSigTotal < oldSigTotal){
			[self addNotes:[NSArray array] atIndex:0];
		} else{
			[self grabNotesFromNextMeasure];
		}
		[[timeSigPanel superview] setNeedsDisplay:YES];
	}
}

- (IBAction)timeSigTopChanged:(id)sender{
	int value = [sender intValue];
	if(value < 1) value = 1;
	[timeSigTopStep setIntValue:value];
	[timeSigTopText setIntValue:value];
	[self timeSigChanged];
}

- (IBAction)timeSigBottomChanged:(id)sender{
	[self timeSigChanged];
}

- (IBAction)timeSigClose:(id)sender{
	[timeSigPanel setHidden:YES withFade:YES blocking:(sender != nil)];
	[timeSigPanel removeFromSuperview];
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
	if(timeSig != nil){
		[coder encodeInt:[timeSig getTop] forKey:@"timeSigTop"];
		[coder encodeInt:[timeSig getBottom] forKey:@"timeSigBottom"];
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
		int top = [coder decodeIntForKey:@"timeSigTop"];
		int bottom = [coder decodeIntForKey:@"timeSigBottom"];
		if(top > 0 && bottom > 0){
			[self setTimeSignature:[TimeSignature timeSignatureWithTop:top bottom:bottom]];
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

@end
