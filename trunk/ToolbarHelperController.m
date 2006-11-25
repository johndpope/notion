//
//  ToolbarHelperController.m
//  Se–or Staff
//
//  Created by Konstantine Prevas on 11/19/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "ToolbarHelperController.h"


@implementation ToolbarHelperController

- (void) _addToolbarItemWithImage:(NSImage *)image
							 view:(NSView *)view
					   identifier:(NSString *)identifier
							label:(NSString *)label
					 paletteLabel:(NSString *)paletteLabel
						  toolTip:(NSString *)toolTip
						   target:(id)target
						   action:(SEL)action
						 keyEquiv:(NSString *)keyEquiv
						isDefault:(BOOL)isDefault{
	NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:identifier] autorelease];
	if(image != nil){
		[item setImage:image];
		if(keyEquiv != nil){
			if(imageItemKeys == nil){
				imageItemKeys = [[NSMutableDictionary dictionary] retain];
			}
			[imageItemKeys setValue:identifier forKey:keyEquiv];			
		}
	} else if(view != nil){
		if(customViews == nil){
			customViews = [[NSMutableArray array] retain];
		}
		[customViews addObject:view];
		[item setView:view];
	}
	[item setLabel:label];
	[item setPaletteLabel:paletteLabel];
	[item setToolTip:toolTip];
	[item setTarget:target];
	[item setAction:action];
	if(toolbarItems == nil){
		toolbarItems = [[NSMutableDictionary dictionary] retain];
	}
	if(idList == nil){
		idList = [[NSMutableArray array] retain];
	}
	if(defaultIdList == nil){
		defaultIdList = [[NSMutableArray array] retain];
	}
	[toolbarItems setObject:item forKey:identifier];
	[idList addObject:identifier];
	if(isDefault){
		[defaultIdList addObject:identifier];
	}
}

- (void) addToolbarItemWithImage:(NSImage *)image
					  identifier:(NSString *)identifier
						   label:(NSString *)label
					paletteLabel:(NSString *)paletteLabel
						 toolTip:(NSString *)toolTip
						  target:(id)target
						  action:(SEL)action
						keyEquiv:(NSString *)keyEquiv
					   isDefault:(BOOL)isDefault{
	[self _addToolbarItemWithImage:image view:nil identifier:identifier label:label paletteLabel:paletteLabel
						   toolTip:toolTip target:target action:action keyEquiv:keyEquiv isDefault:isDefault];
}

- (void) addToolbarItemWithView:(NSView *)view
					 identifier:(NSString *)identifier
						  label:(NSString *)label
				   paletteLabel:(NSString *)paletteLabel
						toolTip:(NSString *)toolTip
						 target:(id)target
						 action:(SEL)action
					  isDefault:(BOOL)isDefault{
	[self _addToolbarItemWithImage:nil view:view identifier:identifier label:label paletteLabel:paletteLabel
						   toolTip:toolTip target:target action:action keyEquiv:nil isDefault:isDefault];
}

- (void) addToolbarSeparator{
	[defaultIdList addObject:NSToolbarSeparatorItemIdentifier];
}

- (void) addToolbarSpace{
	[defaultIdList addObject:NSToolbarSpaceItemIdentifier];
}

- (void) addToolbarFlexibleSpace{
	[defaultIdList addObject:NSToolbarFlexibleSpaceItemIdentifier];
}

- (void) allowToolbarSeparator{
	[idList addObject:NSToolbarSeparatorItemIdentifier];
}

- (void) allowToolbarSpace{
	[idList addObject:NSToolbarSpaceItemIdentifier];
}

- (void) allowToolbarFlexibleSpace{
	[idList addObject:NSToolbarFlexibleSpaceItemIdentifier];
}

- (NSToolbar *) initToolbarWithIdentifier:(NSString *)identifier customizable:(BOOL)customizable{
	NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier:identifier] autorelease];
	[toolbar setDelegate:self];
	[toolbar setAllowsUserCustomization:customizable];
	[toolbar setAutosavesConfiguration:customizable];
	return toolbar;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)identifier willBeInsertedIntoToolbar:(BOOL)flag{
	NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:identifier] autorelease];
	NSToolbarItem *template = [toolbarItems objectForKey:identifier];
	if([template image] != nil){
		[item setImage:[template image]];
	} else if([template view] != nil){
		[item setView:[template view]];
		[item setMinSize:[[template view] bounds].size];
		[item setMaxSize:[[template view] bounds].size];
	}
	[item setLabel:[template label]];
	[item setPaletteLabel:[template paletteLabel]];
	[item setToolTip:[template toolTip]];
	[item setTarget:[template target]];
	[item setAction:[template action]];
	return item;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar{
    return defaultIdList;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar{
    return idList;
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem{
    return YES;
}

- (BOOL)handleToolbarKeystroke:(NSEvent *)event{
	BOOL handled = NO;
	NSString *imageItemIdentifier = [imageItemKeys objectForKey:[event characters]];
	if(imageItemIdentifier != nil){
		NSEnumerator *visItems = [[[[self window] toolbar] visibleItems] objectEnumerator];
		id item;
		while(item = [visItems nextObject]){
			if([[item itemIdentifier] isEqualTo:imageItemIdentifier]){
				[[item target] performSelector:[item action]];
				handled = YES;
			}
		}
	}
	NSEnumerator *viewsEnum = [customViews objectEnumerator];
	id view;
	while(view = [viewsEnum nextObject]){
		if([view performKeyEquivalent:event]){
			handled = YES;
		}
	}
	return handled;
}

- (void) dealloc{
	[toolbarItems release];
	[idList release];
	[defaultIdList release];
	[customViews release];
	[imageItemKeys release];
	[super dealloc];
}

@end
