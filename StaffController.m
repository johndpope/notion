//
//  self.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "StaffController.h"
#import "ScoreController.h"
#import "MeasureController.h"

@implementation StaffController

+ (float)heightOf:(Staff *)staff{
	return 150.0;
}

+ (float)innerHeightOf:(Staff *)staff{
	return 8.0 * [self lineHeightOf:staff];
}

+ (float)widthOf:(Staff *)staff{
	float width=0;
	NSEnumerator *measures = [[staff getMeasures] objectEnumerator];
	id measure;
	while(measure = [measures nextObject]){
		width += [MeasureController widthOf:measure];
	}
	return width;	
}

+ (float)lineHeightOf:(Staff *)staff{
	return [self heightOf:staff] / 24.0;
}

+ (float)topOf:(Staff *)staff{
	NSEnumerator *staffs = [[[staff getSong] staffs] objectEnumerator];
	id currStaff;
	float currY = [ScoreController yInset];
	while(currStaff = [staffs nextObject]){
		int staffHeight = [self heightOf:staff];
		if(currStaff == staff) return currY;
		currY += staffHeight + [ScoreController staffSpacing];
	}
	return currY;
}

+ (float)baseOf:(Staff *)staff{
	return [self topOf:staff] + 50 + [self innerHeightOf:staff];
}

+ (NSRect)boundsOf:(Staff *)staff{
	NSRect staffBounds;
	staffBounds.origin.x = [ScoreController xInset];
	staffBounds.origin.y = [ScoreController yInset] + [self topOf:staff];
	staffBounds.size.height = [self heightOf:staff];
	staffBounds.size.width = [self widthOf:staff];
	return staffBounds;	
}

+ (Measure *)measureAtX:(float)x inStaff:(Staff *)staff{
	NSEnumerator *measures = [[staff getMeasures] objectEnumerator];
	id measure;
	float currX = [ScoreController xInset];
	while(measure = [measures nextObject]){
		float measureWidth = [MeasureController widthOf:measure];
		if(currX + measureWidth > x) return measure;
		currX += measureWidth;
	}
	return [[staff getMeasures] lastObject];	
}

+ (id)targetAtLocation:(NSPoint)location inStaff:(Staff *)staff mode:(NSDictionary *)mode{
	Measure *measure = [self measureAtX:location.x inStaff:staff];
	location.x -= [MeasureController xOf:measure];
	return [MeasureController targetAtLocation:location inMeasure:measure mode:mode];
}

@end
