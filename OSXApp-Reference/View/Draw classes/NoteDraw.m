//
//  NoteDraw.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/26/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "NoteDraw.h"
#import "StaffDraw.h"
#import "NoteController.h"
#import "StaffController.h"
#import "MeasureController.h"
#import "Measure.h"
#import "Note.h"
#import "Clef.h"

@implementation NoteDraw

static NSMutableDictionary *noteX = nil;
static NSMutableArray *drawnTriplets = nil;
static NSColor *mouseOverColor;

+(NSColor *)mouseOverColor{
	if(mouseOverColor == nil){
		mouseOverColor = [[NSColor colorWithDeviceRed:0.8 green:0 blue:0 alpha:1] retain];
	}
	return mouseOverColor;
}

+(void)resetAccidentals{
	if(noteX == nil){
		noteX = [[NSMutableDictionary dictionary] retain];
	}
	if(drawnTriplets == nil) {
		drawnTriplets = [[NSMutableArray array] retain];
	}
	[noteX removeAllObjects];
	[drawnTriplets removeAllObjects];
}

+(BOOL)isStemUpwardsInIsolation:(NoteBase *)note inMeasure:(Measure *)measure{
	Clef *clef = [measure getEffectiveClef];
	int position = [clef getPositionForPitch:[note getPitch] withOctave:[note getOctave]];
	return position <= 4;
}

+(BOOL)isStemUpwards:(NoteBase *)note inMeasure:(Measure *)measure{
	NSEnumerator *groups = [[measure getNoteGroups] objectEnumerator];
	id group;
	while(group = [groups nextObject]){
		if([group containsObject:note]){
			int upwards = 0;
			NSEnumerator *notes = [group objectEnumerator];
			id enumNote;
			while(enumNote = [notes nextObject]){
				if([[enumNote getViewClass] isStemUpwardsInIsolation:enumNote inMeasure:measure]){
					upwards++;
				}
			}
			return upwards > [group count] / 2;
		}
	}
	return [self isStemUpwardsInIsolation:note inMeasure:measure];
}

+ (NSRect)bodyRectFor:(NoteBase *)note atIndex:(float)index inMeasure:(Measure *)measure{
	NSRect body;
	Clef *clef = [measure getEffectiveClef];
	int position = [clef getPositionForPitch:[note getPitch] withOctave:[note getOctave]];
	body.origin.x = [[measure getControllerClass] xOfIndex:index inMeasure:measure];
	body.size.width = 12;
	body.size.height = 12;
	body.origin.y = [[measure getControllerClass] yOfPosition:position inMeasure:measure] - 6;
	return body;
}

+ (float) topOf:(NoteBase *)note inMeasure:(Measure *)measure{
	NSRect body = [self bodyRectFor:note atIndex:0 inMeasure:measure];
	float top = body.origin.y;
	if([self isStemUpwards:note inMeasure:measure]){
		top -= 30;
	}
	return top;
}

+ (float) bottomOf:(NoteBase *)note inMeasure:(Measure *)measure{
	NSRect body = [self bodyRectFor:note atIndex:0 inMeasure:measure];
	float bottom = body.origin.y + body.size.height;
	if(![self isStemUpwards:note inMeasure:measure]){
		bottom += 30;
	}
	return bottom;
}

+(void)drawExtraStaffLinesForPosition:(int)position withBody:(NSRect)body lineHeight:(float)line{
	float lineY = body.origin.y + body.size.height/2;
	if(position < -1){
		int i = position;
		if(abs(position) % 2 == 1){
			lineY -= line;
			i++;
		}
		while(i < 0){
			[NSBezierPath strokeLineFromPoint:NSMakePoint(body.origin.x - 5, lineY)
									  toPoint:NSMakePoint(body.origin.x + body.size.width + 5, lineY)];
			lineY -= line * 2;
			i += 2;
		}
	}
	if(position > 9){
		int i = position;
		if(abs(position) % 2 == 1){
			lineY += line;
			i--;
		}
		while(i > 8){
			[NSBezierPath strokeLineFromPoint:NSMakePoint(body.origin.x - 5, lineY)
									  toPoint:NSMakePoint(body.origin.x + body.size.width + 5, lineY)];
			lineY += line * 2;
			i -= 2;
		}
	}	
}

