//
//  ChromaticKeySignature.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 12/3/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//


#ifdef __APPLE__
#include "TargetConditionals.h"
#ifdef TARGET_OS_IPHONE
// iOS
#import <Foundation/Foundation.h>
#elif TARGET_IPHONE_SIMULATOR
// iOS Simulator
#import <Foundation/Foundation.h>
#elif TARGET_OS_MAC
#import <Foundation/Foundation.h>
#else
// Unsupported platform
#endif
#endif
#import "KeySignature.h"

@interface ChromaticKeySignature : KeySignature {
}

+ (KeySignature *)instance;

@end
