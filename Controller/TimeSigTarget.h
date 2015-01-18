//
//  TimeSigTarget.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/16/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Measure;

@interface TimeSigTarget : NSObject {
	Measure *measure;
}

- (id)initWithMeasure:(Measure *)_measure;
- (Measure *)measure;
- (void)setMeasure:(Measure *)_measure;

- (Class)getControllerClass;

@end
