//
//  NSCollections+CHOMPIteration.h
//  Chomp
//
//  Created by Michael Ash on 12/16/04.
//

#import <Cocoa/Cocoa.h>


@interface NSMutableArray (CHOMPIteration)

- collect;
- do;
- each;

@end

@interface NSMutableSet (CHOMPIteration)

- collect;
- do;
- each;

@end

@interface NSMutableDictionary (CHOMPIteration)

- collect;
- do;
- each;

@end
