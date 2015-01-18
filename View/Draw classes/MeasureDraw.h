//
//  MeasureDraw.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/29/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Measure;
@class Clef;

@interface MeasureDraw : NSObject {
}

+(void)draw:(Measure *)_measure target:(id)target targetLocation:(NSPoint)location selection:(id)selection mode:(NSDictionary *)mode;

@end
