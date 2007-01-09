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
#import "KeySignatureDraw.h"
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

@class Chord;

@implementation MeasureDraw

+(void)drawClef:(Clef *)clef inMeasure:(Measure *)measure isTarget:(BOOL)isTarget{
	Class viewClass = (clef == nil) ? [ClefDraw class] : [clef getViewClass];
	[viewClass draw:clef inMeasure:measure isTarget:isTarget];
}

+(void)drawNotesInMeasure:(Measure *)measure target:(id)target selection:(id)selection{
	NSEnumerator *notes = [[measure getNotes] objectEnumerator];
	id note;
	while(note = [notes nextObject]){
		[[note getViewClass] draw:note inMeasure:measure atIndex:[[measure getNotes] indexOfObject:note] target:target selection:selection];
	}
}

+(void)drawConnectingBarsInMeasure:(Measure *)measure target:(id)target selection:(id)selection{
	[NSBezierPath setDefaultLineWidth:2.0];
	NSEnumerator *groups = [[measure getNoteGroups] objectEnumerator];
	id group;
	while(group = [groups nextObject]){
		if([selection respondsToSelector:@selector(containsAll:)] && [selection containsAll:group]){
			[[NSColor redColor] set];
		}
		Note *firstNote = [group objectAtIndex:0], *lastNote = [group lastObject];
		BOOL stemUpwards = [[firstNote getViewClass] isStemUpwards:firstNote inMeasure:measure];
		float firstStemX = [[firstNote getViewClass] stemXForNote:firstNote inMeasure:measure upwards:stemUpwards];
		float firstStemY = stemUpwards ? [[firstNote getViewClass] topOf:firstNote inMeasure:measure] :
			[[firstNote getViewClass] bottomOf:firstNote inMeasure:measure];
		float lastStemX = [[lastNote getViewClass] stemXForNote:lastNote inMeasure:measure upwards:stemUpwards];
		float lastStemY = stemUpwards ? [[lastNote getViewClass] topOf:lastNote inMeasure:measure] :
			[[lastNote getViewClass] bottomOf:lastNote inMeasure:measure];
		NSEnumerator *notes = [group objectEnumerator];
		id note;
		while(note = [notes nextObject]){
			float stem = stemUpwards ? [[note getViewClass] topOf:note inMeasure:measure] :
				[[note getViewClass] bottomOf:note inMeasure:measure];
			if((stemUpwards && stem < firstStemY && stem < lastStemY) ||
			   (stem > firstStemY && stem > lastStemY)){
				firstStemY = lastStemY = stem;
			}
		}
		NSPoint barStart = NSMakePoint(firstStemX, firstStemY);
		NSPoint barEnd = NSMakePoint(lastStemX, lastStemY);
		[NSBezierPath strokeLineFromPoint:barStart toPoint:barEnd];
		notes = [group objectEnumerator];
		Note *prevNote = nil, *currNote = [notes nextObject], *nextNote = [notes nextObject];
		float prevStemX = 0, currStemX = [[firstNote getViewClass] stemXForNote:firstNote inMeasure:measure upwards:stemUpwards],
			nextStemX = nextNote != nil ? [[nextNote getViewClass] stemXForNote:nextNote inMeasure:measure upwards:stemUpwards] : 0;
		float prevStemY = 0, currStemY = firstStemY + (lastStemY - firstStemY) * (currStemX - firstStemX) / (lastStemX - firstStemX),
			nextStemY = firstStemY + (lastStemY - firstStemY) * (nextStemX - firstStemX) / (lastStemX - firstStemX);
		while(currNote != nil){
			NSPoint stemStart = NSMakePoint(currStemX, [[currNote getViewClass] stemStartYForNote:currNote inMeasure:measure]);
			NSPoint stemEnd = NSMakePoint(currStemX, currStemY);
			[NSGraphicsContext saveGraphicsState];
			if(target == currNote || selection == currNote || 
			   ([selection respondsToSelector:@selector(containsObject:)] && [selection containsObject:currNote])){
				[[NSColor redColor] set];
			}
			[NSBezierPath strokeLineFromPoint:stemStart toPoint:stemEnd];
			[NSGraphicsContext restoreGraphicsState];
			if([currNote getDuration] >= 16){
				if([nextNote getDuration] >= 16){
					[NSBezierPath strokeLineFromPoint:NSMakePoint(currStemX, currStemY + (stemUpwards ? 4 : -4))
											  toPoint:NSMakePoint(nextStemX, nextStemY + (stemUpwards ? 4 : -4))];
				} else if(prevNote != nil && [prevNote getDuration] < 16){
					float partialStemX, partialStemY;
					if(prevNote == nil){
						partialStemY = currStemY + (nextStemY - currStemY) * 8 / (nextStemX - currStemX);
						partialStemX = currStemX + 8;
					} else {
						partialStemY = currStemY - (currStemY - prevStemY) * 8 / (currStemX - prevStemX);
						partialStemX = currStemX - 8;
					}
					[NSBezierPath strokeLineFromPoint:NSMakePoint(currStemX, currStemY + (stemUpwards ? 4 : -4))
											  toPoint:NSMakePoint(partialStemX, partialStemY + (stemUpwards ? 4 : -4))];
				}
				if([currNote getDuration] >= 32){
					if([nextNote getDuration] >= 32){
						[NSBezierPath strokeLineFromPoint:NSMakePoint(currStemX, currStemY + (stemUpwards ? 8 : -8))
												  toPoint:NSMakePoint(nextStemX, nextStemY + (stemUpwards ? 8 : -8))];
					} else if(prevNote != nil && [prevNote getDuration] < 32){
						float partialStemX, partialStemY;
						if(prevNote == nil){
							partialStemY = currStemY + (nextStemY - currStemY) * 8 / (nextStemX - currStemX);
							partialStemX = currStemX + 8;
						} else {
							partialStemY = currStemY - (currStemY - prevStemY) * 8 / (currStemX - prevStemX);
							partialStemX = currStemX - 8;
						}
						[NSBezierPath strokeLineFromPoint:NSMakePoint(currStemX, currStemY + (stemUpwards ? 8 : -8))
												  toPoint:NSMakePoint(partialStemX, partialStemY + (stemUpwards ? 8 : -8))];
					}
				}
			}
			prevNote = currNote;
			prevStemX = currStemX;
			prevStemY = currStemY;
			currNote = nextNote;
			currStemX = nextStemX;
			currStemY = nextStemY;
			nextNote = [notes nextObject];
			nextStemX = nextNote != nil ? [[nextNote getViewClass] stemXForNote:nextNote inMeasure:measure upwards:stemUpwards] : 0;
			nextStemY = firstStemY + (lastStemY - firstStemY) * (nextStemX - firstStemX) / (lastStemX - firstStemX);
		}
		[[NSColor blackColor] set];
	}
	[NSBezierPath setDefaultLineWidth:1.0];
}

