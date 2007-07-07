//
//  Staff.m
//  Music Editor
//
//  Created by Konstantine Prevas on 5/7/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "Staff.h"
#import "Measure.h"
#import "Clef.h"
#import "DrumKit.h"
#import "Song.h"
#import "KeySignature.h"
#import "ChromaticKeySignature.h"
#import "TimeSignature.h"
#import <Chomp/Chomp.h>
@class StaffDraw;
@class DrumStaffDraw;
@class StaffController;

@implementation Staff

- (id)initWithSong:(Song *)_song{
	if((self = [super init])){
		Measure *firstMeasure = [[Measure alloc] initWithStaff:self];
		[firstMeasure setClef:[Clef trebleClef]];
		[firstMeasure setKeySignature:[KeySignature getSignatureWithFlats:0 minor:NO]];
		measures = [[NSMutableArray arrayWithObject:firstMeasure] retain];
		song = _song;
		canMute = YES;
	}
	return self;
}

- (NSUndoManager *)undoManager{
	return [[song document] undoManager];
}

- (void)sendChangeNotification{
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"modelChanged" object:self]];
}

- (void)setSong:(Song *)_song{
	song = _song;
}

- (Song *)getSong{
	return song;
}

- (NSString *)name{
	return name;
}

- (void)setName:(NSString *)_name{
	if(![name isEqualToString:_name]){
		[name release];
		name = [_name retain];
	}
}

- (int)transposition{
	return transposition;
}

- (void)setTransposition:(int)_transposition{
	[[[self undoManager] prepareWithInvocationTarget:self] setTransposition:transposition];
	transposition = _transposition;
}

- (NSMutableArray *)getMeasures{
	return measures;
}

- (void)setMeasures:(NSMutableArray *)_measures{
	if(![measures isEqual:_measures]){
		[measures release];
		measures = [_measures retain];
	}
}

- (StaffVerticalRulerComponent *)rulerView{
	return rulerView;
}

- (BOOL)isDrums{
	return channel == 9;
}

- (void)setIsDrums:(BOOL)isDrums{
	// do nothing - KVO compliance only
}

- (IBAction)editDrumKit:(id)sender{
	[[self undoManager] beginUndoGrouping];
	[NSBundle loadNibNamed:@"DrumKitDialog" owner:[self drumKit]];
	[NSApp beginSheet:[[self drumKit] editDialog] modalForWindow:[[[self getSong] document] windowForSheet]
		modalDelegate:[self drumKit] didEndSelector:@selector(endEditDialog) contextInfo:nil];
}

- (IBAction)deleteSelf:(id)sender{
	[rulerView removeFromSuperview];
	[song removeStaff:self];
}

- (DrumKit *)drumKit{
	if(drumKit == nil){
		drumKit = [[[DrumKit standardKit] copy] retain];
		[drumKit setStaff:self];
	}
	return drumKit;
}

- (Clef *)getClefForMeasure:(Measure *)measure{
	int index = [measures indexOfObject:measure];
	if([self isDrums]){
		return [self drumKit];
	} else {
		while([measure getClef] == nil){
			if(index == 0) return [Clef trebleClef];
			index--;
			measure = [measures objectAtIndex:index];
		}
		return [measure getClef];		
	}
}

- (KeySignature *)getKeySignatureForMeasure:(Measure *)measure{
	if([self isDrums]){
		return [ChromaticKeySignature instance];
	}
	int index = [measures indexOfObject:measure];
	while([measure getKeySignature] == nil){
		if(index == 0) return [KeySignature getSignatureWithSharps:0 minor:NO];
		index--;
		measure = [measures objectAtIndex:index];
	}
	return [measure getKeySignature];
}

- (TimeSignature *)getTimeSignatureForMeasure:(Measure *)measure{
	return [song getTimeSignatureAt:[measures indexOfObject:measure]];
}

