//
//  TimeSignatureDraw.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/17/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class TimeSignature;
@class Measure;

@interface TimeSignatureDraw : NSObject {

}

+(NSMutableDictionary *)timeSigStringAttrs;
+(void)drawTimeSig:(TimeSignature *)sig inMeasure:(Measure *)measure isTarget:(BOOL)isTarget;

@end
