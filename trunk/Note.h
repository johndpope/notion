//
//  Note.h
//  Music Editor
//
//  Created by Konstantine Prevas on 5/7/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AudioToolbox/AudioToolbox.h>
#import "KeySignature.h"
#import "NoteBase.h"
@class Staff;

static int NO_ACC = -100;
static int SHARP = 1;
static int NATURAL = 0;
static int FLAT = -1;

@interface Note : NoteBase <NSCopying>{
	int octave;
	int pitch;
	int accidental;
	
	Note *tieTo;
	Note *tieFrom;
	
}

- (id)initWithPitch:(int)_pitch octave:(int)_octave 
		   duration:(int)_duration dotted:(BOOL)_dotted accidental:(int)_accidental onStaff:(Staff *)staff;
		
- (int)getPitch;
- (int)getOctave;
- (int)getAccidental;

- (void)setOctave:(int)_octave;
- (void)setPitch:(int)_pitch;
- (void)setAccidental:(int)_accidental;

- (BOOL)pitchMatches:(Note *)note;

- (void)collapseOnTo:(Note *)note;

@end
