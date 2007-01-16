//
//  KeySignatureController.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class KeySignature;
@class KeySigTarget;
@class ScoreView;

@interface KeySignatureController : NSObject {

}

+ (float) widthOf:(KeySignature *)keySig;

+ (void)handleMouseClick:(NSEvent *)event at:(NSPoint)location on:(KeySigTarget *)sig mode:(NSDictionary *)mode view:(ScoreView *)view;
+ (BOOL)handleKeyPress:(NSEvent *)event at:(NSPoint)location on:(KeySigTarget *)sig mode:(NSDictionary *)mode view:(ScoreView *)view;

@end
