//
//  Note.m
//  Music Editor
//
//  Created by Konstantine Prevas on 5/7/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "Note.h"
#import "KeySignature.h"
@class NoteDraw;

@implementation Note

- (id)initWithPitch:(int)_pitch octave:(int)_octave 
	duration:(int)_duration dotted:(BOOL)_dotted accidental:(int)_accidental onStaff:(Staff *)_staff{
	if(self = [super init]){
		lastPitch = pitch = _pitch;
		lastOctave = octave = _octave;
		duration = _duration;
		dotted = _dotted;
		accidental = _accidental;
		staff = _staff;
		tieTo = nil;
		tieFrom = nil;
	}
	return self;
}

- (int)getDuration{
	return duration;
}
- (BOOL)getDotted{
	return dotted;
}
- (int)getPitch{
	return pitch;
}
- (int)getOctave{
	return octave;
}
- (int)getAccidental{
	return accidental;
}
- (int)getLastPitch{
	return lastPitch;
}
- (int)getLastOctave{
	return lastOctave;
}

- (void)setOctave:(int)_octave finished:(BOOL)finished{
	if(finished){
		[[[self undoManager] prepareWithInvocationTarget:self] setOctave:lastOctave finished:YES];	
		if(lastOctave != _octave){
			[[self getTieFrom] tieTo:nil];
			[self tieFrom:nil];
			[[self getTieTo] tieFrom:nil];
			[self tieTo:nil];
		}
		lastOctave = _octave;
	}
	octave = _octave;
	[self sendChangeNotification];
}
- (void)setPitch:(int)_pitch finished:(BOOL)finished{
	if(finished){
		[[[self undoManager] prepareWithInvocationTarget:self] setPitch:lastPitch finished:YES];
		if(lastPitch != _pitch){
			[[self getTieFrom] tieTo:nil];
			[self tieFrom:nil];
			[[self getTieTo] tieFrom:nil];
			[self tieTo:nil];
		}
		lastPitch = _pitch;
	}
	pitch = _pitch;
	[self sendChangeNotification];
}
- (void)setAccidental:(int)_accidental{
	[[[self undoManager] prepareWithInvocationTarget:self] setAccidental:accidental];
	accidental = _accidental;
	[self sendChangeNotification];
}

- (id)copyWithZone:(NSZone *)zone{
	return [[Note allocWithZone:zone] initWithPitch:pitch
		octave:octave duration:duration dotted:dotted
		accidental:accidental onStaff:staff];
}

- (BOOL)isEqualTo:(id)obj{
	return [obj isKindOfClass:[Note class]] &&
		[obj getPitch] == pitch && [obj getOctave] == octave &&
		[obj getDuration] == duration && [obj getDotted] == dotted &&
		[obj getAccidental] == accidental;
}

- (int)getEffectivePitchWithKeySignature:(KeySignature *)keySig priorAccidentals:(NSMutableDictionary *)accidentals{
	int effPitch = octave * 12 + [keySig getPitchAtPosition:pitch];
	int effAccidental = accidental;
	if(accidentals != nil){
		if(effAccidental == NO_ACC){
			NSNumber *effAccGet = [accidentals objectForKey:[[[NSNumber alloc] initWithInt:(octave * 7 + pitch)] autorelease]];
			if(effAccGet != nil){
				effAccidental = [effAccGet intValue];
			}
		} else{
			[accidentals setObject:[[[NSNumber alloc] initWithInt:accidental] autorelease] forKey:[[[NSNumber alloc] initWithInt:(octave * 7 + pitch)] autorelease]];
		}
	}
	if(effAccidental != NO_ACC){
		int keySigAcc = [keySig getAccidentalAtPosition:pitch];
		if(keySigAcc != NO_ACC){
			effAccidental -= keySigAcc;
		}
		effPitch += effAccidental;
	}
	return effPitch;
}

- (BOOL)pitchMatches:(Note *)note{
	return [note getEffectivePitchWithKeySignature:[[[note getStaff] getMeasureContainingNote:note] getEffectiveKeySignature] priorAccidentals:nil] == [self getEffectivePitchWithKeySignature:[[[self getStaff] getMeasureContainingNote:self] getEffectiveKeySignature] priorAccidentals:nil];
}

- (BOOL)isHigherThan:(Note *)note{
	return [note getEffectivePitchWithKeySignature:[[[note getStaff] getMeasureContainingNote:note] getEffectiveKeySignature] priorAccidentals:nil] < [self getEffectivePitchWithKeySignature:[[[self getStaff] getMeasureContainingNote:self] getEffectiveKeySignature] priorAccidentals:nil];
}

- (BOOL)isLowerThan:(Note *)note{
	return [note getEffectivePitchWithKeySignature:[[[note getStaff] getMeasureContainingNote:note] getEffectiveKeySignature] priorAccidentals:nil] > [self getEffectivePitchWithKeySignature:[[[self getStaff] getMeasureContainingNote:self] getEffectiveKeySignature] priorAccidentals:nil];
}

- (BOOL)isDrawBars{
	return [self getDuration] > 4;
}

