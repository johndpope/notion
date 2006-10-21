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

@implementation StaffDraw

static NSMutableArray *mustDraw;

+ (void) draw:(Staff *)staff inView:(NSView *)view target:(id)target targetLocation:(NSPoint)location mode:(NSDictionary *)mode{
	if(mustDraw == nil){
		mustDraw = [[NSMutableArray array] retain];
	}
	[mustDraw removeAllObjects];
	NSEnumerator *measures = [[staff getMeasures] objectEnumerator];
	id measure;
	while(measure = [measures nextObject]){
		if([view needsToDrawRect:[MeasureController boundsOf:measure]] || [mustDraw containsObject:measure]){
			[[measure getViewClass] draw:measure target:target targetLocation:location mode:mode];
		}
	}	
}

+ (void) mustDraw:(Measure *)measure{
	if(mustDraw == nil){
		mustDraw = [[NSMutableArray array] retain];
	}
	[mustDraw addObject:measure];
}

@end
