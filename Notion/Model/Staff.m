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


@class StaffDraw;
@class DrumStaffDraw;
@class StaffController;

@implementation Staff

- (id)initWithSong:(Song *)_song {
    if ((self = [super init])) {
        song = _song;
        canMute = YES;
        Measure *firstMeasure = [[Measure alloc] initWithStaff:self];
        [firstMeasure setClef:[Clef trebleClef]];
        [firstMeasure setKeySignature:[KeySignature getSignatureWithFlats:0 minor:NO]];
        self.measures = [[NSMutableArray alloc]initWithObjects:firstMeasure, nil];
    }
    
    return self;
}

- (NSUndoManager *)undoManager {
    return nil;//[[song document] undoManager];
}

- (void)sendChangeNotification {
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"modelChanged" object:self]];
}

- (void)setSong:(Song *)_song {
    song = _song;
}

- (Song *)getSong {
    return song;
}

- (NSString *)name {
    return name;
}

- (void)setName:(NSString *)_name {
    if (![name isEqualToString:_name]) {
        name = _name;
    }
}

- (int)transposition {
    return transposition;
}

- (void)setTransposition:(int)_transposition {
    [[[self undoManager] prepareWithInvocationTarget:self] setTransposition:transposition];
    transposition = _transposition;
}

- (StaffVerticalRulerComponent *)rulerView {
    return rulerView;
}

- (BOOL)isDrums {
    return channel == 9;
}

- (void)setIsDrums:(BOOL)isDrums {
    // do nothing - KVO compliance only
}

//- (IBAction)editDrumKit:(id)sender {
//    [[self undoManager] beginUndoGrouping];
//    [NSBundle loadNibNamed:@"DrumKitDialog" owner:[self drumKit]];
//    [NSApp beginSheet:[[self drumKit] editDialog] modalForWindow:[[[self getSong] document] windowForSheet]
//        modalDelegate:[self drumKit] didEndSelector:@selector(endEditDialog) contextInfo:nil];
//}

//- (IBAction)deleteSelf:(id)sender {
//    //  [rulerView removeFromSuperview];
//    [song removeStaff:self];
//}

- (DrumKit *)drumKit {
    if (drumKit == nil) {
        drumKit = [[DrumKit standardKit] copy];
        [drumKit setStaff:self];
    }
    return drumKit;
}

- (Clef *)getClefForMeasure:(Measure *)measure {
    int index = [self.measures indexOfObject:measure];
    if ([self isDrums]) {
        return [self drumKit];
    }
    else {
        while ([measure getClef] == nil) {
            if (index == 0) return [Clef trebleClef];
            index--;
            measure = [self.measures objectAtIndex:index];
        }
        return [measure getClef];
    }
}

- (KeySignature *)getKeySignatureForMeasure:(Measure *)measure {
    if ([self isDrums]) {
        return [ChromaticKeySignature instance];
    }
    int index = [self.measures indexOfObject:measure];
    while ([measure getKeySignature] == nil) {
        if (index == 0) return [KeySignature getSignatureWithSharps:0 minor:NO];
        index--;
        measure = [self.measures objectAtIndex:index];
    }
    return [measure getKeySignature];
}

- (TimeSignature *)getTimeSignatureForMeasure:(Measure *)measure {
    return [song getTimeSignatureAt:[self.measures indexOfObject:measure]];
}

- (TimeSignature *)getEffectiveTimeSignatureForMeasure:(Measure *)measure {
    int index = [self.measures indexOfObject:measure];
    
    return [song getEffectiveTimeSignatureAt:index];
}

- (BOOL)isCompoundTimeSignatureAt:(Measure *)measure {
    int index = [self.measures indexOfObject:measure];
    return [song isCompoundTimeSignatureAt:index];
}

- (Measure *)getLastMeasure {
    return [self.measures lastObject];
}

- (Measure *)getMeasureAtIndex:(unsigned)index {
    if ([self.measures count] <= index) {
        return nil;
    }
    return [self.measures objectAtIndex:index];
}

- (Measure *)getMeasureBefore:(Measure *)measure {
    int index = [self.measures indexOfObject:measure];
    if (index > 0) {
        return [self.measures objectAtIndex:(index - 1)];
    }
    else {
        return nil;
    }
}

- (Measure *)getMeasureWithKeySignatureBefore:(Measure *)measure {
    Measure *prev = [self getMeasureBefore:measure];
    while (prev != nil && [prev getTimeSignature] == nil) {
        prev = [self getMeasureBefore:prev];
    }
    return prev;
}

