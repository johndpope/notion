//
//  TimeSignature.m
//  Music Editor
//
//  Created by Konstantine Prevas on 6/24/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "TimeSignature.h"


@implementation TimeSignature

+(id)timeSignatureWithTop:(int)top bottom:(int)bottom{
	static NSMutableDictionary *cachedSigs;
	if(cachedSigs == nil){
		cachedSigs = [[NSMutableDictionary dictionary] retain];
	}
	NSString *key = [NSString stringWithFormat:@"%d/%d", top, bottom];
	id sig = [cachedSigs objectForKey:key];
	if(sig == nil){
		sig = [[TimeSignature alloc] initWithTop:top bottom:bottom];
		[cachedSigs setObject:sig forKey:key];
	}
	return sig;
}

-(id)initWithTop:(int)_top bottom:(int)_bottom{
	if(self = [super init]){
		top = _top;
		bottom = _bottom;
	}
	return self;
}

-(int)getTop{
	return top;
}

-(int)getBottom{
	return bottom;
}

-(float)getMeasureDuration{
	return (float)top/(float)bottom;
}

@end
