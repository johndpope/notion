//
//  NSNumberPool.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/7/07.
//  Copyright 2007 Konstantine Prevas. All rights reserved.
//

#import "NSNumberPool.h"

static NSNumber *numbers[128];
static int init = 0;

@implementation NSNumberPool

+ (NSNumber *)number:(int)number{
	if(number >= 128 || number < 0){
		return [NSNumber numberWithInt:number];
	}
	if(init == 0){
		int i;
		for(i = 0; i < 128; i++){
			numbers[i] = nil;
		}
		init = 1;
	}
	if(numbers[number] == nil){
		numbers[number] = [[NSNumber numberWithInt:number] retain];
	}
	return numbers[number];
}

@end
