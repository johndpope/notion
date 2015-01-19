#import <Foundation/Foundation.h>


@class MusicDocument;
@interface AppControl : NSObject {
    MusicDocument *testDoc;
    Song *song;
 
    NSMutableDictionary *db;
    NSMutableArray *loops;
}

@property MusicDocument *testDoc;

+ (AppControl *)cachedAppControl;

@end
