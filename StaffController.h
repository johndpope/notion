//
//  StaffController.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Staff;
@class Measure;

@interface StaffController : NSObject {

}

+ (float) heightOf:(Staff *)staff;
+ (float) widthOf:(Staff *)staff;
+ (float) lineHeightOf:(Staff *)staff;
+ (float) topOf:(Staff *)staff;
+ (float) baseOf:(Staff *)staff;
+ (NSRect) boundsOf:(Staff *)staff;

+ (Measure *)measureAtX:(float)x inStaff:(Staff *)staff;

+ (id)targetAtLocation:(NSPoint)location inStaff:(Staff *)staff mode:(NSDictionary *)mode withEvent:(NSEvent *)event;

@end