- (Measure *)addMeasure {
    Measure *measure = [[Measure alloc] initWithStaff:self];
    [self addMeasure:measure];
    return measure;
}

- (void)addMeasure:(Measure *)measure {
    NSLog(@"addMeasure count:%lu",  (unsigned long)self.measures.count);
    
    if (![self.measures containsObject:measure]) {
        [[[self undoManager] prepareWithInvocationTarget:self] removeMeasure:measure];
        [self.measures addObject:measure];
        [song refreshTimeSigs];
        [song refreshTempoData];
    }
}

- (void)removeMeasure:(Measure *)measure {
    if ([self.measures containsObject:measure]) {
        NSLog(@"removeMeasure");
        [[[self undoManager] prepareWithInvocationTarget:self] addMeasure:measure];
        [self.measures removeObject:measure];
        [song refreshTimeSigs];
        [song refreshTempoData];
    }
}

- (Measure *)getMeasureAfter:(Measure *)measure createNew:(BOOL)createNew {
    int index = [self.measures indexOfObject:measure];
    if (index + 1 < [self.measures count]) {
        return [self.measures objectAtIndex:(index + 1)];
    }
    else {
        if (createNew) {
            return [self addMeasure];
        }
        else {
            return nil;
        }
    }
}

- (Measure *)getMeasureContainingNote:(NoteBase *)note {
    NSEnumerator *measuresEnum = [self.measures objectEnumerator];
    Measure *measure;
    while (measure = [measuresEnum nextObject]) {
        int i;
        for (i = 0; i < [measure.notes count]; i++) {
            NoteBase *currNote = [measure.notes objectAtIndex:i];
            if (currNote == note || ([currNote isKindOfClass:[Chord class]] && [[(Chord *)currNote getNotes] containsObject:note])) {
                return measure;
            }
        }
    }
    return nil;
}

- (Chord *)getChordContainingNote:(NoteBase *)noteToFind {
    NSEnumerator *measuresEnum = [self.measures objectEnumerator];
    Measure *measure;
    while (measure = [measuresEnum nextObject]) {
        NSEnumerator *notes = [measure.notes objectEnumerator];
        id note;
        while (note = [notes nextObject]) {
            if ([note isKindOfClass:[Chord class]] &&
                [[note getNotes] containsObject:noteToFind]) {
                return note;
            }
        }
    }
    return nil;
}

- (void)removeLastNote {
    Measure *measure = [self.measures lastObject];
    while (measure != [self.measures objectAtIndex:0] && [measure.notes count] == 0) {
        measure = [self.measures objectAtIndex:([self.measures indexOfObject:measure] - 1)];
    }
    [measure.notes removeLastObject];
}

- (void)cleanEmptyMeasures {
    while ([self.measures count] > 1 && [[self.measures lastObject] isEmpty]) {
        Measure *measure = [self.measures lastObject];
        // [measure keySigClose:nil];
        [self removeMeasure:measure];
    }
    [song refreshTimeSigs];
    [song refreshTempoData];
}

- (Note *)findPreviousNoteMatching:(Note *)source inMeasure:(Measure *)measure {
    if ([measure getFirstNote] == source ||
        ([[measure getFirstNote] isKindOfClass:[Chord class]] && [[(Chord *)[measure getFirstNote] getNotes] containsObject:source])) {
        Measure *prevMeasure = [[measure getStaff] getMeasureBefore:measure];
        if (prevMeasure != nil) {
            NoteBase *note = [prevMeasure.notes lastObject];
            if ([note respondsToSelector:@selector(pitchMatches:)] && [(Note *)note pitchMatches:source]) {
                return note;
            }
            if ([note isKindOfClass:[Chord class]]) {
                return [(Chord *)note getNoteMatching:source];
            }
        }
        return nil;
    }
    else {
        NoteBase *note = [measure getNoteBefore:source];
        if ([note respondsToSelector:@selector(pitchMatches:)] && [(Note *)note pitchMatches:source]) {
            return (Note *)note;
        }
        if ([note isKindOfClass:[Chord class]]) {
            return [(Chord *)note getNoteMatching:source];
        }
        return nil;
    }
}

- (NoteBase *)noteBefore:(NoteBase *)note {
    NSEnumerator *measureEnum = [self.measures objectEnumerator];
    Measure *measure;
    while ((measure = [measureEnum nextObject]) && ![measure.notes containsObject:note]);
    if (measure != nil) {
        if ([measure getFirstNote] == note) {
            if (measure == [self.measures objectAtIndex:0]) {
                return nil;
            }
            return [[[self.measures objectAtIndex:([self.measures indexOfObject:measure] - 1)] getNotes] lastObject];
        }
        else {
            return [measure.notes objectAtIndex:([measure.notes indexOfObject:note] - 1)];
        }
    }
    return nil;
}

