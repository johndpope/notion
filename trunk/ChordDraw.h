//
//  ChordDraw.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 10/1/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Chord;
@class Measure;

@interface ChordDraw : NSObject {

}

+ (BOOL)isStemUpwards:(Chord *)chord inMeasure:(Measure *)measure;

+(void)draw:(Chord *)chord inMeasure:(Measure *)measure atIndex:(float)index target:(id)target;

@end
