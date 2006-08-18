//
//  NoteDraw.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/26/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Note;
@class Clef;
@class StaffView;

@interface NoteDraw : NSObject {
	Note *note;
	NSRect body;
	float x;
	BOOL highlighted;
	float line;
	float middle;
	float base;
	Clef *clef;
	NSRect measure;
}

-(void)setNote:(Note *)note;
-(void)setX:(float)x;
-(void)setHighlighted:(BOOL)highlighted;
-(void)setClef:(Clef *)clef;
-(void)setMeasure:(NSRect)measure;

+(void)resetAccidentals;

+(void)draw:(Note *)note atX:(NSNumber *)x highlighted:(BOOL)highlighted
		withClef:(Clef *)clef onMeasure:(NSRect)measure;
		
-(void)draw;
-(void)doDraw;

-(void)drawExtraStaffLinesForPosition:(int)position;
-(void)drawNote;
-(void)drawStemWithUpwards:(BOOL)up;
-(void)drawDot;
-(void)drawAccidental;
-(void)drawTie;

@end
