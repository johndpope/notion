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

static RestDraw *instance = nil;

+(void)draw:(Note *)note atX:(NSNumber *)x highlighted:(BOOL)highlighted
   withClef:(Clef *)clef onMeasure:(NSRect)measure{
	if(instance == nil){
		instance = [[RestDraw alloc] init];
	}
	[instance setNote:note];
	[instance setX:[x floatValue]];
	[instance setHighlighted:highlighted];
	[instance setClef:clef];
	[instance setMeasure:measure];
	[instance draw];
}

-(void)doDraw{
	NSRect rect;
	NSImage *img = nil;
	switch([note getDuration]){
		case 1:
			if(highlighted) [[NSColor redColor] set];
			rect.origin.x = x;
			rect.origin.y = middle - line * 2;
			rect.size.height = line;
			rect.size.width = 15;
			[NSBezierPath fillRect:rect];
			break;
		case 2:
			if(highlighted) [[NSColor redColor] set];
			rect.origin.x = x;
			rect.origin.y = middle - line;
			rect.size.height = line;
			rect.size.width = 15;
			[NSBezierPath fillRect:rect];
			break;
		case 4:
			if(highlighted){
				img = [NSImage imageNamed:@"qrest-over.png"];
			} else{
				img = [NSImage imageNamed:@"qrest.png"];
			}
			[img compositeToPoint:NSMakePoint(x, middle + [img size].height / 2)
						operation:NSCompositeSourceOver];
			break;
		case 8:
			if(highlighted){
				img = [NSImage imageNamed:@"erest-over.png"];
			} else{
				img = [NSImage imageNamed:@"erest.png"];
			}
			[img compositeToPoint:NSMakePoint(x, middle + [img size].height / 2)
						operation:NSCompositeSourceOver];
			break;
		case 16:
			if(highlighted){
				img = [NSImage imageNamed:@"srest-over.png"];
			} else{
				img = [NSImage imageNamed:@"srest.png"];
			}
			[img compositeToPoint:NSMakePoint(x, middle + [img size].height / 2)
						operation:NSCompositeSourceOver];
			break;
		case 32:
			if(highlighted){
				img = [NSImage imageNamed:@"trest-over.png"];
			} else{
				img = [NSImage imageNamed:@"trest.png"];
			}
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
}

@end
