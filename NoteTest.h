//
//  NoteTest.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 8/17/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
@class Note;

@interface NoteTest : SenTestCase {
	Note *note;
}

- (void) testGetEffectiveDuration;

- (void) testRemoveDuration;

@end
