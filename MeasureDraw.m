//
//  MeasureDraw.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/29/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "MeasureDraw.h"
#import "NoteDraw.h"
#import "TimeSignatureDraw.h"
#import "ClefDraw.h"
#import "MEWindowController.h"
#import "MeasureController.h"
#import "Measure.h"
#import "Staff.h"
#import "StaffController.h"
#import "ClefController.h"
#import "TimeSignatureController.h"
#import "TimeSignature.h"
#import "ClefTarget.h"
#import "KeySigTarget.h"
#import "TimeSigTarget.h"
#import "Clef.h"

@implementation MeasureDraw

+(void)draw:(Measure *)measure target:(id)target targetLocation:(NSPoint)location mode:(NSDictionary *)mode{
	NSRect bounds = [MeasureController innerBoundsOf:measure];
	[NSBezierPath strokeRect:bounds];
	int i;
	for(i=1; i<=3; i++){
		NSPoint point1, point2;
		point1.x = bounds.origin.x;
		point2.x = bounds.origin.x + bounds.size.width;
		point1.y = point2.y = bounds.origin.y + i * bounds.size.height / 4;
		[NSBezierPath strokeLineFromPoint:point1 toPoint:point2];
	}
	
	[self drawClef:[measure getClef] inMeasure:measure isTarget:([target isKindOfClass:[ClefTarget class]] && [target measure] == measure)];
	[TimeSignatureDraw drawTimeSig:[measure getTimeSignature] inMeasure:measure isTarget:([target isKindOfClass:[TimeSigTarget class]] && [target measure] == measure)];
	[self drawKeySig:[measure getKeySignature] inMeasure:measure isTarget:([target isKindOfClass:[KeySigTarget class]] && [target measure] == measure)];
	[self drawNotesInMeasure:measure target:(id)target];
	if([[mode objectForKey:@"pointerMode"] intValue] == MODE_NOTE && target == measure){
		[self drawFeedbackNoteInMeasure:measure targetLocation:location mode:mode];
	}
}

+(void)drawClef:(Clef *)clef inMeasure:(Measure *)measure isTarget:(BOOL)isTarget{
	Class *viewClass = (clef == nil) ? [ClefDraw class] : [clef getViewClass];
	[viewClass draw:clef inMeasure:measure isTarget:isTarget];
}

+(void)drawKeySig:(KeySignature *)sig inMeasure:(Measure *)measure isTarget:(BOOL)isTarget{
	NSRect bounds = [MeasureController innerBoundsOf:measure];
	float baseY = [StaffController baseOf:[measure getStaff]];
	float lineHeight = [StaffController lineHeightOf:[measure getStaff]];
	float clefWidth = [ClefController widthOf:[measure getClef]];
	float timeSigWidth = [TimeSignatureController widthOf:[measure getTimeSignature]];
	if(sig != nil && ([sig getNumSharps] > 0 || [sig getNumFlats] > 0)){
		NSPoint accLoc;
		accLoc.x = bounds.origin.x + clefWidth + timeSigWidth;
		NSEnumerator *sharps = [[sig getSharps] objectEnumerator];
		NSNumber *sharp;
		NSImage *sharpImg;
		if(isTarget){
			sharpImg = [NSImage imageNamed:@"sharp over.png"];
		} else{
			sharpImg = [NSImage imageNamed:@"sharp.png"];
		}
		while(sharp = [sharps nextObject]){
			int sharpLoc = [sharp intValue];
			accLoc.y = baseY - lineHeight * sharpLoc + 7.0;
			[sharpImg compositeToPoint:accLoc operation:NSCompositeSourceOver];
			accLoc.x += 10.0;
		}
		NSEnumerator *flats = [[sig getFlats] objectEnumerator];
		NSNumber *flat;
		NSImage *flatImg;
		if(isTarget){
			flatImg = [NSImage imageNamed:@"flat over.png"];
		} else{
			flatImg = [NSImage imageNamed:@"flat.png"];
		}
		while(flat = [flats nextObject]){
			int flatLoc = [flat intValue];
			accLoc.y = baseY - lineHeight * flatLoc + 3.0;
			[flatImg compositeToPoint:accLoc operation:NSCompositeSourceOver];
			accLoc.x += 10.0;
		}
	} else if(isTarget && ![measure isShowingKeySigPanel]){
		NSImage *sigIns = [NSImage imageNamed:@"keysig_insert.png"];
		[sigIns compositeToPoint:NSMakePoint(bounds.origin.x + clefWidth + timeSigWidth, bounds.origin.y) operation:NSCompositeSourceOver];			
	}	
}

+(void)drawNotesInMeasure:(Measure *)measure target:(id)target{
	NSEnumerator *notes = [[measure getNotes] objectEnumerator];
	id note;
	while(note = [notes nextObject]){
		[[note getViewClass] draw:note inMeasure:measure atIndex:[[measure getNotes] indexOfObject:note] isTarget:(note == target)];
	}
}

+(void)drawFeedbackNoteInMeasure:(Measure *)measure targetLocation:(NSPoint)location mode:(NSDictionary *)mode{
	[[NSColor blueColor] set];
	location.x -= [MeasureController xOf:measure];
	location.y -= [MeasureController boundsOf:measure].origin.y;
	Note *feedbackNote = [[[Note alloc] initWithPitch:[MeasureController pitchAt:location inMeasure:measure]
											   octave:[MeasureController octaveAt:location inMeasure:measure]
											 duration:[[mode objectForKey:@"duration"] intValue]
											   dotted:[[mode objectForKey:@"dotted"] boolValue]
										   accidental:[[mode objectForKey:@"accidental"] intValue]
											  onStaff:[measure getStaff]]
		autorelease];
	[NoteDraw draw:feedbackNote inMeasure:measure atIndex:[MeasureController indexAt:location inMeasure:measure] isTarget:NO];
}

@end
