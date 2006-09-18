/* MEWindowController */

#import <Cocoa/Cocoa.h>
@class ScoreView;
@class TempoData;
@class CAMIDIEndpointMenu;
#import "Staff.h"
#import "Measure.h"

static const int MODE_POINT = 0;
static const int MODE_NOTE = 1;

@interface MEWindowController : NSWindowController
{
	IBOutlet ScoreView *view;
	IBOutlet CAMIDIEndpointMenu *devicePopup;
	IBOutlet NSMatrix *mode;
	IBOutlet NSButton *dotted;
	IBOutlet NSButton *flat, *sharp, *natural;
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
- (BOOL)getDotted;
- (BOOL)isTieToPrev;

- (IBAction)playSong:(id)sender;
- (IBAction)changeDuration:(id)sender;
- (IBAction)changeDotted:(id)sender;
- (IBAction)changeAccidental:(id)sender;
- (IBAction)addStaff:(id)sender;

- (void)placeRulerComponents;
- (void)addVerticalRulerComponentFor:(Staff *)staff;
- (void)addHorizontalRulerComponentFor:(TempoData *)tempo;

- (id)targetAt:(NSPoint)location;

- (void)clickedAtLocation:(NSPoint)location withEvent:(NSEvent *)event;
- (BOOL)keyPressedAtLocation:(NSPoint)location withEvent:(NSEvent *)event;

@end
