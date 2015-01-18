//
//  KeySignatureDraw.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/17/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class KeySignature;
@class Measure;

@interface KeySignatureDraw : NSObject {

}

+(void)drawKeySig:(KeySignature *)sig inMeasure:(Measure *)measure isTarget:(BOOL)isTarget;

@end
