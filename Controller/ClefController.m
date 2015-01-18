//
//  ClefController.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "ClefController.h"
#import "Clef.h"
#import "ClefTarget.h"
#import "Measure.h"

@implementation ClefController

+ (float) widthOf:(Clef *)clef{
	return (clef == nil) ? 10.0 : 35.0;
}

+ (NSString *)getCommandListFor:(ClefTarget *)clef at:(NSPoint)location mode:(NSDictionary *)mode{
	return @"click - toggle clef";
}

+ (void)handleMouseClick:(NSEvent *)event at:(NSPoint)location on:(ClefTarget *)clef mode:(NSDictionary *)mode view:(ScoreView *)view{
	Measure *measure = [clef measure];
	[[measure undoManager] setActionName:@"toggling clef"];
	[[measure getStaff] toggleClefAtMeasure:measure];
}

@end