- (float)addToMIDITrack:(MusicTrack *)musicTrack atPosition:(float)pos withKeySignature:(KeySignature *)keySig 
			accidentals:(NSMutableDictionary *)accidentals transpose:(int)transposition onChannel:(int)channel{
	if(tieFrom != nil) return 4.0 * [self getEffectiveDuration] / 3;
	MIDINoteMessage note;
	note.channel = channel;
	note.velocity = 100.00;
	note.duration = 4.0 * [self getEffectiveDuration] / 3;
	Note *tie = tieTo;
	while(tie != nil){
		note.duration += 4.0 * [tie getEffectiveDuration] / 3;
		tie = [tie getTieTo];
	}
	note.note = [self getEffectivePitchWithKeySignature:keySig priorAccidentals:accidentals] + transposition;
	if (MusicTrackNewMIDINoteEvent(*musicTrack, pos, &note) != noErr) {
		NSLog(@"Cannot add note to track.");
    }
	return 4.0 * [self getEffectiveDuration] / 3;
}

- (void)tieTo:(NoteBase *)note{
	[[[self undoManager] prepareWithInvocationTarget:self] tieTo:tieTo];
	if(![tieTo isEqual:note]){
		[tieTo release];
		tieTo = [note retain];
	}
}

- (NoteBase *)getTieTo{
	return tieTo;
}

- (void)tieFrom:(NoteBase *)note{
	[[[self undoManager] prepareWithInvocationTarget:self] tieFrom:tieFrom];
	if(![tieFrom isEqual:note]){
		[tieFrom release];
		tieFrom = [note retain];
	}
}

- (NoteBase *)getTieFrom{
	return tieFrom;
}

- (void)transposeBy:(int)numLines{
	int newPitch = pitch;
	int newOctave = octave;
	newPitch += numLines;
	while(newPitch >= 7){
		newPitch -= 7;
		newOctave++;
	}
	while(newPitch < 0){
		newPitch += 7;
		newOctave--;
	}
	[self setPitch:newPitch finished:YES];
	[self setOctave:newOctave finished:YES];
}

- (void)transposeBy:(int)numHalfSteps oldSignature:(KeySignature *)oldSig newSignature:(KeySignature *)newSig{
	int effectivePitch = [self getEffectivePitchWithKeySignature:oldSig priorAccidentals:nil];
	effectivePitch += numHalfSteps;
	int newOctave = effectivePitch / 12;
	effectivePitch -= newOctave * 12;
	int newPitch = [newSig positionForPitch:effectivePitch preferAccidental:accidental];
	if(effectivePitch == 11 && newPitch == 0) {
		newOctave++;
	}
	int newAccidental = [newSig accidentalForPitch:effectivePitch atPosition:newPitch];
	[self setOctave:newOctave finished:YES];
	[self setPitch:newPitch finished:YES];
	[self setAccidental:newAccidental];
}

- (void)prepareForDelete{
	[[self getTieTo] tieFrom:[self getTieFrom]];
	[[self getTieFrom] tieTo:[self getTieTo]];
}

- (void)collapseOnTo:(Note *)note{
	float effDuration = [self getEffectiveDuration];
	float targetDuration = [note getEffectiveDuration];
	float totalDuration = effDuration + targetDuration;
	//TODO: implement
}

+ (NSPoint)closestNoteTo:(NSPoint)base withRank:(int)rank{
	int pitch = (rank + 5) % 7;
	int octave = base.y;
	if(base.x > pitch && base.x - pitch > (pitch + 7) - base.x){
		octave++;
	}
	if(pitch > base.x && pitch - base.x > (base.x + 7) - pitch){
		octave--;
	}
	return NSMakePoint(pitch, octave);
}

- (NSPoint)closestNoteAtRank:(int)rank{
	return [Note closestNoteTo:NSMakePoint(pitch, octave) withRank:rank];
}

+ (NSPoint)noteAtRank:(int)rank onClef:(Clef *)clef{
	int pitch = [clef getPitchForPosition:4];
	int octave = [clef getOctaveForPosition:4];
	return [Note closestNoteTo:NSMakePoint(pitch, octave) withRank:rank];
}

- (void)encodeWithCoder:(NSCoder *)coder{
	[coder encodeInt:duration forKey:@"duration"];
	[coder encodeBool:dotted forKey:@"dotted"];
	[coder encodeInt:octave forKey:@"octave"];
	[coder encodeInt:pitch forKey:@"pitch"];
	[coder encodeInt:accidental forKey:@"accidental"];
	[coder encodeObject:tieTo forKey:@"tieTo"];
	[coder encodeObject:tieFrom forKey:@"tieFrom"];
}

- (id)initWithCoder:(NSCoder *)coder{
	if(self = [super init]){
		duration = [coder decodeIntForKey:@"duration"];
		dotted = [coder decodeBoolForKey:@"dotted"];
		octave = [coder decodeIntForKey:@"octave"];
		pitch = [coder decodeIntForKey:@"pitch"];
		accidental = [coder decodeIntForKey:@"accidental"];
		[self tieTo:[coder decodeObjectForKey:@"tieTo"]];
		[self tieFrom:[coder decodeObjectForKey:@"tieFrom"]];
	}
	return self;
}

- (void)dealloc{
	tieTo = nil;
	tieFrom = nil;
	[super dealloc];
}

- (Class)getViewClass{
	return [NoteDraw class];
}

@end
