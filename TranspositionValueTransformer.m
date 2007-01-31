//
//  TranspositionValueTransformer.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 1/31/07.
//  Copyright 2007 Konstantine Prevas. All rights reserved.
//

#import "TranspositionValueTransformer.h"


@implementation TranspositionValueTransformer

+ (Class)transformedValueClass{
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation{
	return YES;
}

- (id)transformedValue:(id)value{
	int val = [value intValue];
	if(val >= 0){
		return [NSString stringWithFormat:@"+%d", val];
	}
	return [NSString stringWithFormat:@"%d", val];
}

- (id)reverseTransformedValue:(id)value{
	return [NSNumber numberWithInt:[value intValue]];
}

@end
