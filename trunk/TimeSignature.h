//
//  TimeSignature.h
//  Music Editor
//
//  Created by Konstantine Prevas on 6/24/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TimeSignature : NSObject {
	int top;
	int bottom;
}

+(id)timeSignatureWithTop:(int)top bottom:(int)bottom;

-(id)initWithTop:(int)top bottom:(int)bottom;

-(int)getTop;
-(int)getBottom;
-(float)getMeasureDuration;

@end