- (TimeSignature *)getEffectiveTimeSignatureForMeasure:(Measure *)measure{
	int index = [measures indexOfObject:measure];
	return [song getEffectiveTimeSignatureAt:index];
}

- (BOOL)isCompoundTimeSignatureAt:(Measure *)measure{
	int index = [measures indexOfObject:measure];
	return [song isCompoundTimeSignatureAt:index];
}

- (Measure *)getLastMeasure{
	return [measures lastObject];
}

- (Measure *)getMeasureAtIndex:(unsigned)index{
	if([measures count] <= index){
		return nil;
	}
	return [measures objectAtIndex:index];
}

- (Measure *)getMeasureBefore:(Measure *)measure{
	int index = [measures indexOfObject:measure];
	if(index > 0){
		return [measures objectAtIndex:(index - 1)];
	} else{
		return nil;
	}
}

- (Measure *)getMeasureWithKeySignatureBefore:(Measure *)measure{
	Measure *prev = [self getMeasureBefore:measure];
	while(prev != nil && [prev getTimeSignature] == nil){
		prev = [self getMeasureBefore:prev];
	}
	return prev;
}

- (Measure *)addMeasure{
	Measure *measure = [[Measure alloc] initWithStaff:self];
	[self addMeasure:measure];
	return measure;
}

- (void)addMeasure:(Measure *)measure{
	if(![measures containsObject:measure]){
		[[[self undoManager] prepareWithInvocationTarget:self] removeMeasure:measure];
		[measures addObject:measure];
		[song refreshTimeSigs];
		[song refreshTempoData];
	}
}

- (void)removeMeasure:(Measure *)measure{
	if([measures containsObject:measure]){
		[[[self undoManager] prepareWithInvocationTarget:self] addMeasure:measure];
		[measures removeObject:measure];		
		[song refreshTimeSigs];
		[song refreshTempoData];
	}
}

- (Measure *)getMeasureAfter:(Measure *)measure createNew:(BOOL)createNew{
	int index = [measures indexOfObject:measure];
	if(index + 1 < [measures count]){
		return [measures objectAtIndex:(index + 1)];
	} else{
		if(createNew){
			return [self addMeasure];
		} else {
			return nil;
		}
	}
}

- (Measure *)getMeasureContainingNote:(NoteBase *)note{
	NSEnumerator *measuresEnum = [measures objectEnumerator];
	id measure;
	while(measure = [measuresEnum nextObject]){
		int i;
		for(i=0; i<[[measure getNotes] count]; i++){
			NoteBase *currNote = [[measure getNotes] objectAtIndex:i];
			if(currNote == note || ([currNote isKindOfClass:[Chord class]] && [[currNote getNotes] containsObject:note])){
				return measure;
			}
		}
	}
	return nil;
}

- (Chord *)getChordContainingNote:(NoteBase *)noteToFind{
	NSEnumerator *measuresEnum = [measures objectEnumerator];
	id measure;
	while(measure = [measuresEnum nextObject]){
		NSEnumerator *notes = [[measure getNotes] objectEnumerator];
		id note;
		while(note = [notes nextObject]){
			if([note isKindOfClass:[Chord class]] &&
			   [[note getNotes] containsObject:noteToFind]){
				return note;
			}			
		}
	}
	return nil;
}

- (void)removeLastNote{
	Measure *measure = [measures lastObject];
	while(measure != [measures objectAtIndex:0] && [[measure getNotes] count] == 0){
		measure = [measures objectAtIndex:([measures indexOfObject:measure] - 1)];
	}
	[[measure getNotes] removeLastObject];
}

- (void)cleanEmptyMeasures{
	while([measures count] > 1 && [[measures lastObject] isEmpty]){
		Measure *measure = [measures lastObject];
		[measure keySigClose:nil];
		[self removeMeasure:measure];
	}
	[song refreshTimeSigs];
	[song refreshTempoData];
}

