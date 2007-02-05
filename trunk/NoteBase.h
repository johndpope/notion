//
//  NoteBase.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/31/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AudioToolbox/AudioToolbox.h>
@class KeySignature;
@class Staff;

@interface NoteBase : NSObject {
	int duration;
	BOOL dotted;

	Staff *staff;
}

- (int)getDuration;
- (BOOL)getDotted;

- (void)setDuration:(int)_duration;
- (void)setDotted:(BOOL)_dotted;

- (Staff *)getStaff;
- (void)setStaff:(Staff *)_staff;

- (NSUndoManager *)undoManager;
- (void)sendChangeNotification;

- (float)getEffectiveDuration;

- (BOOL)canBeInChord;

- (BOOL)isTriplet;
- (BOOL)isPartOfFullTriplet;
- (NSArray *)getContainingTriplet;

- (BOOL)isDrawBars;

- (float)addToMIDITrack:(MusicTrack *)musicTrack atPosition:(float)pos
	   withKeySignature:(KeySignature *)sig accidentals:(NSMutableDictionary *)accidentals
			  transpose:(int)transposition onChannel:(int)channel;

- (void)transposeBy:(int)numLines;
- (void)transposeBy:(int)numHalfSteps oldSignature:(KeySignature *)oldSig newSignature:(KeySignature *)newSig;

- (void)prepareForDelete;

- (NSArray *)subtractDuration:(float)maxDuration;
- (void)tryToFill:(float)maxDuration;

- (void)tieTo:(NoteBase *)note;
- (NoteBase *)getTieTo;
- (void)tieFrom:(NoteBase *)note;
- (NoteBase *)getTieFrom;

- (Class)getViewClass;
- (Class)getControllerClass;

@end