- (NoteBase *)noteAfter:(NoteBase *)note {
    NSEnumerator *measureEnum = [self.measures objectEnumerator];
    Measure *measure;
    while ((measure = [measureEnum nextObject]) && ![measure.notes containsObject:note]);
    if (measure != nil) {
        if ([measure.notes lastObject] == note) {
            if (measure == [self.measures lastObject]) {
                return nil;
            }
            Measure *nextMeasure = [self.measures objectAtIndex:([self.measures indexOfObject:measure] + 1)];
            if ([nextMeasure.notes count] == 0) {
                return nil;
            }
            return [nextMeasure.notes objectAtIndex:0];
        }
        else {
            return [measure.notes objectAtIndex:([measure.notes indexOfObject:note] + 1)];
        }
    }
    return nil;
}

- (NSArray *)notesBetweenSingleNote:(NoteBase *)note1 andNote:(NoteBase *)note2 {
    NSMutableArray *between = [NSMutableArray array];
    Measure *measure1 = [self getMeasureContainingNote:note1];
    Measure *measure2 = [self getMeasureContainingNote:note2];
    Measure *firstMeasure = measure1, *lastMeasure = measure2;
    NoteBase *firstNote = note1, *lastNote = note2;
    if ([[self getMeasures] indexOfObject:measure1] > [[self getMeasures] indexOfObject:measure2]) {
        firstMeasure = measure2;
        lastMeasure = measure1;
        firstNote = note2;
        lastNote = note1;
    }
    if (firstMeasure == lastMeasure &&
        [firstMeasure.notes indexOfObject:note1] > [firstMeasure.notes indexOfObject:note2]) {
        firstNote = note2;
        lastNote = note1;
    }
    int i;
    for (i = [firstMeasure.notes indexOfObject:firstNote]; i < [firstMeasure.notes count]; i++) {
        NoteBase *note = [firstMeasure.notes objectAtIndex:i];
        [between addObject:note];
        if (note == lastNote) {
            return between;
        }
    }
    Measure *currMeasure;
    for (currMeasure = [self getMeasureAfter:firstMeasure createNew:NO]; currMeasure != lastMeasure; currMeasure = [self getMeasureAfter:currMeasure createNew:NO]) {
        [between addObjectsFromArray:currMeasure.notes];
    }
    for (i = 0; i <= [lastMeasure.notes indexOfObject:lastNote]; i++) {
        NoteBase *note = [lastMeasure.notes objectAtIndex:i];
        [between addObject:note];
    }
    return between;
}

- (NSArray *)notesBetweenArray:(NSArray *)notes andNote:(NoteBase *)note2 {
    NoteBase *firstArrayNote = [notes objectAtIndex:0];
    NoteBase *lastArrayNote = [notes lastObject];
    Measure *firstArrayMeasure = [self getMeasureContainingNote:firstArrayNote];
    Measure *lastArrayMeasure = [self getMeasureContainingNote:lastArrayNote];
    Measure *secondNoteMeasure = [self getMeasureContainingNote:note2];
    if ([[self getMeasures] indexOfObject:secondNoteMeasure] < [[self getMeasures] indexOfObject:firstArrayMeasure]) {
        return [self notesBetweenSingleNote:note2 andNote:lastArrayNote];
    }
    if ([[self getMeasures] indexOfObject:secondNoteMeasure] > [[self getMeasures] indexOfObject:lastArrayMeasure]) {
        return [self notesBetweenSingleNote:firstArrayNote andNote:note2];
    }
    if (secondNoteMeasure == firstArrayMeasure) {
        if ([secondNoteMeasure.notes indexOfObject:note2] >= [secondNoteMeasure.notes indexOfObject:firstArrayNote]) {
            return [self notesBetweenSingleNote:firstArrayNote andNote:note2];
        }
        return [self notesBetweenSingleNote:note2 andNote:lastArrayNote];
    }
    if (secondNoteMeasure == lastArrayMeasure) {
        if ([secondNoteMeasure.notes indexOfObject:note2] <= [secondNoteMeasure.notes indexOfObject:lastArrayNote]) {
            return [self notesBetweenSingleNote:firstArrayNote andNote:note2];
        }
        return [self notesBetweenSingleNote:firstArrayNote andNote:note2];
    }
    return [self notesBetweenSingleNote:firstArrayNote andNote:note2];
}

