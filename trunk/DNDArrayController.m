
#import "DNDArrayController.h"


NSString *MovedRowsType = @"MOVED_ROWS_TYPE";
NSString *CopiedRowsType = @"COPIED_ROWS_TYPE";

@implementation DNDArrayController

- (void)awakeFromNib{
    // register for drag and drop
    [tableView registerForDraggedTypes:
		[NSArray arrayWithObjects:MovedRowsType, CopiedRowsType, nil]];
    [tableView setAllowsMultipleSelection:YES];
	[tableView setVerticalMotionCanBeginDrag:YES];
	[tableView setDataSource:self];
	[super awakeFromNib];
}

- (BOOL)tableView:(NSTableView *)tv
		writeRows:(NSArray*)rows
	 toPasteboard:(NSPasteboard*)pboard{
	// declare our own pasteboard types
    NSArray *typesArray = [NSArray arrayWithObjects:MovedRowsType, CopiedRowsType, nil];
	
	[pboard declareTypes:typesArray owner:self];
	
    // add rows array for local move
    [pboard setPropertyList:rows forType:MovedRowsType];
	
	// create new array of selected rows for remote drop
    // could do deferred provision, but keep it direct for clarity
	NSMutableArray *rowCopies = [NSMutableArray arrayWithCapacity:[rows count]];    
	NSEnumerator *rowEnumerator = [rows objectEnumerator];
	NSNumber *idx;
	while (idx = [rowEnumerator nextObject]) {
		[rowCopies addObject:[[self arrangedObjects] objectAtIndex:[idx intValue]]];
	}

	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowCopies];
	[pboard setData:data forType:CopiedRowsType];
	
    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv
				validateDrop:(id <NSDraggingInfo>)info
				 proposedRow:(int)row
	   proposedDropOperation:(NSTableViewDropOperation)op{
    
	if(![self isEditable]){
		return NSDragOperationNone;
	}
	
    NSDragOperation dragOp = NSDragOperationCopy;
    
    // if drag source is self, it's a move
    if ([info draggingSource] == tableView) {
		dragOp =  NSDragOperationMove;
    }
    // we want to put the object at, not over,
    // the current row (contrast NSTableViewDropOn) 
    [tv setDropRow:row dropOperation:NSTableViewDropAbove];
	
    return dragOp;
}

- (BOOL)tableView:(NSTableView*)tv
	   acceptDrop:(id <NSDraggingInfo>)info
			  row:(int)row
	dropOperation:(NSTableViewDropOperation)op{
	
	if (![self isEditable]){
		return NO;
	}
	
    if (row < 0) {
		row = 0;
	}
    
    // if drag source is self, it's a move
    if ([info draggingSource] == tableView) {
		
		NSArray *rows = [[info draggingPasteboard] propertyListForType:MovedRowsType];
		NSIndexSet  *indexSet = [self indexSetFromRows:rows];
		
		[self moveObjectsInArrangedObjectsFromIndexes:indexSet toIndex:row];
		
		// set selected rows to those that were just moved
		// Need to work out what moved where to determine proper selection...
		int rowsAbove = [self rowsAboveRow:row inIndexSet:indexSet];
		
		NSRange range = NSMakeRange(row - rowsAbove, [indexSet count]);
		indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
		[self setSelectionIndexes:indexSet];
		
		return YES;
    }
	
	// Can we get rows from another document?  If so, add them, then return.
	NSData *data = [[info draggingPasteboard] dataForType:CopiedRowsType];
	NSArray *newRows = [NSKeyedUnarchiver unarchiveObjectWithData:data];

	if (newRows) {
		NSRange range = NSMakeRange(row, [newRows count]);
		NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
		
		[self insertObjects:newRows atArrangedObjectIndexes:indexSet];
		// set selected rows to those that were just copied
		[self setSelectionIndexes:indexSet];
		return YES;
    }
	
    return NO;
}

- (void)insertObject:(id)object atArrangedObjectIndex:(unsigned int)index{
	NSArray *objects = [self arrangedObjects];
	int i;
	for(i = 0; i < [objects count]; i++){
		if([[objects objectAtIndex:i] isEqual:object]){
			[self removeObjectAtArrangedObjectIndex:i];
			if(i < index){
				index--;
			}
		}
	}
	[super insertObject:object atArrangedObjectIndex:index];
}

-(void) moveObjectsInArrangedObjectsFromIndexes:(NSIndexSet*)indexSet
										toIndex:(unsigned int)insertIndex{

    NSArray *objects = [self arrangedObjects];
	int	index = [indexSet lastIndex];
	
    int	aboveInsertIndexCount = 0;
    id object;
    int	removeIndex;
	
    while (NSNotFound != index) {
		if (index >= insertIndex) {
			removeIndex = index + aboveInsertIndexCount;
			aboveInsertIndexCount += 1;
		}
		else {
			removeIndex = index;
			insertIndex -= 1;
		}
		object = [objects objectAtIndex:removeIndex];
		[self removeObjectAtArrangedObjectIndex:removeIndex];
		[self insertObject:object atArrangedObjectIndex:insertIndex];
		
		index = [indexSet indexLessThanIndex:index];
    }
}

- (NSIndexSet *)indexSetFromRows:(NSArray *)rows{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    NSEnumerator *rowEnumerator = [rows objectEnumerator];
    NSNumber *idx;
    while (idx = [rowEnumerator nextObject]) {
		[indexSet addIndex:[idx intValue]];
    }
    return indexSet;
}

- (int)rowsAboveRow:(int)row inIndexSet:(NSIndexSet *)indexSet{
    unsigned currentIndex = [indexSet firstIndex];
    int i = 0;
    while (currentIndex != NSNotFound) {
		if (currentIndex < row) { i++; }
		currentIndex = [indexSet indexGreaterThanIndex:currentIndex];
    }
    return i;
}

@end
