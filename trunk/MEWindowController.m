#import "MEWindowController.h"
#import "ScoreView.h"
#include <CoreMIDI/MIDIServices.h>
#import "CAMIDIEndpointMenu2.h"

@class StaffRuler;
@class StaffVerticalRuler;
#import "Note.h"
#import "Rest.h"
#import "Song.h"
#import "TempoData.h"
#import "ScoreController.h"
#import "StaffController.h"
#import "MeasureController.h"
#import "TimeSignatureController.h"
#import "ClefController.h"

@implementation MEWindowController

- (void)windowDidLoad{
	[view setFrameSize:[view calculateBounds].size];
	[verticalRuler setFrameSize:NSMakeSize([verticalRuler frame].size.width, [view frame].size.height)];
	[horizontalRuler setFrameSize:NSMakeSize([view frame].size.width, [horizontalRuler frame].size.height)];
}	

- (void)mouseMoved:(NSEvent *)event{
	[view mouseMoved:event];
}

- (IBAction)changeDuration:(id)sender{
	[[view window] makeFirstResponder:view];
}

- (IBAction)changeDotted:(id)sender{
	[[view window] makeFirstResponder:view];
}

- (IBAction)changeTriplet:(id)sender{
	[[view window] makeFirstResponder:view];
}

- (IBAction)changeAccidental:(id)sender{
	[[view window] makeFirstResponder:view];
	if(sharp != sender) [sharp setState:NSOffState];
	if(flat != sender) [flat setState:NSOffState];
	if(natural != sender) [natural setState:NSOffState];
}

- (IBAction)playSong:(id)sender{
	[[[self document] getSong] stopPlaying];
	[[[self document] getSong] playToEndpoint:[[[[NSApp mainMenu] itemWithTag:1] submenu] selectedEndpoint]];
}

- (IBAction)playSelection:(id)sender{
	[[[self document] getSong] stopPlaying];
	[[[self document] getSong] playToEndpoint:[[[[NSApp mainMenu] itemWithTag:1] submenu] selectedEndpoint] notesToPlay:[view selection]];
}

- (IBAction)stopSong:(id)sender{
	[[[self document] getSong] stopPlaying];
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
		} else if(![[verticalRuler subviews] containsObject:[staff rulerView]]){
			[verticalRuler addSubview:[staff rulerView]];
		}
		[[staff rulerView] setFrameOrigin:NSMakePoint(0, [StaffController baseOf:staff] -
													  [StaffController lineHeightOf:staff] * 3.0)];
	}
	NSEnumerator *tempos = [[[[self document] getSong] tempoData] objectEnumerator];
	id tempo;
	int i=0;
	while(tempo = [tempos nextObject]){
		if([tempo tempoPanel] == nil){
			[self addHorizontalRulerComponentFor:tempo];
		}
		[[tempo tempoPanel] setFrameOrigin:NSMakePoint([MeasureController xOf:[longest getMeasureAtIndex:i]], 1)];
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
		[staff refreshChannelButton];
	}
}

- (void)awakeFromNib{
	if(!didAwakeFromNib){
		didAwakeFromNib = YES;
		Song *song = [[self document] getSong];
		[song addObserver:self forKeyPath:@"staffs" options:NSKeyValueObservingOptionNew context:nil];
		[song addObserver:self forKeyPath:@"tempoData" options:NSKeyValueObservingOptionNew context:nil];
		[view setController:self];
		[view setSong:song];
		[[[[NSApp mainMenu] itemWithTag:1] submenu] buildMenu:kMIDIEndpointMenuDestinations opts:(kMIDIEndpointMenuOpt_SortByName | kMIDIEndpointMenuOpt_CanSelectNone)];
		[[scrollView contentView] setPostsBoundsChangedNotifications:YES];
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		[center addObserver:self selector:@selector(boundsDidChangeNotification:) name:NSViewBoundsDidChangeNotification
			object:[scrollView contentView]];
		[center addObserver:self selector:@selector(modelChanged:) name:@"modelChanged" object:nil];
		[self placeRulerComponents];
		[self addToolbarItemWithImage:[NSImage imageNamed:@"play.png"] identifier:@"play" label:@"Play" 
							  paletteLabel:@"Play" toolTip:@"Begin MIDI playback" target:self 
							   action:@selector(playSong:) keyEquiv:@"\r" isDefault:YES];
		[self addToolbarItemWithImage:[NSImage imageNamed:@"playsel.png"] identifier:@"playselected" label:@"Play selected" 
						 paletteLabel:@"Play selected" toolTip:@"Begin MIDI playback of selected notes" target:self 
							   action:@selector(playSelection:) keyEquiv:@"$\r" isDefault:YES];
		[self addToolbarItemWithImage:[NSImage imageNamed:@"stop.png"] identifier:@"stop" label:@"Stop" 
							  paletteLabel:@"Stop" toolTip:@"Stop MIDI playback" target:self 
							   action:@selector(stopSong:) keyEquiv:@"\033" isDefault:YES];
		[self addToolbarSeparator];

		[self addToolbarFlexibleSpace];
		[self addToolbarItemWithView:durationView identifier:@"duration" label:@"Duration" paletteLabel:@"Note duration" toolTip:nil 
							  target:self action:nil isDefault:YES];
		[self addToolbarItemWithView:accidentalView identifier:@"accidental" label:@"Accidentals" paletteLabel:@"Accidentals" toolTip:nil
							  target:self action:nil isDefault:YES];
		
		[[view window] setToolbar:[self initToolbarWithIdentifier:@"toolbar" customizable:NO]];
		
		[duration insertImages];
	}
}

