//
//  TimeSigTarget.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/16/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "TimeSigTarget.h"
@class Measure;
@class TimeSignatureController;

@implementation TimeSigTarget

- (Measure *)measure{
	return measure;
}

- (id)initWithMeasure:(Measure *)_measure{
	if((self = [super init])){
		measure = _measure;
	}
	return self;
}

- (void)setMeasure:(Measure *)_measure{
	if(measure != _measure){
		[measure release];
		measure = [_measure retain];
	}
}

- (void) dealloc {
	[measure release];
	[super dealloc];
}

- (Class)getControllerClass{
	return [TimeSignatureController class];
}

@end
