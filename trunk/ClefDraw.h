//
//  ClefDraw.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/29/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Clef;
@class Measure;

@interface ClefDraw : NSObject {

}

+(void)draw:(Clef *)clef inMeasure:(Measure *)measure isTarget:(BOOL)isTarget;

@end
