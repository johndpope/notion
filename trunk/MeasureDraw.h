//
//  MeasureDraw.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/29/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Measure;
@class Clef;

@interface MeasureDraw : NSObject {
	Measure *measure;
	NSRect bounds;
	float baseY;
	BOOL mouseOverClef;
	BOOL mouseOverTimeSig;
	BOOL mouseOverKeySig;
	float lineHeight;
	float clefWidth, timeSigWidth;
}

-(void)setMeasure:(Measure *)measure;
-(void)setBounds:(NSRect)bounds;
-(void)setBase:(float)baseY;
-(void)setMouseOverClef:(BOOL)mouseOverClef;
-(void)setMouseOverTimeSig:(BOOL)mouseOverTimeSig;
-(void)setMouseOverKeySig:(BOOL)mouseOverKeySig;
-(void)setLineHeight:(float)lineHeight;
-(void)setClefWidth:(float)clefWidth;
-(void)setTimeSigWidth:(float)timeSigWidth;

+(void)draw:(Measure *)_measure withBounds:(NSRect)_bounds base:(NSNumber *)_baseY
		lineHeight:(NSNumber *)_lineHeight clefWidth:(NSNumber *)clefWidth
		timeSigWidth:(NSNumber *)timeSigWidth
		mouseOverClef:(BOOL)_mouseOverClef
		mouseOverTimeSig:(BOOL)_mouseOverTimeSig
		mouseOverKeySig:(BOOL)_mouseOverKeySig;

-(void)draw;
-(void)drawClef:(Clef *)clef;

@end
