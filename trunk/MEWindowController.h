/* MEWindowController */

#import <Cocoa/Cocoa.h>
@class ScoreView;
@class TempoData;
@class CAMIDIEndpointMenu;
#import "Staff.h"
#import "Measure.h"
#import "ToolbarHelperController.h"

static const int MODE_POINT = 0;
static const int MODE_NOTE = 1;

@interface MEWindowController : ToolbarHelperController
{
	BOOL didAwakeFromNib;
	IBOutlet ScoreView *view;
	IBOutlet NSPopUpButton *duration;
	IBOutlet NSButton *dotted;
	IBOutlet NSView *durationView;
	IBOutlet NSView *accidentalView;
	IBOutlet NSButton *flat, *sharp, *natural;
	IBOutlet NSButton *triplet;
	IBOutlet NSButton *tieToPrev;
	IBOutlet NSScrollView *scrollView;
	IBOutlet NSScrollView *verticalRulerScroll;
	IBOutlet NSView *verticalRuler;
	IBOutlet NSScrollView *horizontalRulerScroll;
	IBOutlet NSView *horizontalRuler;
}
- (int)getPointerMode;
- (int)getNoteModeDuration;
- (int)getAccidental;
- (BOOL)isDotted;
- (BOOL)isTieToPrev;

- (IBAction)changeDuration:(id)sender;
- (IBAction)changeTriplet:(id)sender;
- (IBAction)changeDotted:(id)sender;
- (IBAction)changeAccidental:(id)sender;
- (IBAction)addStaff:(id)sender;

- (void)placeRulerComponents;
- (void)addVerticalRulerComponentFor:(Staff *)staff;
- (void)addHorizontalRulerComponentFor:(TempoData *)tempo;

- (id)targetAt:(NSPoint)location withEvent:(NSEvent *)event;

- (void)clickedAtLocation:(NSPoint)location withEvent:(NSEvent *)event;
- (BOOL)keyPressedAtLocation:(NSPoint)location withEvent:(NSEvent *)event;

@end
