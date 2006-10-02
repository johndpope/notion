//
//  ChordController.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 10/1/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Chord;
@class Measure;
@class ScoreView;

@interface ChordController : NSObject {

}

+ (float) widthOf:(Chord *)chord;
+ (float) widthOf:(Chord *)chord inMeasure:(Measure *)measure;

+ (float) xOf:(Chord *)chord inMeasure:(Measure *)measure;

+ (BOOL)handleKeyPress:(NSEvent *)event at:(NSPoint)location on:(Chord *)chord mode:(NSDictionary *)mode view:(ScoreView *)view;

@end
