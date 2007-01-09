//
//  NSArray+SenorStaff.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 1/7/07.
//  Copyright 2007 Konstantine Prevas. All rights reserved.
//

#import "NSArray+SenorStaff.h"


@implementation NSArray(SenorStaff)

- (BOOL)containsAll:(NSArray *)array{
	NSEnumerator *enumerator = [array objectEnumerator];
	id obj;
	while(obj = [enumerator nextObject]){
		if(![self containsObject:obj]){
			return false;
		}
	}
	return true;
}

@end