+ (float)stemXForNote:(NoteBase *)note inMeasure:(Measure *)measure upwards:(BOOL)up{
	NSRect body = [self bodyRectFor:note atIndex:[[measure getNotes] indexOfObject:note] inMeasure:measure];
	return up ? body.origin.x + body.size.width - 0.5 : body.origin.x + 0.5;
}

+ (float)stemStartYForNote:(NoteBase *)note inMeasure:(Measure *)measure upwards:(BOOL)up{
	NSRect body = [self bodyRectFor:note atIndex:[[measure getNotes] indexOfObject:note] inMeasure:measure];
	return body.origin.y + (body.size.height / 2);
}

+(void)drawStemForNote:(Note *)note withBody:(NSRect)body upwards:(BOOL)up inMeasure:(Measure *)measure{
	[NSBezierPath setDefaultLineWidth:2.0];
	NSPoint point1, point2;
	point1.y = [self stemStartYForNote:note inMeasure:measure upwards:up];
	point1.x = point2.x = up ? body.origin.x + body.size.width - 0.5 : body.origin.x + 0.5;
	point2.y = up ? point1.y - 30 : point1.y + 30;
	[NSBezierPath strokeLineFromPoint:point1 toPoint:point2];
	int i;
	if(!up){
		point1.x -= 7;
		point1.y = point2.y - 7;
	} else{
		point1.x += 7;
		point1.y = point2.y + 7;
	}
	for(i=8; i<=[note getDuration]; i*=2){
		[NSBezierPath strokeLineFromPoint:point1 toPoint:point2];
		if(!up){
			point1.y -= 5;
			point2.y -= 5;
		} else{
			point1.y += 5;
			point2.y += 5;
		}
	}		
	[NSBezierPath setDefaultLineWidth:1.0];
}

+(void)drawDotForBody:(NSRect)body{
	NSRect dotRect;
	dotRect.origin.x = body.origin.x + body.size.width;
	dotRect.origin.y = body.origin.y + body.size.height - 4;
	dotRect.size.width = dotRect.size.height = 4;
	[[NSBezierPath bezierPathWithOvalInRect:dotRect] fill]; 
}

+(void)drawAccidentalForNote:(Note *)note withBody:(NSRect)body isTarget:(BOOL)highlighted{
	if([note getAccidental] != NO_ACC && [note getTieFrom] == nil){
		NSImage *acc;
		if([note getAccidental] == FLAT){
			if(highlighted){
				acc = [NSImage imageNamed:@"flat over.png"];
			} else{
				acc = [NSImage imageNamed:@"flat.png"];
			}
		} else if([note getAccidental] == SHARP){
			if(highlighted){
				acc = [NSImage imageNamed:@"sharp over.png"];
			} else{
				acc = [NSImage imageNamed:@"sharp.png"];
			}
		} else if([note getAccidental] == NATURAL){
			if(highlighted){
				acc = [NSImage imageNamed:@"natural over.png"];
			} else{
				acc = [NSImage imageNamed:@"natural.png"];
			}
		} else{
			NSAssert(NO, @"bad accidental value");
		}
		[acc drawFlippedAtPoint:NSMakePoint(body.origin.x - 10, body.origin.y - 5)];
	}	
}

+(void)drawTieForNote:(Note *)note withBody:(NSRect)body{
	Note *tieFrom = [note getTieFrom];
	if(tieFrom != nil){
		NSNumber *tieFromIndex = [NSNumber numberWithInt:tieFrom]; 
		float startX = [[noteX objectForKey:tieFromIndex] floatValue];
		NSBezierPath *tie = [NSBezierPath bezierPath];
		[tie setLineWidth:2.0];
		[tie moveToPoint:NSMakePoint(startX, body.origin.y + body.size.height)];
		[tie curveToPoint:NSMakePoint(body.origin.x, body.origin.y + body.size.height)
			controlPoint1:NSMakePoint((body.origin.x + startX) / 2, body.origin.y + body.size.height + 10)
			controlPoint2:NSMakePoint((body.origin.x + startX) / 2, body.origin.y + body.size.height + 10)];
		[tie stroke];
	}
	Note *tieTo = [note getTieTo];
	if(tieTo != nil){
		[noteX setObject:[NSNumber numberWithFloat:(body.origin.x+body.size.width)] forKey:[NSNumber numberWithInt:note]];
		[StaffDraw mustDraw:[[tieTo getStaff] getMeasureContainingNote:tieTo]];
	}
}