- (NSArray *)notesBetweenArray:(NSArray *)notes1 andArray:(NSArray *)notes2 {
    NoteBase *firstArray1Note = [notes1 objectAtIndex:0];
    NoteBase *lastArray1Note = [notes1 lastObject];
    Measure *firstArray1Measure = [self getMeasureContainingNote:firstArray1Note];
    Measure *lastArray1Measure = [self getMeasureContainingNote:lastArray1Note];
    NoteBase *firstArray2Note = [notes2 objectAtIndex:0];
    NoteBase *lastArray2Note = [notes2 lastObject];
    Measure *firstArray2Measure = [self getMeasureContainingNote:firstArray2Note];
    Measure *lastArray2Measure = [self getMeasureContainingNote:lastArray2Note];
    NoteBase *firstNote, *lastNote;
    if ([[self getMeasures] indexOfObject:firstArray1Measure] < [[self getMeasures] indexOfObject:firstArray2Measure]) {
        firstNote = firstArray1Note;
    }
    else if ([[self getMeasures] indexOfObject:firstArray1Measure] > [[self getMeasures] indexOfObject:firstArray2Measure]) {
        firstNote = firstArray2Note;
    }
    else if ([firstArray1Measure.notes indexOfObject:firstArray1Note] < [firstArray1Measure.notes indexOfObject:firstArray2Note]) {
        firstNote = firstArray1Note;
    }
    else {
        firstNote = firstArray2Note;
    }
    if ([[self getMeasures] indexOfObject:lastArray1Measure] < [[self getMeasures] indexOfObject:lastArray2Measure]) {
        lastNote = lastArray2Note;
    }
    else if ([[self getMeasures] indexOfObject:lastArray1Measure] > [[self getMeasures] indexOfObject:lastArray2Measure]) {
        lastNote = lastArray1Note;
    }
    else if ([lastArray1Measure.notes indexOfObject:lastArray1Note] < [lastArray1Measure.notes indexOfObject:lastArray2Note]) {
        lastNote = lastArray2Note;
    }
    else {
        lastNote = lastArray1Note;
    }
    return [self notesBetweenSingleNote:firstNote andNote:lastNote];
}

- (NSArray *)notesBetweenNote:(id)note1 andNote:(id)note2 {
    if ([note1 respondsToSelector:@selector(containsObject:)]) {
        if ([note2 respondsToSelector:@selector(containsObject:)]) {
            return [self notesBetweenArray:note1 andArray:note2];
        }
        return [self notesBetweenArray:note1 andNote:note2];
    }
    else {
        if ([note2 respondsToSelector:@selector(containsObject:)]) {
            return [self notesBetweenArray:note2 andNote:note1];
        }
        return [self notesBetweenSingleNote:note1 andNote:note2];
    }
}

- (void)toggleClefAtMeasure:(Measure *)measure {
    Clef *oldClef = [measure getClef];
    if (oldClef != nil && measure != [self.measures objectAtIndex:0]) {
        [measure setClef:nil];
    }
    else {
        oldClef = [self getClefForMeasure:measure];
        [measure setClef:[Clef getClefAfter:oldClef]];
    }
    Clef *newClef = [self getClefForMeasure:measure];
    int numLines = [newClef getTranspositionFrom:oldClef];
    int index = [self.measures indexOfObject:measure] + 1;
    [measure transposeBy:numLines];
    if (index < [self.measures count]) {
        while (index < [self.measures count]) {
            measure = [self.measures objectAtIndex:index++];
            if ([measure getClef] != nil) break;
            [measure transposeBy:numLines];
        }
    }
}

- (void)timeSigChangedAtMeasure:(Measure *)measure top:(int)top bottom:(int)bottom {
    [song timeSigChangedAtIndex:[self.measures indexOfObject:measure]
                            top:(int)top bottom:(int)bottom];
}

- (void)timeSigChangedAtMeasure:(Measure *)measure top:(int)top bottom:(int)bottom secondTop:(int)secondTop secondBottom:(int)secondBottom {
    [song timeSigChangedAtIndex:[self.measures indexOfObject:measure]
                            top:(int)top bottom:(int)bottom
                      secondTop:(int)secondTop secondBottom:(int)secondBottom];
}

- (void)timeSigDeletedAtMeasure:(Measure *)measure {
    if (measure != [self.measures objectAtIndex:0]) {
        [song timeSigDeletedAtIndex:[self.measures indexOfObject:measure]];
    }
}

