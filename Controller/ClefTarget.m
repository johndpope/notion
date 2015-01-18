//
//  ClefTarget.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/16/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "ClefTarget.h"
@class ClefController;

@implementation ClefTarget

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

- (BOOL) isEqual:(id)obj {
	return [obj isKindOfClass:[self class]] &&
	[[obj measure] isEqual:measure];
}

- (unsigned) hash {
	return [measure hash];
}

- (void) dealloc {
	[measure release];
	[super dealloc];
}

- (Class)getControllerClass{
	return [ClefController class];
}

@end
