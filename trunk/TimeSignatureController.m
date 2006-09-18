//
//  TimeSignatureController.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "TimeSignatureController.h"
#import "TimeSignature.h"

@implementation TimeSignatureController

+ (float) widthOf:(TimeSignature *)timeSig{
	return [timeSig isKindOfClass:[NSNull class]] ? 10.0 : ([timeSig getBottom] > 10 ? 40.0 : 30.0);
}

+ (void)handleMouseClick:(NSEvent *)event at:(NSPoint)location on:(TimeSigTarget *)sig mode:(NSDictionary *)mode view:(ScoreView *)view{
	[view showTimeSigPanelFor:[sig measure]];
}

@end
