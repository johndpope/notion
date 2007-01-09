//
//  CompoundTimeSig.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 1/8/07.
//  Copyright 2007 Konstantine Prevas. All rights reserved.
//

#import "CompoundTimeSig.h"


@implementation CompoundTimeSig

-(id)initWithFirstSig:(TimeSignature *)_firstSig secondSig:(TimeSignature *)_secondSig{
	if(self = [super init]){
		firstSig = [_firstSig retain];
		secondSig = [_secondSig retain];
	}
	return self;
}

-(TimeSignature *)getTimeSignatureAfterMeasures:(int)numMeasures{
	if(numMeasures % 2 == 0){
		return firstSig;
	}
	return secondSig;
}

+(NSArray *)asNSNumberArray:(id)sig{
	return [[TimeSignature asNSNumberArray:firstSig] arrayByAddingObjectsFromArray:[TimeSignature asNSNumberArray:secondSig]];
}

-(void)dealloc{
	[firstSig release];
	[secondSig release];
	firstSig = nil;
	secondSig = nil;
	[super dealloc];
}

@end