- (void) boundsDidChangeNotification:(NSNotification *)notification{
	[[verticalRulerScroll contentView] scrollToPoint:NSMakePoint(0, [[scrollView contentView] bounds].origin.y)];
	[verticalRuler setNeedsDisplay:YES];
	[[horizontalRulerScroll contentView] scrollToPoint:NSMakePoint([[scrollView contentView] bounds].origin.x, 0)];
	[horizontalRuler setNeedsDisplay:YES];
}

- (void) modelChanged:(NSNotification *)notification{
	[view setFrameSize:[view calculateBounds].size];
	[view setNeedsDisplay:YES];
}

- (NSDictionary *)getMode{
	NSMutableDictionary *modeDict = [NSMutableDictionary dictionary];
	[modeDict setObject:[NSNumber numberWithInt:[self getPointerMode]] forKey:@"pointerMode"];
	[modeDict setObject:[NSNumber numberWithInt:[self getNoteModeDuration]] forKey:@"duration"];
	[modeDict setObject:[NSNumber numberWithInt:[self getAccidental]] forKey:@"accidental"];
	[modeDict setObject:[NSNumber numberWithBool:[self isDotted]] forKey:@"dotted"];
	[modeDict setObject:[NSNumber numberWithBool:[self isTriplet]] forKey:@"triplet"];
	[modeDict setObject:[NSNumber numberWithBool:[self isTieToPrev]] forKey:@"tieToPrev"];
	return modeDict;
}

- (int)getPointerMode{
	if([duration selectedTag] == 0) return MODE_POINT;
	return MODE_NOTE;
}

- (int)getNoteModeDuration{
	if([self getPointerMode] == MODE_POINT) return 0;
	int i = [duration selectedTag];
	int duration = 1;
	while(i > 1){
		duration *= 2;
		i--;
	}
	return duration;
}

- (BOOL)isDotted{
	return [dotted state] == NSOnState;
}

- (BOOL)isTriplet{
	return [triplet state] == NSOnState;
}

- (BOOL)isTieToPrev{
	return [tieToPrev state] == NSOnState;
}

- (int)getAccidental{
	if([flat state] == NSOnState) return FLAT;
	if([sharp state] == NSOnState) return SHARP;
	if([natural state] == NSOnState) return NATURAL;
	return NO_ACC;
}

- (id)targetAt:(NSPoint)location withEvent:(NSEvent *)event{
	id modeDict = [self getMode];
	return [self targetAt:location withEvent:event mode:modeDict];
}

- (id)targetAt:(NSPoint)location withEvent:(NSEvent *)event mode:(NSDictionary *)modeDict{
	id song = [[self document] getSong];
	return [ScoreController targetAtLocation:location inSong:song mode:modeDict withEvent:(NSEvent *)event];	
}

- (void)clickedAtLocation:(NSPoint)location withEvent:(NSEvent *)event{
	id modeDict = [self getMode];
	id song = [[self document] getSong];
	id target = [ScoreController targetAtLocation:location inSong:song mode:modeDict withEvent:(NSEvent *)event];
	if([[target getControllerClass] respondsToSelector:@selector(handleMouseClick:at:on:mode:view:)]){
		[[target getControllerClass] handleMouseClick:event at:location on:target mode:modeDict view:view];		
	}
}

- (BOOL)keyPressedAtLocation:(NSPoint)location withEvent:(NSEvent *)event{
	if([self handleToolbarKeystroke:event]){
		return YES;
	}
	id modeDict = [self getMode];
	id song = [[self document] getSong];
	id target = [ScoreController targetAtLocation:location inSong:song mode:modeDict withEvent:(NSEvent *)event];
	BOOL handled = [[target getControllerClass] respondsToSelector:@selector(handleKeyPress:at:on:mode:view:)] &&
		[[target getControllerClass] handleKeyPress:event at:location on:target mode:modeDict view:view];
	if(!handled){
		if([[event characters] rangeOfString:[NSString stringWithFormat:@"%C", NSLeftArrowFunctionKey]].location != NSNotFound){
			int sel = [duration selectedTag];
			if(sel > 0) sel--;
			[duration selectItemWithTag:sel];
			return YES;
		} else if([[event characters] rangeOfString:[NSString stringWithFormat:@"%C", NSRightArrowFunctionKey]].location != NSNotFound){
			int sel = [duration selectedTag];
			if(sel < [duration numberOfItems] - 1) sel++;
			[duration selectItemWithTag:sel];
			return YES;
		}		
	}
	return handled;
}

- (void)dragged:(id)target fromLocation:(NSPoint)fromLocation toLocation:(NSPoint)location withEvent:(NSEvent *)event finished:(BOOL)finished{
	if([[target getControllerClass] respondsToSelector:@selector(handleDrag:from:to:on:finished:mode:view:)]){
		id modeDict = [self getMode];
		[[target getControllerClass] handleDrag:event from:fromLocation to:location on:target finished:finished mode:modeDict view:view];
	}
}

- (void)paste:(id)data atLocation:(NSPoint)location{
	NSMutableDictionary *modeDict = [NSMutableDictionary dictionaryWithDictionary:[self getMode]];
	[modeDict setObject:@"paste" forKey:@"specialEvent"];
	id target = [self targetAt:location withEvent:nil mode:modeDict];
	if([[target getControllerClass] respondsToSelector:@selector(handlePaste:at:on:mode:)]){
		[[target getControllerClass] handlePaste:data at:location on:target mode:modeDict];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if([keyPath isEqualToString:@"staffs"] || [keyPath isEqualToString:@"tempoData"]){
		[self placeRulerComponents];
		[scrollView setNeedsDisplay:YES];
	}
}

@end