- (Note *)findPreviousNoteMatching:(Note *)source inMeasure:(Measure *)measure{
	if([measure getFirstNote] == source || 
	   ([[measure getFirstNote] isKindOfClass:[Chord class]] && [[[measure getFirstNote] getNotes] containsObject:source])){
		Measure *prevMeasure = [[measure getStaff] getMeasureBefore:measure];
		if(prevMeasure != nil){
			NoteBase *note = [[prevMeasure getNotes] lastObject];
			if([note respondsToSelector:@selector(pitchMatches:)] && [note pitchMatches:source]){
				return note;
			}
			if([note isKindOfClass:[Chord class]]){
				return [note getNoteMatching:source];
			}
		}
		return nil;
	} else{
		NoteBase *note = [measure getNoteBefore:source];
		if([note respondsToSelector:@selector(pitchMatches:)] && [note pitchMatches:source]){
			return note;
		}
		if([note isKindOfClass:[Chord class]]){
			return [note getNoteMatching:source];
		}
		return nil;
	}
}

- (NoteBase *)noteBefore:(NoteBase *)note{
	NSEnumerator *measureEnum = [measures objectEnumerator];
	id measure;
	while((measure = [measureEnum nextObject]) && ![[measure getNotes] containsObject:note]);
	if(measure != nil){
		if([measure getFirstNote] == note){
			if(measure == [measures objectAtIndex:0]){
				return nil;
			}
			return [[[measures objectAtIndex:([measures indexOfObject:measure] - 1)] getNotes] lastObject];
		} else{
			return [[measure getNotes] objectAtIndex:([[measure getNotes] indexOfObject:note] - 1)];
		}
	}
	return nil;
}

- (NoteBase *)noteAfter:(NoteBase *)note{
	NSEnumerator *measureEnum = [measures objectEnumerator];
	id measure;
	while((measure = [measureEnum nextObject]) && ![[measure getNotes] containsObject:note]);
	if(measure != nil){
		if([[measure getNotes] lastObject] == note){
			if(measure == [measures lastObject]){
				return nil;
			}
			Measure *nextMeasure = [measures objectAtIndex:([measures indexOfObject:measure] + 1)];
			if([[nextMeasure getNotes] count] == 0){
				return nil;
			}
			return [[nextMeasure getNotes] objectAtIndex:0];
		} else{
			return [[measure getNotes] objectAtIndex:([[measure getNotes] indexOfObject:note] + 1)];
		}
	}
	return nil;
}

- (NSArray *)notesBetweenSingleNote:(NoteBase *)note1 andNote:(NoteBase *)note2{
	NSMutableArray *between = [NSMutableArray array];
	Measure *measure1 = [self getMeasureContainingNote:note1];
	Measure *measure2 = [self getMeasureContainingNote:note2];
	Measure *firstMeasure = measure1, *lastMeasure = measure2;
	NoteBase *firstNote = note1, *lastNote = note2;
	if([[self getMeasures] indexOfObject:measure1] > [[self getMeasures] indexOfObject:measure2]){
		firstMeasure = measure2;
		lastMeasure = measure1;
		firstNote = note2;
		lastNote = note1;
	}
	if(firstMeasure == lastMeasure && 
	   [[firstMeasure getNotes] indexOfObject:note1] > [[firstMeasure getNotes] indexOfObject:note2]){
		firstNote = note2;
		lastNote = note1;
	}
	int i;
	for(i = [[firstMeasure getNotes] indexOfObject:firstNote]; i < [[firstMeasure getNotes] count]; i++){
		NoteBase *note = [[firstMeasure getNotes] objectAtIndex:i];
		[between addObject:note];
		if(note == lastNote){
			return between;
		}
	}
	Measure *currMeasure;
	for(currMeasure = [self getMeasureAfter:firstMeasure createNew:NO]; currMeasure != lastMeasure; currMeasure = [self getMeasureAfter:currMeasure createNew:NO]){
		[between addObjectsFromArray:[currMeasure getNotes]];
	}
	for(i = 0; i <= [[lastMeasure getNotes] indexOfObject:lastNote]; i++){
		NoteBase *note = [[lastMeasure getNotes] objectAtIndex:i];
		[between addObject:note];
	}
	return between;
}

