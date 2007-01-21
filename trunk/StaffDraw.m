//
//  StaffDraw.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/9/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "StaffDraw.h"
#import "MeasureController.h"
#import "Measure.h"
#import "StaffController.h"
#import "NoteController.h"

@implementation StaffDraw

static NSMutableArray *mustDraw;

+ (NSRect) getSelectionRectFor:(id)selection onStaff:(Staff *)staff{
	NSRect selectionRect;
	selectionRect.origin.y = [[staff getControllerClass] topOf:staff];
	selectionRect.size.height = [[staff getControllerClass] heightOf:staff];
	float minX = MAXFLOAT, maxX = 0;
	NSEnumerator *notes = [selection objectEnumerator];
	id note;
	while(note = [notes nextObject]){
		float noteX = [[note getControllerClass] xOf:note];
		if(noteX < minX){
			minX = noteX;
		}
		if(noteX > maxX){
			maxX = noteX;
		}
	}
	selectionRect.origin.x = minX - 3;
	selectionRect.size.width = maxX - minX + 18;
	return selectionRect;
}

+ (void) draw:(Staff *)staff inView:(NSView *)view target:(id)target targetLocation:(NSPoint)location selection:(id)selection
		 mode:(NSDictionary *)mode{
	if([selection respondsToSelector:@selector(containsObject:)] && [[selection objectAtIndex:0] getStaff] == staff){
		NSRect selectionRect = [self getSelectionRectFor:selection onStaff:staff];
		[[NSColor colorWithDeviceRed:1.0 green:0.0 blue:0.0 alpha:0.15] set];
		[NSBezierPath fillRect:selectionRect];
		[[NSColor blackColor] set];
	}
	if(mustDraw == nil){
		mustDraw = [[NSMutableArray array] retain];
	}
	[mustDraw removeAllObjects];
	NSEnumerator *measures = [[staff getMeasures] objectEnumerator];
	id measure, lastDrawnMeasure;
	while(measure = [measures nextObject]){
		if([view needsToDrawRect:[MeasureController boundsOf:measure]] || [mustDraw containsObject:measure]){
			[[measure getViewClass] draw:measure target:target targetLocation:location selection:selection mode:mode];
			lastDrawnMeasure = measure;
		}
	}
	if([staff isDrums]){
	}
}

+ (void) mustDraw:(Measure *)measure{
	if(measure == nil){
		return;
	}
	if(mustDraw == nil){
		mustDraw = [[NSMutableArray array] retain];
	}
	[mustDraw addObject:measure];
}

@end
