//
//  SongTest.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 8/9/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
@class Song;

@interface SongTest : SenTestCase {
	Song *song;
}

- (void) testRefreshTempoDataRemovesTempoData;
- (void) testRefreshTempoDataAddsTempoData;

- (void) testGetEffectiveTimeSigForMeasureWithTimeSig;
- (void) testGetEffectiveTimeSigForMeasureWithoutTimeSig;

- (void) testRefreshTimeSigsRemovesTimeSigs;
- (void) testRefreshTimeSigsAddsTimeSigs;

@end