- (void)transposeFrom:(KeySignature *)oldSig to:(KeySignature *)newSig startingAt:(Measure *)measure {
    int transposeAmount = [newSig distanceFrom:oldSig];
    do {
        [measure transposeBy:transposeAmount oldSignature:oldSig newSignature:newSig];
        measure = [[measure getStaff] getMeasureAfter:measure createNew:NO];
    }
    while (measure != nil && [measure getKeySignature] == nil);
}

- (void)cleanPanels {
    NSEnumerator *measureEnum = [self.measures objectEnumerator];
    id measure;
    while (measure = [measureEnum nextObject]) {
        [measure cleanPanels];
    }
}

- (BOOL)canMute {
    return canMute && !solo;
}

- (BOOL)canSolo {
    return canMute;
}

- (void)setCanMute:(BOOL)enabled {
    canMute = enabled;
}

- (BOOL)mute {
    return mute;
}

- (BOOL)solo {
    return solo;
}

- (void)setMute:(BOOL)_mute {
    mute = _mute;
}

- (void)setSolo:(BOOL)_solo {
    solo = _solo;
    if (solo) {
        [self setMute:NO];
    }
    [song soloPressed:solo onStaff:self];
}

- (int)channel {
    return channel + 1;
}

- (int)realChannel {
    return channel;
}

- (void)setChannel:(int)_channel {
    [[[self undoManager] prepareWithInvocationTarget:self] setChannel:(channel + 1)];
    channel = _channel - 1;
    [self setIsDrums:[self isDrums]];               //trigger KVO
    [self sendChangeNotification];
}

- (float)addTrackToMIDISequence:(MusicSequence *)musicSequence notesToPlay:(id)selection {
    if (MusicSequenceNewTrack(*musicSequence, &musicTrack) != noErr) {
        NSLog(@"Cannot create music track.");
        return 0;
    }
    
    NSEnumerator *measureEnum = [self.measures objectEnumerator];
    id measure;
    float pos = 0.0;
    BOOL isRepeating;
    NSMutableArray *repeatMeasures = [[NSMutableArray alloc]init];
    while (measure = [measureEnum nextObject]) {
        if ([measure isStartRepeat]) {
            isRepeating = YES;
        }
        pos += [measure addToMIDITrack:&musicTrack atPosition:pos transpose:transposition
                             onChannel:channel notesToPlay:selection];
        if (isRepeating) {
            [repeatMeasures addObject:measure];
        }
        if ([measure isEndRepeat]) {
            isRepeating = NO;
            int i;
            for (i = 1; i < [measure getNumRepeats]; i++) {
                NSEnumerator *repeatMeasuresEnum = [repeatMeasures objectEnumerator];
                id repeatMeasure;
                while (repeatMeasure = [repeatMeasuresEnum nextObject]) {
                    pos += [repeatMeasure addToMIDITrack:&musicTrack atPosition:pos transpose:transposition
                                               onChannel:channel notesToPlay:selection];
                }
            }
            [repeatMeasures removeAllObjects];
        }
    }
    
    MIDIMetaEvent metaEvent = { 0x2f, 0, 0, 0, 0, { 0 }
    };
    if (MusicTrackNewMetaEvent(musicTrack, pos, &metaEvent) != noErr) {
        NSLog(@"Cannot add end of track meta event to track.");
        return 0;
    }
    
    return pos;
}

- (void)addToLilypondString:(NSMutableString *)string {
    if ([self isDrums]) {
        [string appendString:@"\\new DrumStaff {\n\\drummode{\n"];
    }
    else {
        [string appendString:@"\\new Staff {\n"];
    }
    if ([[self name] length] > 0) {
        [string appendFormat:@"\\set Staff.instrumentName = \"%@\"\n", [self name]];
    }
    [[self.measures do] addToLilypondString:string];
    [string appendString:@"}\n"];
    if ([self isDrums]) {
        [string appendString:@"}\n"];
    }
}

- (void)addToMusicXMLString:(NSMutableString *)string {
    [[self.measures do] addToMusicXMLString:string];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.measures forKey:@"measures"];
    [coder encodeInt:channel forKey:@"channel"];
    [coder encodeInt:transposition forKey:@"transposition"];
    [coder encodeObject:name forKey:@"name"];
    [coder encodeObject:drumKit forKey:@"drumKit"];
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
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

//- (Class)getViewClass {
//    if ([self isDrums]) {
//        return [DrumStaffDraw class];
//    }
//    return [StaffDraw class];
//}
//
//- (Class)getControllerClass {
//    return [StaffController class];
//}

- (NSString *)musicXml {
    NSMutableString *str = [NSMutableString string];
    [self addToMusicXMLString:str];
    return str;
}

@end
