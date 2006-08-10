//
//  NoteDraw.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/26/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "NoteDraw.h"
#import "Note.h"
#import "Clef.h"

@implementation NoteDraw

static NSMutableDictionary *noteX = nil;
static NSColor *mouseOverColor;
static NoteDraw *instance = nil;

-(void)setNote:(Note *)_note{
	note = _note;
}

-(void)setX:(float)_x{
	x = _x;
}

-(void)setHighlighted:(BOOL)_highlighted{
	highlighted = _highlighted;
}

-(void)setClef:(Clef *)_clef{
	clef = _clef;
}

-(void)setMeasure:(NSRect)_measure{
	measure = _measure;
}


+(void)resetAccidentals{
	if(noteX == nil){
		noteX = [[NSMutableDictionary dictionary] retain];
	}
	[noteX removeAllObjects];
}

+(void)draw:(Note *)note atX:(NSNumber *)x highlighted:(BOOL)highlighted
		withClef:(Clef *)clef onMeasure:(NSRect)measure{
	if(instance == nil){
		instance = [[NoteDraw alloc] init];
	}
	[instance setNote:note];
	[instance setX:[x floatValue]];
	[instance setHighlighted:highlighted];
	[instance setClef:clef];
	[instance setMeasure:measure];
	[instance draw];
}

-(void)draw{
	if(highlighted){
		if(mouseOverColor == nil){
			mouseOverColor = [[NSColor colorWithDeviceRed:0.8 green:0 blue:0 alpha:1] retain];
		}
		[mouseOverColor set];
	}
	if(noteX == nil){
		noteX = [[NSMutableDictionary dictionary] retain];
	}
	line = measure.size.height / 8.0;
	middle = measure.origin.y + measure.size.height / 2.0;
	[self doDraw];
	[[NSColor blackColor] set];
}

-(void)doDraw{
	int position = [clef getPositionForPitch:[note getPitch] withOctave:[note getOctave]];
	body.origin.x = x;
	body.size.width = 12;
	body.size.height = 12;
	body.origin.y = measure.origin.y + measure.size.height - line * position - 6;
	[self drawExtraStaffLinesForPosition:position];
	[NSBezierPath setDefaultLineWidth:1.5];
	[self drawNote];
	if([note getDuration] >= 2){
		[self drawStemWithUpwards:(body.origin.y + body.size.height <= middle)];
	}
	[NSBezierPath setDefaultLineWidth:1.0];
	[self drawDot];
	[self drawAccidental];
	[self drawTie];
}

-(void)drawExtraStaffLinesForPosition:(int)position{
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

-(void)drawNote{
	if([note getDuration] >= 4){
		[[NSBezierPath bezierPathWithOvalInRect:body] fill];
	} else{
		[[NSBezierPath bezierPathWithOvalInRect:body] stroke];
	}	
}

-(void)drawStemWithUpwards:(BOOL)up{
	NSPoint point1, point2;
	point1.y = body.origin.y + (body.size.height / 2);
	if(up){
		point1.x = point2.x = body.origin.x + 0.5;
		point2.y = point1.y + 30;
	} else{
		point1.x = point2.x = body.origin.x + body.size.width - 0.5;
		point2.y = point1.y - 30;
	}
	[NSBezierPath strokeLineFromPoint:point1 toPoint:point2];
	int i;
	if(up){
		point1.x -= 7;
		point1.y = point2.y - 7;
	} else{
		point1.x += 7;
		point1.y = point2.y + 7;
	}		
	for(i=8; i<=[note getDuration]; i*=2){
		[NSBezierPath strokeLineFromPoint:point1 toPoint:point2];
		if(up){
			point1.y -= 5;
			point2.y -= 5;
		} else{
			point1.y += 5;
			point2.y += 5;
		}
	}	
}

-(void)drawDot{
	if([note getDotted]){
		NSRect dotRect;
		dotRect.origin.x = body.origin.x + body.size.width;
		dotRect.origin.y = body.origin.y + body.size.height - 4;
		dotRect.size.width = dotRect.size.height = 4;
		[[NSBezierPath bezierPathWithOvalInRect:dotRect] fill]; 
	}	
}

-(void)drawAccidental{
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

-(void)drawTie{
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

@end
