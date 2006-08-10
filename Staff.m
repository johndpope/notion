//
//  Staff.m
//  Music Editor
//
//  Created by Konstantine Prevas on 5/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Staff.h"
#import "Measure.h"
#import "Clef.h"
#import "Song.h"
#import "KeySignature.h"
#import "TimeSignature.h"

@implementation Staff

- (id)initWithSong:(Song *)_song{
	if((self = [super init])){
		Measure *firstMeasure = [[Measure alloc] initWithStaff:self];
		[firstMeasure setClef:[Clef trebleClef]];
		[firstMeasure setKeySignature:[KeySignature getSignatureWithFlats:0]];
		measures = [[NSMutableArray arrayWithObject:firstMeasure] retain];
		song = _song;
	}
	return self;
}

- (void)setSong:(Song *)_song{
	song = _song;
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

- (IBAction)setChannel:(id)sender{
	channel = [[channelButton titleOfSelectedItem] intValue] - 1;
}

- (IBAction)deleteSelf:(id)sender{
	[rulerView removeFromSuperview];
	[song removeStaff:self];
}

- (Clef *)getClefForMeasure:(Measure *)measure{
	int index = [measures indexOfObject:measure];
	while([measure getClef] == nil){
		if(index == 0) return [Clef trebleClef];
		index--;
		measure = [measures objectAtIndex:index];
	}
	return [measure getClef];
}

- (KeySignature *)getKeySignatureForMeasure:(Measure *)measure{
	int index = [measures indexOfObject:measure];
	while([measure getKeySignature] == nil){
		if(index == 0) return [KeySignature getSignatureWithSharps:0];
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

- (Measure *)getLastMeasure{
	return [measures lastObject];
}

- (Measure *)getMeasureBefore:(Measure *)measure{
	int index = [measures indexOfObject:measure];
	if(index > 0){
		return [measures objectAtIndex:(index - 1)];
	} else{
		return nil;
	}
}

- (Measure *)getMeasureAfter:(Measure *)measure{
	int index = [measures indexOfObject:measure];
	if(index + 1 < [measures count]){
		return [measures objectAtIndex:(index + 1)];
	} else{
		measure = [[Measure alloc] initWithStaff:self];
		[measures addObject:measure];
		[song refreshTimeSigs];
		[song refreshTempoData];
		return measure;
	}
}

- (Measure *)getMeasureContainingNote:(Note *)note{
	NSEnumerator *measuresEnum = [measures objectEnumerator];
	id measure;
	while(measure = [measuresEnum nextObject]){
		if([[measure getNotes] containsObject:note]){
			return measure;
		}
	}
	return nil;
}

- (void)cleanEmptyMeasures{
	while([measures count] > 1 && [[measures lastObject] isEmpty]){
		Measure *measure = [measures lastObject];
		[measure keySigClose:nil];
		[measures removeLastObject];
	}
	[song refreshTimeSigs];
	[song refreshTempoData];
}

- (Note *)findPreviousNoteMatching:(Note *)source inMeasure:(Measure *)measure atIndex:(int)index{
	if([measure getFirstNote] == source){
		Measure *prevMeasure = [[measure getStaff] getMeasureBefore:measure];
		if(prevMeasure != nil){
			Note *note = [[prevMeasure getNotes] lastObject];
			if([note isEqualTo:source]){
				return note;
			}
		}
		return nil;
	} else{
		Note *note = [measure getNoteBefore:source];
		if([note isEqualTo:source]){
			return note;
		}
		return nil;
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
	int transposeAmount = [newClef getTranspositionFrom:oldClef];
	int index = [measures indexOfObject:measure] + 1;
	[measure transposeBy:transposeAmount];
	if(index < [measures count]){
		while(index < [measures count]){
			measure = [measures objectAtIndex:index++];
			if([measure getClef] != nil) break;
			[measure transposeBy:transposeAmount];
		}
	}
}

- (void)timeSigChangedAtMeasure:(Measure *)measure top:(int)top bottom:(int)bottom{
	[song timeSigChangedAtIndex:[measures indexOfObject:measure]
		top:(int)top bottom:(int)bottom];
}

- (void)cleanPanels{
	NSEnumerator *measureEnum = [measures objectEnumerator];
	id measure;
	while(measure = [measureEnum nextObject]){
		[measure cleanPanels];
	}
}

- (void)addTrackToMIDISequence:(MusicSequence *)musicSequence{
	MusicTrack musicTrack;
	if (MusicSequenceNewTrack(*musicSequence, &musicTrack) != noErr) {
		NSLog(@"Cannot create music track.");
		return;
	}
  
	NSEnumerator *measureEnum = [measures objectEnumerator];
	id measure;
	float pos = 0.0;
	while(measure = [measureEnum nextObject]){
		pos += [measure addToMIDITrack:&musicTrack atPosition:pos
				onChannel:channel];
	}

	MIDIMetaEvent metaEvent = { 0x2f, 0, 0, 0, 0, { 0 } };
	if (MusicTrackNewMetaEvent(musicTrack, 13.0, &metaEvent) != noErr) {
		NSLog(@"Cannot add end of track meta event to track.");
		return;
	}

}

- (void)encodeWithCoder:(NSCoder *)coder{
	[coder encodeObject:measures forKey:@"measures"];
	[coder encodeInt:channel forKey:@"channel"];
}

- (id)initWithCoder:(NSCoder *)coder{
	if(self = [super init]){
		[self setMeasures:[coder decodeObjectForKey:@"measures"]];
		channel = [coder decodeIntForKey:@"channel"];
	}
	return self;
}

- (void)dealloc{
	[measures release];
	measures = nil;
	song = nil;
	[super dealloc];
}

@end
