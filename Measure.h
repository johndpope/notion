//
//  Measure.h
//  Music Editor
//
//  Created by Konstantine Prevas on 5/4/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Note;
@class Clef;
@class Staff;
@class KeySignature;
@class TimeSignature;
#import <AudioToolbox/AudioToolbox.h>

@interface Measure : NSObject <NSCoding> {
	Staff *staff;
	Clef *clef;
	KeySignature *keySig;
	TimeSignature *timeSig;
	NSMutableArray *notes;
	NSViewAnimation *anim;
	
	IBOutlet NSView *keySigPanel;
	IBOutlet NSPopUpButton *keySigLetter;
	IBOutlet NSPopUpButton *keySigMajMin;
	
	IBOutlet NSView *timeSigPanel;
	IBOutlet NSTextField *timeSigTopText;
	IBOutlet NSStepper *timeSigTopStep;
	IBOutlet NSPopUpButton *timeSigBottom;
}

- (id)initWithStaff:(Staff *)_staff;

- (NSMutableArray *)getNotes;
- (Note *)getFirstNote;
- (void)setNotes:(NSMutableArray *)_notes;
- (Note *)addNotes:(NSArray *)note atIndex:(float)index;
- (void)removeNoteAtIndex:(float)x temporary:(BOOL)temp;

- (float)getTotalDuration;
- (BOOL)isEmpty;
- (BOOL)isFull;

- (Clef *)getClef;
- (Clef *)getEffectiveClef;
- (void)setClef:(Clef *)_clef;

- (KeySignature *)getKeySignature;
- (KeySignature *)getEffectiveKeySignature;
- (void)setKeySignature:(KeySignature *)_sig;

- (TimeSignature *)getTimeSignature;
- (TimeSignature *)getEffectiveTimeSignature;
- (void)setTimeSignature:(TimeSignature *)_sig;

- (BOOL)isShowingKeySigPanel;
- (NSView *)getKeySigPanel;

- (BOOL)isShowingTimeSigPanel;
- (NSView *)getTimeSigPanel;

- (Note *)findPreviousNoteMatching:(Note *)source atIndex:(int)index;

- (void)transposeBy:(int)tranposeAmount;

- (IBAction)keySigChanged:(id)sender;
- (IBAction)keySigClose:(id)sender;

- (IBAction)timeSigTopChanged:(id)sender;
- (IBAction)timeSigBottomChanged:(id)sender;
- (IBAction)timeSigClose:(id)sender;

- (float)addToMIDITrack:(MusicTrack *)musicTrack atPosition:(float)pos
	onChannel:(int)channel;

@end
