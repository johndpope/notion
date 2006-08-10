//
//  StaffView.h
//  Music Editor
//
//  Created by Konstantine Prevas on 5/3/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Song;
@class Staff;
@class Measure;
@class Note;
@class Clef;
@class KeySignature;
@class TimeSignature;
@class MEWindowController;

@interface StaffView : NSView {
	MEWindowController *controller;
	
	id mouseOver;
	id clefFeedback;
	id keySigFeedback;
	id timeSigFeedback;

	Song *song;
	Note *feedbackNote;
	Staff *feedbackStaff;
	Measure *feedbackMeasure;
	float feedbackX;
	NSColor *mouseOverColor;
	
	ATSFontContainerRef container;
}

- (void)setController:(MEWindowController *)_controller;

- (Song *)getSong;
- (void)setSong:(Song*)song;

- (id)initWithFrame:(NSRect)frame;

- (void)drawRect:(NSRect)rect;
- (BOOL)isOpaque;

- (float)xInset;
- (float)yInset;

- (NSRect)calculateBounds;
- (float)calcStaffWidth:(Staff *)staff;
- (float)calcStaffHeight:(Staff *)staff;
- (float)calcStaffBase:(Staff *)staff fromTop:(float)y;
- (float)calcStaffTop:(Staff *)staff;
- (float)calcStaffLineHeight:(Staff *)staff;
- (float)calcMeasureWidth:(Measure *)measure;
- (float)staffSpacing;
- (float)minNoteSpacing;
- (float)clefWidth;
- (float)clefAreaWidth;
- (float)calcClefWidth:(Measure *)measure;
- (float)keySignatureWidth:(KeySignature *)sig;
- (float)keySignatureAreaWidth;
- (float)calcKeySignatureWidth:(Measure *)measure;
- (float)timeSignatureWidth;
- (float)timeSignatureAreaWidth;
- (float)calcTimeSignatureWidth:(Measure *)measure;
- (float)calcMeasureNoteAreaStart:(Measure *)measure;
- (float)getXForMeasure:(Measure *)measure forStaff:(Staff *)staff;
- (float)calcNoteWidth:(Note *)note;

- (float)getXForIndex:(float)index forStaff:(Staff *)staff forMeasure:(Measure *)measure;
- (float)getIndexAtX:(float)x forStaff:(Staff *)staff forMeasure:(Measure *)measure;

- (void)drawStaff:(Staff *)staff y:(float)y;
- (void)drawMeasure:(Measure *)measure x:(float)x top:(float)y base:(float)baseY height:(float)height lineHeight:(float)line withClef:(Clef *)clef;
- (void)drawNote:(Note *)note x:(float)x y:(float)y measure:(NSRect)measure lineHeight:(float)line withClef:(Clef *)clef;

- (void)setFeedbackNoteDuration:(int)_duration;
- (void)setFeedbackNoteDotted:(BOOL)_dotted;
- (void)setFeedbackNoteAccidental:(int)_accidental;
- (void)updateFeedback:(NSEvent *)event;

@end
