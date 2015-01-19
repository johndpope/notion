//
//  Factory.h
//  SenorStaff Hack
//
//  Created by John Pope on 18/01/2015.
//
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
#import "Chord.h"
#import "ChromaticKeySignature.h"
#import "Clef.h"
#import "CompoundTimeSig.h"
#import "Drum+Lilypond.h"
#import "Drum+MusicXML.h"
#import "Drum.h"
#import "DrumKit.h"
#import "KeySignature.h"
#import "Measure.h"
#import "Note.h"
#import "NoteBase.h"
#import "Repeat.h"
#import "Rest.h"
#import "Song.h"
#import "Staff.h"
#import "TempoData.h"
#import "TimeSignature.h"
