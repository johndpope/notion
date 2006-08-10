/* MEWindowController */

#import <Cocoa/Cocoa.h>
@class StaffView;
@class TempoData;
@class CAMIDIEndpointMenu;
#import "Staff.h"
#import "Measure.h"

const int MODE_POINT = 0;
const int MODE_NOTE = 1;

@interface MEWindowController : NSWindowController
{
	IBOutlet StaffView *view;
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
- (IBAction)playSong:(id)sender;
- (int)getMode;
- (int)getNoteModeDuration;
- (int)getAccidental;
- (BOOL)getDotted;
- (IBAction)changeDuration:(id)sender;
- (IBAction)changeDotted:(id)sender;
- (IBAction)changeAccidental:(id)sender;
- (void)updateFeedbackDuration;
- (void)updateFeedbackDotted;
- (void)updateFeedbackAccidental;
- (IBAction)addStaff:(id)sender;
- (void)placeRulerComponents;
- (void)addVerticalRulerComponentFor:(Staff *)staff;
- (void)addHorizontalRulerComponentFor:(TempoData *)tempo;
- (void)clickedAtLocation:(NSPoint)location onStaff:(Staff *)staff onMeasure:(Measure *)measure
				atPitch:(int)pitch atOctave:(int)octave atXIndex:(float)x 
				onClef:(BOOL)onClef onKeySig:(BOOL)onKeySig onTimeSig:(BOOL)onTimeSig button:(int)button;
- (BOOL)keyPressed:(NSEvent *)event onStaff:(Staff *)staff onMeasure:(Measure *)measure atXIndex:(float)x;
@end
