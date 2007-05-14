//
//  MusicDocument.m
//  Music Editor
//
//  Created by Konstantine Prevas on 5/3/06.
//  Copyright Konstantine Prevas 2006 . All rights reserved.
//

#import "MusicDocument.h"

@implementation MusicDocument

- (id)init
{
    self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
    
    }
    return self;
}

- (id)initWithType:(NSString *)typeName error:(NSError **)outError{
	self = [super initWithType:typeName error:outError];
	if(self){
		[self setSong:[[Song alloc] initWithDocument:self]];
	}
	return self;
}

- (void)makeWindowControllers
{
	windowController = [[MEWindowController alloc] initWithWindowNibName:@"MusicDocument"];
	[self addWindowController:windowController];
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (Song *)getSong{
	return song;
}

- (void)setSong:(Song *)_song{
	if(![song isEqual:_song]){
		[song release];
		song = [_song retain];
		[song setDocument:self];
	}
}

-(NSData *)dataRepresentationOfType:(NSString *)aType{
	if([aType isEqualToString:@"MIDI file"]){
		return [song asMIDIData];
	}
	return [NSKeyedArchiver archivedDataWithRootObject:song];
}

-(BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType{
	if([aType isEqualToString:@"MIDI file"]){
		@try {
			NSAlert *alert = [NSAlert alertWithMessageText:@"Importing from a MIDI file is currently an experimental feature."
											 defaultButton:@"OK"
										   alternateButton:nil
											   otherButton:nil
								 informativeTextWithFormat:@"The resulting score may contain errors.  If so, please report a bug using the \"Report a Bug\" item in the \"Help\" menu, and attach the MIDI file to the bug report."];
			[alert runModal];
			[self setSong:[[Song alloc] initFromMIDI:data withDocument:self]];
		}
		@catch (NSException *exception) {
			NSAlert *alert = [NSAlert alertWithMessageText:@"The selected MIDI file was invalid or could not be imported."
											 defaultButton:@"OK"
										   alternateButton:nil
											   otherButton:nil
								 informativeTextWithFormat:[exception reason]];
			[alert runModal];
			return NO;
		}
		return YES;
	}
	[self setSong:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
	return YES;
}

- (void)printShowingPrintPanel:(BOOL)showPanels{
	NSPrintOperation *op = [NSPrintOperation printOperationWithView:[windowController view] printInfo:[self printInfo]];
	[op setShowPanels:showPanels];
	[self runModalPrintOperation:op delegate:nil didRunSelector:nil contextInfo:nil];
}

- (IBAction)goToHomepage:(id)sender{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.gusprevas.com/senorstaff/about"]];
}

- (IBAction)goToBugReport:(id)sender{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://code.google.com/p/senorstaff/issues/entry"]];	
}

@end
