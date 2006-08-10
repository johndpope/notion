#import "MEWindowController.h"
#import "StaffView.h"
#include <CoreMIDI/MIDIServices.h>
#import "CAMIDIEndpointMenu2.h"

@class StaffRuler;
@class StaffVerticalRuler;
#import "Note.h"
#import "Song.h"
#import "TempoData.h"

@implementation MEWindowController

- (void)windowDidLoad{
	[self updateFeedbackDuration];
	[view setFrameSize:[view calculateBounds].size];
	[verticalRuler setFrameSize:NSMakeSize([verticalRuler frame].size.width, [view frame].size.height)];
	[horizontalRuler setFrameSize:NSMakeSize([view frame].size.width, [horizontalRuler frame].size.height)];
}

- (void)mouseMoved:(NSEvent *)event{
	[view mouseMoved:event];
}

- (IBAction)changeDuration:(id)sender{
	[[view window] makeFirstResponder:view];
	[self updateFeedbackDuration];
}

- (IBAction)changeDotted:(id)sender{
	[[view window] makeFirstResponder:view];
	[self updateFeedbackDotted];
}

- (IBAction)changeAccidental:(id)sender{
	[[view window] makeFirstResponder:view];
	if(sharp != sender) [sharp setState:NSOffState];
	if(flat != sender) [flat setState:NSOffState];
	if(natural != sender) [natural setState:NSOffState];
	[self updateFeedbackAccidental];
}

- (void)updateFeedbackDuration{
	[view setFeedbackNoteDuration:[self getNoteModeDuration]];
}

- (void)updateFeedbackDotted{
	[view setFeedbackNoteDotted:[self getDotted]];
}

- (void)updateFeedbackAccidental{
	[view setFeedbackNoteAccidental:[self getAccidental]];
}

- (IBAction)playSong:(id)sender{
	[[[self document] getSong] playToEndpoint:[devicePopup selectedEndpoint]];
}

- (IBAction)addStaff:(id)sender{
	[[[self document] getSong] addStaff];
	[self placeRulerComponents];
}

- (void)setupStaff:(Staff *)staff{
	[self addVerticalRulerComponentFor:staff];
	[view setNeedsDisplay:YES];
}

- (void)placeRulerComponents{
	NSEnumerator *staffs = [[[[self document] getSong] staffs] objectEnumerator];
	id staff, longest = nil;
	while(staff = [staffs nextObject]){
		if(longest == nil || [[staff getMeasures] count] > [[longest getMeasures] count]){
			longest = staff;
		}
		if([staff rulerView] == nil){
			[self setupStaff:staff];
		}
		[[staff rulerView] setFrameOrigin:NSMakePoint(0, [view calcStaffBase:staff fromTop:[view calcStaffTop:staff]] -
													[view calcStaffLineHeight:staff] * 5.0)];
	}
	NSEnumerator *tempos = [[[[self document] getSong] tempoData] objectEnumerator];
	id tempo;
	int i=0;
	while(tempo = [tempos nextObject]){
		if([tempo tempoPanel] == nil){
			[self addHorizontalRulerComponentFor:tempo];
		}
		[[tempo tempoPanel] setFrameOrigin:NSMakePoint([view getXForMeasure:[[longest getMeasures] objectAtIndex:i] forStaff:longest], 1)];
		i++;
	}
	[view setFrameSize:[view calculateBounds].size];
	[verticalRuler setFrameSize:NSMakeSize([verticalRuler frame].size.width, [view frame].size.height)];
	[horizontalRuler setFrameSize:NSMakeSize([view frame].size.width, [horizontalRuler frame].size.height)];
	[verticalRuler setNeedsDisplay:YES];
	[horizontalRuler setNeedsDisplay:YES];
}

- (void)addHorizontalRulerComponentFor:(TempoData *)tempo{
	if([NSBundle loadNibNamed:@"StaffHorizontalRulerComponent" owner:tempo]){
		[horizontalRuler addSubview:[tempo tempoPanel]];
		[[tempo tempoPanel] setHidden:YES];
		[tempo refreshTempo];
	}
}

- (void)addVerticalRulerComponentFor:(Staff *)staff{
	if([NSBundle loadNibNamed:@"StaffVerticalRulerComponent" owner:staff]){
		[verticalRuler addSubview:[staff rulerView]];
	}
}

- (void)showKeySigPanelFor:(Measure *)measure onStaff:(Staff *)staff{
	NSView *keySigPanel = [measure getKeySigPanel];
	if([keySigPanel superview] == nil){
		[view addSubview:keySigPanel];
		float x, y;
		x = [view getXForMeasure:measure forStaff:staff] + [view calcClefWidth:measure] + [view calcTimeSignatureWidth:measure];
		y = [view calcStaffTop:staff];
		[keySigPanel setFrameOrigin:NSMakePoint(x, y)];
		[keySigPanel setHidden:NO withFade:YES blocking:NO];
	}
	if([measure isShowingTimeSigPanel]) [measure timeSigClose:nil];
	[view setNeedsDisplay:YES];
}