+ (void) drawTriplet:(NoteBase *)note{
	if([drawnTriplets containsObject:note]){
		return;
	}
	NSArray *notesToDraw = [note getContainingTriplet];
	float top = -1;
	NSEnumerator *notesEnum = [notesToDraw objectEnumerator];
	id noteToDraw;
	while(noteToDraw = [notesEnum nextObject]){
		float thisTop = [[noteToDraw getViewClass] topOf:noteToDraw inMeasure:[[noteToDraw getStaff] getMeasureContainingNote:noteToDraw]];
		if(top == -1 || top > thisTop){
			top = thisTop;
		}
	}
	top -= 15;
	NoteBase *firstNote = [notesToDraw objectAtIndex:0];
	NoteBase *lastNote = [notesToDraw lastObject];
	float startX = [NoteController xOf:firstNote];
	float endX = [NoteController xOf:lastNote] + 12;
	[NSBezierPath strokeLineFromPoint:NSMakePoint(startX, top) toPoint:NSMakePoint(endX, top)];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(startX, top) toPoint:NSMakePoint(startX, top + 5)];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(endX, top) toPoint:NSMakePoint(endX, top + 5)];
	[@"3" drawAtPoint:NSMakePoint((startX + endX) / 2, top - 15) withAttributes:nil];
	[drawnTriplets addObjectsFromArray:notesToDraw];
}

+(void)draw:(NoteBase *)note inMeasure:(Measure *)measure atIndex:(float)index target:(id)target selection:(id)selection{
	[self draw:note inMeasure:measure atIndex:index isTarget:((target == note) || [[note getControllerClass] isSelected:note inSelection:selection])
	  isOffset:NO isInChordWithOffset:NO stemUpwards:[self isStemUpwards:note inMeasure:measure] 
	  drawStem:(![note isDrawBars] || [measure isIsolated:note]) drawTriplet:YES];
}

+(void)draw:(NoteBase *)note inMeasure:(Measure *)measure atIndex:(float)index isTarget:(BOOL)highlighted
   isOffset:(BOOL)offset isInChordWithOffset:(BOOL)hasOffset stemUpwards:(BOOL)stemUpwards drawStem:(BOOL)stem drawTriplet:(BOOL)triplet{
	if(highlighted){
		[[self mouseOverColor] set];
	}
	if(noteX == nil){
		noteX = [[NSMutableDictionary dictionary] retain];
	}
	float lineHeight = [StaffController lineHeightOf:[measure getStaff]];
	NSRect measureBounds = [MeasureController innerBoundsOf:measure];
	Clef *clef = [measure getEffectiveClef];
	int position = [clef getPositionForPitch:[note getPitch] withOctave:[note getOctave]];
	NSRect body = [self bodyRectFor:note atIndex:index inMeasure:measure];
	[self drawExtraStaffLinesForPosition:position withBody:body lineHeight:lineHeight];
	if([note getDotted]){
		[self drawDotForBody:body];		
	}
	[self drawAccidentalForNote:note withBody:body isTarget:highlighted];
	[self drawTieForNote:note withBody:body];
	[NSBezierPath setDefaultLineWidth:1.5];
	if(offset){
		if(stemUpwards){
			body.origin.x += 12;			
		} else{
			body.origin.x -= 12;
		}
	}
	if([note getDuration] >= 4){
		[[NSBezierPath bezierPathWithOvalInRect:body] fill];
	} else{
		[[NSBezierPath bezierPathWithOvalInRect:body] stroke];
	}
	if(triplet){
		if([note isTriplet]){
			if(![note isPartOfFullTriplet]){
				float threeY = stemUpwards ? body.origin.y + body.size.height : body.origin.y - body.size.height - 2;
				[@"3" drawAtPoint:NSMakePoint(body.origin.x + 2, threeY) withAttributes:nil];
			} else{
				[self drawTriplet:note];
			}
		}
	}
	if(stem){
		if(offset){
			if(stemUpwards){
				body.origin.x -= 12;			
			} else{
				body.origin.x += 12;
			}
		}
		if([note getDuration] >= 2){
			[self drawStemForNote:note withBody:body upwards:stemUpwards inMeasure:measure];
		}
	}
	[NSBezierPath setDefaultLineWidth:1.0];
	[[NSColor blackColor] set];
}

@end