+(void)drawFeedbackNoteInMeasure:(Measure *)measure targetLocation:(NSPoint)location mode:(NSDictionary *)mode{
	[[NSColor blueColor] set];
	location.x -= [MeasureController xOf:measure];
	location.y -= [MeasureController boundsOf:measure].origin.y;
	if([[measure getControllerClass] canPlaceNoteAt:location inMeasure:measure]){
		Note *feedbackNote = [[[Note alloc] initWithPitch:[MeasureController pitchAt:location inMeasure:measure]
												   octave:[MeasureController octaveAt:location inMeasure:measure]
												 duration:[[mode objectForKey:@"duration"] intValue]
												   dotted:[[mode objectForKey:@"dotted"] boolValue]
											   accidental:[[mode objectForKey:@"accidental"] intValue]
												  onStaff:[measure getStaff]]
			autorelease];
		float index = [MeasureController indexAt:location inMeasure:measure];
		if(((int)(index * 2)) % 2 == 0 && [[measure getNotes] count] > ceil(index)){
			id note = [[measure getNotes] objectAtIndex:index];
			if([[note getViewClass] respondsToSelector:@selector(isStemUpwards:inMeasure:)]){
				BOOL stemUpwards = [[note getViewClass] isStemUpwards:note inMeasure:measure];
				[[feedbackNote getViewClass] draw:feedbackNote inMeasure:measure atIndex:index isTarget:NO isOffset:NO
							  isInChordWithOffset:NO stemUpwards:stemUpwards drawStem:YES drawTriplet:YES];
				return;
			}
		}
		[[feedbackNote getViewClass] draw:feedbackNote inMeasure:measure atIndex:index target:nil selection:nil];		
	}
	[[NSColor blackColor] set];
}

+(void)drawStartRepeat:(NSRect)measureBounds{
	[NSBezierPath setDefaultLineWidth:2];
	[NSBezierPath strokeLineFromPoint:measureBounds.origin 
							  toPoint:NSMakePoint(measureBounds.origin.x, measureBounds.origin.y + measureBounds.size.height)];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(measureBounds.origin.x + 4, measureBounds.origin.y) 
							  toPoint:NSMakePoint(measureBounds.origin.x + 4, measureBounds.origin.y + measureBounds.size.height)];
	NSRect dotRect = NSMakeRect(measureBounds.origin.x + 7,
								measureBounds.origin.y + measureBounds.size.height / 4 + 4,
								4,
								measureBounds.size.height / 4 - 8);
	[[NSBezierPath bezierPathWithOvalInRect:dotRect] fill]; 
	dotRect = NSMakeRect(measureBounds.origin.x + 7,
						 measureBounds.origin.y + measureBounds.size.height / 2 + 4,
						 4,
						 measureBounds.size.height / 4 - 8);
	[[NSBezierPath bezierPathWithOvalInRect:dotRect] fill];
	[NSBezierPath setDefaultLineWidth:1];
}

