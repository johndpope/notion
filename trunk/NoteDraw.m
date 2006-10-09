//
//  NoteDraw.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/26/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "NoteDraw.h"
#import "NoteController.h"
#import "StaffController.h"
#import "MeasureController.h"
#import "Measure.h"
#import "Note.h"
#import "Clef.h"

@implementation NoteDraw

static NSMutableDictionary *noteX = nil;
static NSColor *mouseOverColor;

+(void)resetAccidentals{
	if(noteX == nil){
		noteX = [[NSMutableDictionary dictionary] retain];
	}
	[noteX removeAllObjects];
}

+(BOOL)isStemUpwards:(Note *)note inMeasure:(Measure *)measure{
	Clef *clef = [measure getEffectiveClef];
	int position = [clef getPositionForPitch:[note getPitch] withOctave:[note getOctave]];
	return position <= 4;
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

+(void)drawStemForNote:(Note *)note withBody:(NSRect)body upwards:(BOOL)up{
	NSPoint point1, point2;
	point1.y = body.origin.y + (body.size.height / 2);
	if(!up){
		point1.x = point2.x = body.origin.x + 0.5;
		point2.y = point1.y + 30;
	} else{
		point1.x = point2.x = body.origin.x + body.size.width - 0.5;
		point2.y = point1.y - 30;
	}
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
		[acc compositeToPoint:NSMakePoint(body.origin.x - 10, body.origin.y + 5) operation:NSCompositeSourceOver];
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
	if([note getTieTo] != nil){
		[noteX setObject:[NSNumber numberWithFloat:(body.origin.x+body.size.width)] forKey:[NSNumber numberWithInt:note]];
	}	
}

+(void)draw:(NoteBase *)note inMeasure:(Measure *)measure atIndex:(float)index target:(id)target{
	[self draw:note inMeasure:measure atIndex:index isTarget:(target == note) isOffset:NO 
		isInChordWithOffset:NO stemUpwards:[self isStemUpwards:note inMeasure:measure]];
}

+(void)draw:(NoteBase *)note inMeasure:(Measure *)measure atIndex:(float)index isTarget:(BOOL)highlighted
   isOffset:(BOOL)offset isInChordWithOffset:(BOOL)hasOffset stemUpwards:(BOOL)stemUpwards{
	if(highlighted){
		if(mouseOverColor == nil){
			mouseOverColor = [[NSColor colorWithDeviceRed:0.8 green:0 blue:0 alpha:1] retain];
		}
		[mouseOverColor set];
	}
	if(noteX == nil){
		noteX = [[NSMutableDictionary dictionary] retain];
	}
	float lineHeight = [StaffController lineHeightOf:[measure getStaff]];
	NSRect measureBounds = [MeasureController innerBoundsOf:measure];
	float middle = measureBounds.origin.y + measureBounds.size.height / 2.0;
	Clef *clef = [measure getEffectiveClef];
	int position = [clef getPositionForPitch:[note getPitch] withOctave:[note getOctave]];
	NSRect body;
	body.origin.x = [MeasureController xOfIndex:index inMeasure:measure];
	body.size.width = 12;
	body.size.height = 12;
	body.origin.y = measureBounds.origin.y + measureBounds.size.height - lineHeight * position - 6;
	[self drawExtraStaffLinesForPosition:position withBody:body lineHeight:lineHeight];
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
	if(offset){
		if(stemUpwards){
			body.origin.x -= 12;			
		} else{
			body.origin.x += 12;
		}
	}
	if([note getDuration] >= 2){
		[self drawStemForNote:note withBody:body upwards:stemUpwards];
	}
	[NSBezierPath setDefaultLineWidth:1.0];
	if(hasOffset && stemUpwards){
		body.origin.x += 12;
	}
	if([note getDotted]){
		[self drawDotForBody:body];		
	}
	[self drawAccidentalForNote:note withBody:body isTarget:highlighted];
	if(hasOffset && stemUpwards){
		body.origin.x -= 12;
	}
	[self drawTieForNote:note withBody:body];
	[[NSColor blackColor] set];		
}

@end
