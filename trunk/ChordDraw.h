//
//  ChordDraw.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 10/1/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Chord;
@class Measure;

@interface ChordDraw : NSObject {

}

+(void)draw:(Chord *)chord inMeasure:(Measure *)measure atIndex:(float)index isTarget:(BOOL)highlighted;

@end
