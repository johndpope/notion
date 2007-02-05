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

- (void)testDistanceFromMajorToMajorNoWrap{
	KeySignature *sig = [KeySignature getMajorSignatureAtIndexFromA:6]; //C sharp major
	KeySignature *otherSig = [KeySignature getMajorSignatureAtIndexFromA:11]; //E major
	STAssertEquals([sig distanceFrom:otherSig], -3, @"distanceFrom failed downwards major to major");
	STAssertEquals([otherSig distanceFrom:sig], 3, @"distanceFrom failed upwards major to major");
}

- (void)testDistanceFromMajorToMajorWrap{
	KeySignature *sig = [KeySignature getMajorSignatureAtIndexFromA:15]; //G major
	KeySignature *otherSig = [KeySignature getMajorSignatureAtIndexFromA:0]; //A major
	STAssertEquals([sig distanceFrom:otherSig], -2, @"distanceFrom failed downwards major to major");
	STAssertEquals([otherSig distanceFrom:sig], 2, @"distanceFrom failed upwards major to major");
}

- (void)testDistanceFromMinorToMinorNoWrap{
	KeySignature *sig = [KeySignature getMinorSignatureAtIndexFromA:6]; //C sharp minor
	KeySignature *otherSig = [KeySignature getMinorSignatureAtIndexFromA:11]; //E minor
	STAssertEquals([sig distanceFrom:otherSig], -3, @"distanceFrom failed downwards minor to minor");
	STAssertEquals([otherSig distanceFrom:sig], 3, @"distanceFrom failed upwards minor to minor");
}

- (void)testDistanceFromMinorToMinorWrap{
	KeySignature *sig = [KeySignature getMinorSignatureAtIndexFromA:15]; //G minor
	KeySignature *otherSig = [KeySignature getMinorSignatureAtIndexFromA:0]; //A minor
	STAssertEquals([sig distanceFrom:otherSig], -2, @"distanceFrom failed downwards minor to minor");
	STAssertEquals([otherSig distanceFrom:sig], 2, @"distanceFrom failed upwards minor to minor");
}

- (void)testDistanceFromMajorToMinorNoWrap{
	KeySignature *sig = [KeySignature getMajorSignatureAtIndexFromA:6]; //C sharp major
	KeySignature *otherSig = [KeySignature getMinorSignatureAtIndexFromA:6]; //C sharp minor
	STAssertEquals([sig distanceFrom:otherSig], -3, @"distanceFrom failed downwards major to minor");
	STAssertEquals([otherSig distanceFrom:sig], 3, @"distanceFrom failed upwards major to minor");
}

- (void)testDistanceFromMajorToMinorWrap{
	KeySignature *sig = [KeySignature getMajorSignatureAtIndexFromA:15]; //G major
	KeySignature *otherSig = [KeySignature getMinorSignatureAtIndexFromA:13]; //F sharp minor
	STAssertEquals([sig distanceFrom:otherSig], -2, @"distanceFrom failed downwards major to minor");
	STAssertEquals([otherSig distanceFrom:sig], 2, @"distanceFrom failed upwards major to minor");
}

- (void)testDistanceFromMinorToMajorNoWrap{
	KeySignature *sig = [KeySignature getMinorSignatureAtIndexFromA:1]; //A sharp minor
	KeySignature *otherSig = [KeySignature getMajorSignatureAtIndexFromA:11]; //E major
	STAssertEquals([sig distanceFrom:otherSig], -3, @"distanceFrom failed upwards minor to major");
	STAssertEquals([otherSig distanceFrom:sig], 3, @"distanceFrom failed downwards minor to major");
}

- (void)testDistanceFromMinorToMajorWrap{
	KeySignature *sig = [KeySignature getMinorSignatureAtIndexFromA:11]; //E minor
	KeySignature *otherSig = [KeySignature getMajorSignatureAtIndexFromA:0]; //A major
	STAssertEquals([sig distanceFrom:otherSig], -2, @"distanceFrom failed upwards minor to major");
	STAssertEquals([otherSig distanceFrom:sig], 2, @"distanceFrom failed downwards minor to major");
}

@end
