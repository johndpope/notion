//
//  TimeSignatureController.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "TimeSignatureController.h"
#import "CompoundTimeSigController.h"
#import "TimeSignatureDraw.h"
#import "TimeSignature.h"
#import "CompoundTimeSig.h"

static float widths[17] = {
	0.0, 0.0, 0.0, 0.0,
	0.0, 0.0, 0.0, 0.0,
	0.0, 0.0, 0.0, 0.0,
	0.0, 0.0, 0.0, 0.0, 0.0
};

@implementation TimeSignatureController

+ (float) widthOf:(TimeSignature *)timeSig{
	if([timeSig isKindOfClass:[NSNull class]]){
		return 10.0;
	}
	if([timeSig isKindOfClass:[CompoundTimeSig class]]){
		return [CompoundTimeSigController widthOf:timeSig];
	}
	if(widths[[timeSig getBottom]] == 0.0) {
		widths[[timeSig getBottom]] = [[NSString stringWithFormat:@"%d", [timeSig getBottom]] sizeWithAttributes:[TimeSignatureDraw timeSigStringAttrs]].width + 10.0;
	}
	return widths[[timeSig getBottom]];
}

+ (NSString *)getCommandListFor:(TimeSigTarget *)sig at:(NSPoint)location mode:(NSDictionary *)mode{
	NSMutableArray *commands = [NSMutableArray array];
	if([[sig measure] getTimeSignature] != [NSNull null]){
		[commands addObject:@"click - edit time signature"];
		[commands addObject:@"DELETE - delete time sig"];
	} else {
		[commands addObject:@"click - add time signature"];
	}
	return [commands componentsJoinedByString:@"\n"];
}

+ (void)handleMouseClick:(NSEvent *)event at:(NSPoint)location on:(TimeSigTarget *)sig mode:(NSDictionary *)mode view:(ScoreView *)view{
	[view showTimeSigPanelFor:[sig measure]];
}

+ (BOOL)handleKeyPress:(NSEvent *)event at:(NSPoint)location on:(TimeSigTarget *)sig mode:(NSDictionary *)mode view:(ScoreView *)view{
	if([[event characters] rangeOfString:[NSString stringWithFormat:@"%C", NSDeleteCharacter]].location != NSNotFound){
		[[[sig measure] undoManager] setActionName:@"deleting time signature"];
		[[sig measure] timeSigDelete];
		return YES;
	}
	return NO;
}

@end