- (void)showTimeSigPanelFor:(Measure *)measure onStaff:(Staff *)staff{
	NSView *timeSigPanel = [measure getTimeSigPanel];
	if([timeSigPanel superview] == nil){
		[view addSubview:timeSigPanel];
		float x, y;
		x = [view getXForMeasure:measure forStaff:staff] + [view calcClefWidth:measure];
		y = [view calcStaffTop:staff];
		[timeSigPanel setFrameOrigin:NSMakePoint(x, y)];
		[timeSigPanel setHidden:NO withFade:YES blocking:NO];
	}
	if([measure isShowingKeySigPanel]) [measure keySigClose:nil];
	[view setNeedsDisplay:YES];
}

- (void)awakeFromNib{
	Song *song = [[self document] getSong];
	[song addObserver:self forKeyPath:@"staffs" options:NSKeyValueObservingOptionNew context:nil];
	[song addObserver:self forKeyPath:@"tempoData" options:NSKeyValueObservingOptionNew context:nil];
	[view setController:self];
	[view setSong:song];
	[devicePopup buildMenu:kMIDIEndpointMenuDestinations opts:(kMIDIEndpointMenuOpt_SortByName | kMIDIEndpointMenuOpt_CanSelectNone)];
	[[scrollView contentView] setPostsBoundsChangedNotifications:YES];
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(boundsDidChangeNotification:) name:NSViewBoundsDidChangeNotification
		object:[scrollView contentView]];
	[self placeRulerComponents];
	
}

- (void) boundsDidChangeNotification:(NSNotification *)notification{
	[[verticalRulerScroll contentView] scrollToPoint:NSMakePoint(0, [[scrollView contentView] bounds].origin.y)];
	[verticalRuler setNeedsDisplay:YES];
	[[horizontalRulerScroll contentView] scrollToPoint:NSMakePoint([[scrollView contentView] bounds].origin.x, 0)];
	[horizontalRuler setNeedsDisplay:YES];
}

- (int)getMode{
	if([mode selectedColumn] == 0) return MODE_POINT;
	return MODE_NOTE;
}

- (int)getNoteModeDuration{
	if([self getMode] == MODE_POINT) return 0;
	int i = [mode selectedColumn];
	int duration = 1;
	while(i > 1){
		duration *= 2;
		i--;
	}
	return duration;
}

- (BOOL)getDotted{
	return [dotted state] == NSOnState;
}

- (int)getAccidental{
	if([flat state] == NSOnState) return FLAT;
	if([sharp state] == NSOnState) return SHARP;
	if([natural state] == NSOnState) return NATURAL;
	return NO_ACC;
}

- (void)clickedAtLocation:(NSPoint)location onStaff:(Staff *)staff onMeasure:(Measure *)measure
				atPitch:(int)pitch atOctave:(int)octave atXIndex:(float)x 
				onClef:(BOOL)onClef onKeySig:(BOOL)onKeySig onTimeSig:(BOOL)onTimeSig button:(int)button{
	if([self getMode] == MODE_NOTE){
		Note *note = [[Note alloc] initWithPitch:pitch octave:octave duration:[self getNoteModeDuration] dotted:[self getDotted] accidental:[self getAccidental]];
		note = [measure addNotes:[NSArray arrayWithObject:note] atIndex:x];
		measure = [staff getMeasureContainingNote:note];
		if([tieToPrev state] == NSOnState){
			[note setAccidental:NO_ACC];
			Note *tie = [staff findPreviousNoteMatching:note inMeasure:measure atIndex:ceil(x)];
			[note tieFrom:tie];
			[tie tieTo:note];
		}
		if([measure isFull]) [staff getMeasureAfter:measure];
	} else if([self getMode] == MODE_POINT){
		if(onClef){
			[staff toggleClefAtMeasure:measure];
		} else if(onTimeSig){
			[self showTimeSigPanelFor:measure onStaff:staff];
		} else if(onKeySig){
			[self showKeySigPanelFor:measure onStaff:staff];
		}
	}
}

- (BOOL)keyPressed:(NSEvent *)event onStaff:(Staff *)staff onMeasure:(Measure *)measure atXIndex:(float)x{
	if([[event characters] rangeOfString:[NSString stringWithFormat:@"%C", NSLeftArrowFunctionKey]].location != NSNotFound){
		int row = [mode selectedRow];
		int col = [mode selectedColumn]-1;
		if(col < 0) col = 0;
		[mode selectCellAtRow:row column:col];
		[self updateFeedbackDuration];
		return YES;
	} else if([[event characters] rangeOfString:[NSString stringWithFormat:@"%C", NSRightArrowFunctionKey]].location != NSNotFound){
		int row = [mode selectedRow];
		int col = [mode selectedColumn]+1;
		if(col > [mode numberOfColumns]-1) col = [mode numberOfColumns]-1;
		[mode selectCellAtRow:row column:col];
		[self updateFeedbackDuration];
		return YES;
	} else if([[event characters] rangeOfString:[NSString stringWithFormat:@"%C", NSDeleteCharacter]].location != NSNotFound){
		[measure removeNoteAtIndex:x temporary:NO];
		return YES;
	} else if([self getMode] == MODE_NOTE && [[event characters] isEqualToString:@" "]){
		[measure addNotes:[NSArray arrayWithObject:[[Note alloc] initRestWithDuration:[self getNoteModeDuration] dotted:[self getDotted]]] atIndex:x];
		if([measure isFull]) [staff getMeasureAfter:measure];
		return YES;
	}
	return NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if([keyPath isEqualToString:@"staffs"] || [keyPath isEqualToString:@"tempoData"]){
		[self placeRulerComponents];
		[scrollView setNeedsDisplay:YES];
	}
}

@end
