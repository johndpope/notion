//
//  NSPopUpButton+Images.m
//
//  Created by Konstantine Prevas on 11/26/06.
//
//  The source code in this file is available in the public domain.  Permission is granted to use,
//  modify, or distribute it; however, it is provided "as is" and without warranties as to performance or merchantability.
//

#import "NSPopUpButton+Images.h"


@implementation NSPopUpButton(Images)

- (void)insertImages{
	NSEnumerator *items = [[self itemArray] objectEnumerator];
	id item;
	while(item = [items nextObject]){
		NSString *title = [item title];
		if([title characterAtIndex:0] == '{'){
			NSRange endIndex = [title rangeOfString:@"}"];
			NSString *filename = [title substringWithRange:NSMakeRange(1, endIndex.location - 1)];
			NSString *titleText = [title substringFromIndex:(endIndex.length + endIndex.location)];
			NSTextAttachment *attachment = [[[NSTextAttachment alloc] init] autorelease];
			NSCell *cell = [attachment attachmentCell];
			NSImage *icon = [NSImage imageNamed:filename];
			[cell setImage:icon];
			NSFont *font = [NSFont systemFontOfSize:[NSFont systemFontSize]];
			NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
			NSAttributedString *attrString = [[[NSAttributedString alloc] initWithString:titleText attributes:attr] autorelease];
			NSMutableAttributedString *attrTitle = [NSMutableAttributedString attributedStringWithAttachment:attachment];
			[attrTitle appendAttributedString:attrString];
			[item setAttributedTitle:attrTitle];
		}
	}
}

@end