- (NSArray *)notesBetweenArray:(NSArray *)notes andNote:(NoteBase *)note2{
	NoteBase *firstArrayNote = [notes objectAtIndex:0];
	NoteBase *lastArrayNote = [notes lastObject];
	Measure *firstArrayMeasure = [self getMeasureContainingNote:firstArrayNote];
	Measure *lastArrayMeasure = [self getMeasureContainingNote:lastArrayNote];
	Measure *secondNoteMeasure = [self getMeasureContainingNote:note2];
	if([[self getMeasures] indexOfObject:secondNoteMeasure] < [[self getMeasures] indexOfObject:firstArrayMeasure]){
		return [self notesBetweenSingleNote:note2 andNote:lastArrayNote];
	}
	if([[self getMeasures] indexOfObject:secondNoteMeasure] > [[self getMeasures] indexOfObject:lastArrayMeasure]){
		return [self notesBetweenSingleNote:firstArrayNote andNote:note2];
	}
	if(secondNoteMeasure == firstArrayMeasure){
		if([[secondNoteMeasure getNotes] indexOfObject:note2] >= [[secondNoteMeasure getNotes] indexOfObject:firstArrayNote]){
			return [self notesBetweenSingleNote:firstArrayNote andNote:note2];
		}
		return [self notesBetweenSingleNote:note2 andNote:lastArrayNote];
	}
	if(secondNoteMeasure == lastArrayMeasure){
		if([[secondNoteMeasure getNotes] indexOfObject:note2] <= [[secondNoteMeasure getNotes] indexOfObject:lastArrayNote]){
			return [self notesBetweenSingleNote:firstArrayNote andNote:note2];
		}
		return [self notesBetweenSingleNote:firstArrayNote andNote:note2];
	}
	return [self notesBetweenSingleNote:firstArrayNote andNote:note2];
}

- (NSArray *)notesBetweenArray:(NSArray *)notes1 andArray:(NSArray *)notes2{
	NoteBase *firstArray1Note = [notes1 objectAtIndex:0];
	NoteBase *lastArray1Note = [notes1 lastObject];
	Measure *firstArray1Measure = [self getMeasureContainingNote:firstArray1Note];
	Measure *lastArray1Measure = [self getMeasureContainingNote:lastArray1Note];
	NoteBase *firstArray2Note = [notes2 objectAtIndex:0];
	NoteBase *lastArray2Note = [notes2 lastObject];
	Measure *firstArray2Measure = [self getMeasureContainingNote:firstArray2Note];
	Measure *lastArray2Measure = [self getMeasureContainingNote:lastArray2Note];
	NoteBase *firstNote, *lastNote;
	if([[self getMeasures] indexOfObject:firstArray1Measure] < [[self getMeasures] indexOfObject:firstArray2Measure]){
		firstNote = firstArray1Note;
	} else if([[self getMeasures] indexOfObject:firstArray1Measure] > [[self getMeasures] indexOfObject:firstArray2Measure]){
		firstNote = firstArray2Note;
	} else if([[firstArray1Measure getNotes] indexOfObject:firstArray1Note] < [[firstArray1Measure getNotes] indexOfObject:firstArray2Note]){
		firstNote = firstArray1Note;
	} else {
		firstNote = firstArray2Note;
	}
	if([[self getMeasures] indexOfObject:lastArray1Measure] < [[self getMeasures] indexOfObject:lastArray2Measure]){
		lastNote = lastArray2Note;
	} else if([[self getMeasures] indexOfObject:lastArray1Measure] > [[self getMeasures] indexOfObject:lastArray2Measure]){
		lastNote = lastArray1Note;
	} else if([[lastArray1Measure getNotes] indexOfObject:lastArray1Note] < [[lastArray1Measure getNotes] indexOfObject:lastArray2Note]){
		lastNote = lastArray2Note;
	} else {
		lastNote = lastArray1Note;
	}
	return [self notesBetweenSingleNote:firstNote andNote:lastNote];
}

