//
//  StaffDraw.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/9/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Staff;
@class Measure;

@interface StaffDraw : NSObject {

}

+ (void) draw:(Staff *)staff inView:(NSView *)view target:(id)target targetLocation:(NSPoint)location mode:(NSDictionary *)mode;

+ (void) mustDraw:(Measure *)measure;

@end
