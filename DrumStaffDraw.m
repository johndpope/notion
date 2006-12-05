//
//  DrumStaffDraw.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 12/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "DrumStaffDraw.h"
#import "DrumKit.h"
#import "Measure.h"
#import "MeasureController.h"

static NSDictionary *drumNameAttributes;

@implementation DrumStaffDraw

+ (Measure *) getLastVisibleMeasureInStaff:(Staff *)staff inView:(NSView *)view {
	NSEnumerator *measures = [[staff getMeasures] objectEnumerator];
	id measure;
	while(measure = [measures nextObject]){
		if([view needsToDrawRect:[MeasureController boundsOf:measure]]){
			return measure;
		}
	}
	return nil;
}

+ (void) draw:(Staff *)staff inView:(NSView *)view target:(id)target targetLocation:(NSPoint)location mode:(NSDictionary *)mode{
	[super draw:staff inView:view target:target targetLocation:location mode:mode];
	
	if(drumNameAttributes == nil){
		drumNameAttributes = [[NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:8], NSFontAttributeName, nil] retain];
	}
	Measure *lastDrawnMeasure = [self getLastVisibleMeasureInStaff:staff inView:view];
	DrumKit *kit = [lastDrawnMeasure getEffectiveClef];
	int i;
	for(i = 0; [kit positionIsValid:i]; i++){
		NSString *name = [kit nameAt:i];
		NSSize size = [name sizeWithAttributes:drumNameAttributes];
		NSRect visible = [view visibleRect];
		NSPoint point = NSMakePoint(visible.origin.x + visible.size.width - size.width, [[lastDrawnMeasure getControllerClass] yOfPosition:i inMeasure:lastDrawnMeasure] - size.height/2);
		[[NSColor colorWithDeviceWhite:1.0 alpha:0.8] set];
		[NSBezierPath fillRect:NSMakeRect(point.x, point.y, size.width, size.height)];
		[[NSColor blackColor] set];
	}
	for(i = 0; [kit positionIsValid:i]; i++){
		NSString *name = [kit nameAt:i];
		NSSize size = [name sizeWithAttributes:drumNameAttributes];
		NSRect visible = [view visibleRect];
		NSPoint point = NSMakePoint(visible.origin.x + visible.size.width - size.width, [[lastDrawnMeasure getControllerClass] yOfPosition:i inMeasure:lastDrawnMeasure] - size.height/2);
		[name drawAtPoint:point withAttributes:drumNameAttributes];
	}	
}

@end