- (NSArray *)notesBetweenNote:(id)note1 andNote:(id)note2{
	if([note1 respondsToSelector:@selector(containsObject:)]){
		if([note2 respondsToSelector:@selector(containsObject:)]){
			return [self notesBetweenArray:note1 andArray:note2];
		}
		return [self notesBetweenArray:note1 andNote:note2];
	} else {
		if([note2 respondsToSelector:@selector(containsObject:)]){
			return [self notesBetweenArray:note2 andNote:note1];
		}
		return [self notesBetweenSingleNote:note1 andNote:note2];
	}
}

- (void)toggleClefAtMeasure:(Measure *)measure{
	Clef *oldClef = [measure getClef];
	if(oldClef != nil && measure != [measures objectAtIndex:0]){
		[measure setClef:nil];
	} else{
		oldClef = [self getClefForMeasure:measure];
		[measure setClef:[Clef getClefAfter:oldClef]];
	}
	Clef *newClef = [self getClefForMeasure:measure];
	int numLines = [newClef getTranspositionFrom:oldClef];
	int index = [measures indexOfObject:measure] + 1;
	[measure transposeBy:numLines];
	if(index < [measures count]){
		while(index < [measures count]){
			measure = [measures objectAtIndex:index++];
			if([measure getClef] != nil) break;
			[measure transposeBy:numLines];
		}
	}
}

- (void)timeSigChangedAtMeasure:(Measure *)measure top:(int)top bottom:(int)bottom{
	[song timeSigChangedAtIndex:[measures indexOfObject:measure]
							top:(int)top bottom:(int)bottom];
}

- (void)timeSigChangedAtMeasure:(Measure *)measure top:(int)top bottom:(int)bottom secondTop:(int)secondTop secondBottom:(int)secondBottom{
	[song timeSigChangedAtIndex:[measures indexOfObject:measure]
							top:(int)top bottom:(int)bottom
					  secondTop:(int)secondTop secondBottom:(int)secondBottom];
}

- (void)timeSigDeletedAtMeasure:(Measure *)measure{
	if(measure != [measures objectAtIndex:0]){
		[song timeSigDeletedAtIndex:[measures indexOfObject:measure]];		
	}
}

- (void)transposeFrom:(KeySignature *)oldSig to:(KeySignature *)newSig startingAt:(Measure *)measure{
	int transposeAmount = [newSig distanceFrom:oldSig];
	do {
		[measure transposeBy:transposeAmount oldSignature:oldSig newSignature:newSig];
		measure = [[measure getStaff] getMeasureAfter:measure createNew:NO];
	} while(measure != nil && [measure getKeySignature] == nil);
}

- (void)cleanPanels{
	NSEnumerator *measureEnum = [measures objectEnumerator];
	id measure;
	while(measure = [measureEnum nextObject]){
		[measure cleanPanels];
	}
}

- (BOOL)canMute{
	return canMute && !solo;
}

- (BOOL)canSolo{
	return canMute;
}

- (void)setCanMute:(BOOL)enabled{
	canMute = enabled;
}

- (BOOL)mute{
	return mute;
}

- (BOOL)solo{
	return solo;
}

- (void)setMute:(BOOL)_mute{
	mute = _mute;
}

- (void)setSolo:(BOOL)_solo{
	solo = _solo;
	if(solo){
		[self setMute:NO];
	}
	[song soloPressed:solo onStaff:self];
}

- (int)channel{
	return channel + 1;
}

- (int)realChannel{
	return channel;
}

- (void)setChannel:(int)_channel{
	[[[self undoManager] prepareWithInvocationTarget:self] setChannel:(channel + 1)];
	channel = _channel - 1;
	[self setIsDrums:[self isDrums]]; //trigger KVO
	[self sendChangeNotification];
}