+(void)drawEndRepeat:(NSRect)measureBounds repeatCount:(int)count{
	[NSBezierPath setDefaultLineWidth:2];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(measureBounds.origin.x + measureBounds.size.width, measureBounds.origin.y) 
							  toPoint:NSMakePoint(measureBounds.origin.x + measureBounds.size.width, measureBounds.origin.y + measureBounds.size.height)];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(measureBounds.origin.x + measureBounds.size.width - 4, measureBounds.origin.y) 
							  toPoint:NSMakePoint(measureBounds.origin.x + measureBounds.size.width - 4, measureBounds.origin.y + measureBounds.size.height)];
	NSRect dotRect = NSMakeRect(measureBounds.origin.x + measureBounds.size.width - 11,
								measureBounds.origin.y + measureBounds.size.height / 4 + 4,
								4,
								measureBounds.size.height / 4 - 8);
	[[NSBezierPath bezierPathWithOvalInRect:dotRect] fill]; 
	dotRect = NSMakeRect(measureBounds.origin.x + measureBounds.size.width - 11,
						 measureBounds.origin.y + measureBounds.size.height / 2 + 4,
						 4,
						 measureBounds.size.height / 4 - 8);
	[[NSBezierPath bezierPathWithOvalInRect:dotRect] fill];
	[NSBezierPath setDefaultLineWidth:1];
	if(count > 2){
		NSString *countString = [NSString stringWithFormat:@"x%d", count];
		[countString drawAtPoint:NSMakePoint(measureBounds.origin.x + measureBounds.size.width - 4,
											 measureBounds.origin.y - [countString sizeWithAttributes:nil].height - 3)
				  withAttributes:nil];
	}
}

+(void)draw:(Measure *)measure target:(id)target targetLocation:(NSPoint)location selection:(id)selection mode:(NSDictionary *)mode{
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
	BOOL drawFeedbackNote = YES;
	NSPoint targetLoc = location;
	targetLoc.x -= [[measure getControllerClass] xOf:measure];
	targetLoc.y -= [[measure getControllerClass] boundsOf:measure].origin.y;
	if(target == measure && [[measure getControllerClass] isOverStartRepeat:targetLoc inMeasure:measure]){
		[([measure isStartRepeat] ? [[NSColor redColor] shadowWithLevel:0.4] : [NSColor redColor]) set];
		[self drawStartRepeat:bounds];
		[[NSColor blackColor] set];
		drawFeedbackNote = NO;
	}
	else{
		if([measure isStartRepeat]){		
			[self drawStartRepeat:bounds];
		}
		if(target == measure && [measure followsOpenRepeat]){
			[[NSColor redColor] set];
			[self drawEndRepeat:bounds repeatCount:2];
			[[NSColor blackColor] set];
			drawFeedbackNote = NO;
		}
	}
	if(target == measure && [measure isEndRepeat] && [[measure getControllerClass] isOverEndRepeat:targetLoc inMeasure:measure]){
		[[[NSColor redColor] shadowWithLevel:0.4] set];
		[self drawEndRepeat:bounds repeatCount:[measure getNumRepeats]];
		[[NSColor blackColor] set];
		drawFeedbackNote = NO;
	} else {
		if([measure isEndRepeat]){
			[self drawEndRepeat:bounds repeatCount:[measure getNumRepeats]];
		}		
	}
	[self drawClef:[measure getClef] inMeasure:measure isTarget:([target isKindOfClass:[ClefTarget class]] && [target measure] == measure)];
	[TimeSignatureDraw drawTimeSig:[measure getTimeSignature] inMeasure:measure isTarget:([target isKindOfClass:[TimeSigTarget class]] && [target measure] == measure)];
	[KeySignatureDraw drawKeySig:[measure getKeySignature] inMeasure:measure isTarget:([target isKindOfClass:[KeySigTarget class]] && [target measure] == measure)];
	[self drawNotesInMeasure:measure target:target selection:selection];
	[self drawConnectingBarsInMeasure:measure target:target selection:selection];
	if([[mode objectForKey:@"pointerMode"] intValue] == MODE_NOTE && target == measure && drawFeedbackNote){
		[self drawFeedbackNoteInMeasure:measure targetLocation:location mode:mode];
	}
}

@end
