//
//  RestDraw.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/26/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "RestDraw.h"
#import "Note.h"
@class Clef;

@implementation RestDraw

static NSColor *mouseOverColor;

+(void)draw:(Note *)note atX:(float)x highlighted:(BOOL)highlighted
   withClef:(Clef *)clef onMeasure:(NSRect)measure{
	if(highlighted){
		if(mouseOverColor == nil){
			mouseOverColor = [[NSColor colorWithDeviceRed:0.8 green:0 blue:0 alpha:1] retain];
		}
		[mouseOverColor set];
	}
	float line = measure.size.height / 8.0;
	float middle = measure.origin.y + measure.size.height / 2.0;
	NSRect rect;
	NSImage *img = nil;
	switch([note getDuration]){
		case 1:
			rect.origin.x = x;
			rect.origin.y = middle - line * 2;
			rect.size.height = line;
			rect.size.width = 15;
			[NSBezierPath fillRect:rect];
			break;
		case 2:
			rect.origin.x = x;
			rect.origin.y = middle - line;
			rect.size.height = line;
			rect.size.width = 15;
			[NSBezierPath fillRect:rect];
			break;
		case 4:
			img = [NSImage imageNamed:@"qrest.png"];
			[img compositeToPoint:NSMakePoint(x, middle + [img size].height / 2)
						operation:NSCompositeSourceOver];
			break;
		case 8:
			img = [NSImage imageNamed:@"erest.png"];
			[img compositeToPoint:NSMakePoint(x, middle + [img size].height / 2)
						operation:NSCompositeSourceOver];
			break;
		case 16:
			img = [NSImage imageNamed:@"srest.png"];
			[img compositeToPoint:NSMakePoint(x, middle + [img size].height / 2)
						operation:NSCompositeSourceOver];
			break;
		case 32:
			img = [NSImage imageNamed:@"trest.png"];
			[img compositeToPoint:NSMakePoint(x, middle + [img size].height / 2)
						operation:NSCompositeSourceOver];
			break;
	}
	if([note getDotted]){
		NSRect dotRect;
		dotRect.origin.x = x + (img != nil ? [img size].width : 17);
		dotRect.origin.y = (img != nil ? middle + 10 : middle);
		dotRect.size.width = dotRect.size.height = 4;
		[[NSBezierPath bezierPathWithOvalInRect:dotRect] fill]; 
	}
	[[NSColor blackColor] set];
}

@end