- (float)addTrackToMIDISequence:(MusicSequence *)musicSequence notesToPlay:(id)selection{
	if (MusicSequenceNewTrack(*musicSequence, &musicTrack) != noErr) {
		NSLog(@"Cannot create music track.");
		return 0;
	}
  
	NSEnumerator *measureEnum = [measures objectEnumerator];
	id measure;
	float pos = 0.0;
	BOOL isRepeating;
	NSMutableArray *repeatMeasures = [NSMutableArray array];
	while(measure = [measureEnum nextObject]){
		if([measure isStartRepeat]){
			isRepeating = YES;
		}
		pos += [measure addToMIDITrack:&musicTrack atPosition:pos transpose:transposition
							 onChannel:channel notesToPlay:selection];
		if(isRepeating){
			[repeatMeasures addObject:measure];
		}
		if([measure isEndRepeat]){
			isRepeating = NO;
			int i;
			for(i = 1; i < [measure getNumRepeats]; i++){
				NSEnumerator *repeatMeasuresEnum = [repeatMeasures objectEnumerator];
				id repeatMeasure;
				while(repeatMeasure = [repeatMeasuresEnum nextObject]){
					pos += [repeatMeasure addToMIDITrack:&musicTrack atPosition:pos transpose:transposition
											   onChannel:channel notesToPlay:selection];
				}
			}
			[repeatMeasures removeAllObjects];
		}
	}

	MIDIMetaEvent metaEvent = { 0x2f, 0, 0, 0, 0, { 0 } };
	if (MusicTrackNewMetaEvent(musicTrack, pos, &metaEvent) != noErr) {
		NSLog(@"Cannot add end of track meta event to track.");
		return 0;
	}

	return pos;
}

- (void)addToLilypondString:(NSMutableString *)string{
	if([self isDrums]){
		[string appendString:@"\\new DrumStaff {\n\\drummode{\n"];
	} else {
		[string appendString:@"\\new Staff {\n"];
	}
	if([[self name] length] > 0){
		[string appendFormat:@"\\set Staff.instrumentName = \"%@\"\n", [self name]];
	}
	[[measures do] addToLilypondString:string];
	[string appendString:@"}\n"];
	if([self isDrums]){
		[string appendString:@"}\n"];
	}
}

- (void)addToMusicXMLString:(NSMutableString *)string{
	[[measures do] addToMusicXMLString:string];
}

- (void)encodeWithCoder:(NSCoder *)coder{
	[coder encodeObject:measures forKey:@"measures"];
	[coder encodeInt:channel forKey:@"channel"];
	[coder encodeInt:transposition forKey:@"transposition"];
	[coder encodeObject:name forKey:@"name"];
	[coder encodeObject:drumKit forKey:@"drumKit"];
}

- (id)initWithCoder:(NSCoder *)coder{
	if(self = [super init]){
		[self setMeasures:[coder decodeObjectForKey:@"measures"]];
		[self setChannel:([coder decodeIntForKey:@"channel"] + 1)];
		[self setTransposition:[coder decodeIntForKey:@"transposition"]];
		[self setName:[coder decodeObjectForKey:@"name"]];
		drumKit = [coder decodeObjectForKey:@"drumKit"];
		[drumKit setStaff:self];
		canMute = YES;
	}
	return self;
}

- (void)dealloc{
	[measures release];
	[drumKit release];
	measures = nil;
	drumKit = nil;
	song = nil;
	[super dealloc];
}

- (Class)getViewClass{
	if([self isDrums]){
		return [DrumStaffDraw class];
	}
	return [StaffDraw class];
}
- (Class)getControllerClass{
	return [StaffController class];
}

- (NSString *) description {
	NSMutableString *str = [NSMutableString string];
	[self addToMusicXMLString:str];
	return str;
}

@end
