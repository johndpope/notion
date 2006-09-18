//
//  KeySigTest.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 8/27/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "KeySigTest.h"
#import "KeySignature.h"

@implementation KeySigTest

- (void)testGetIndexFromA{
	int i;
	for(i=0; i<18; i++){
		KeySignature *sig = [KeySignature getMajorSignatureAtIndexFromA:i];
		if(sig != nil){
			STAssertEquals([sig getIndexFromA], i, @"getIndexFromA failed, index %d, major.", i);			
		}
		sig = [KeySignature getMinorSignatureAtIndexFromA:i];
		if(sig != nil){
			STAssertEquals([sig getIndexFromA], i, @"getIndexFromA failed, index %d, minor.", i);			
		}
	}
}

@end
