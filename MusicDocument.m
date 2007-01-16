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
	}
}

-(NSData *)dataRepresentationOfType:(NSString *)aType{
	return [NSKeyedArchiver archivedDataWithRootObject:song];
}

-(BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType{
	[self setSong:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
	return YES;
}

- (IBAction)goToHomepage:(id)sender{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.gusprevas.com/senorstaff/about"]];
}

- (IBAction)goToBugReport:(id)sender{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://code.google.com/p/senorstaff/issues/list"]];	
}

@end
