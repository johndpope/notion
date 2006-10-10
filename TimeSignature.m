//
//  TimeSignature.m
//  Music Editor
//
//  Created by Konstantine Prevas on 6/24/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
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

+(id)fromNSNumberArray:(NSArray *)array{
	if([array isEqual:[NSNull null]]) return [NSNull null];
	return [self timeSignatureWithTop:[[array objectAtIndex:0] intValue] bottom:[[array objectAtIndex:1] intValue]];
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

+(NSArray *)asNSNumberArray:(id)sig{
	if([sig isEqual:[NSNull null]]){
		return nil;
	}
	return [NSArray arrayWithObjects:[NSNumber numberWithInt:[sig getTop]], [NSNumber numberWithInt:[sig getBottom]], nil];
}

@end
