//
//  NSData+SnapAdditions.m
//  Snap
//
//  Created by Scott Gardner on 12/19/12.
//  Copyright (c) 2012 inyago LLC. All rights reserved.
//

#import "NSData+SnapAdditions.h"
#import <Cocoa/Cocoa.h>


@implementation NSData (SnapAdditions)

// These methods assume the data is in network byte-order (big endian) and so use ntohs() and ntohl() to convert them back to host byte-order

- (char)rw_int8AtOffset:(size_t)offset {
    const char *charBytes = (const char *)[self bytes];
    return charBytes[offset];
}

- (short)rw_int16AtOffset:(size_t)offset {
    const short *shortBytes = (const short *)[self bytes];
    return ntohs(shortBytes[offset / 2]);
}
- (short)big_rw_int16AtOffset:(size_t)offset {
    const short *shortBytes = (const short *)[self bytes];
    return (shortBytes[offset / 2]);
}

- (int)rw_int32AtOffset:(size_t)offset {
    const int *intBytes = (const int *)[self bytes];
    return ntohl(intBytes[offset / 4]);
}

- (NSString *)rw_stringAtOffset:(size_t)offset bytesRead:(size_t *)amount {
    const char *charBytes = (const char *)[self bytes];
    NSString *string = [NSString stringWithUTF8String:charBytes + offset]; // @(charBytes + offset);
    *amount = strlen(charBytes + offset) + 1;
    return string;
}

@end

@implementation NSMutableData (SnapAdditions)

/*
 About htons() and htonl():
 These functions are called on value to ensure it is always transmitted in "network byte order," which happens
 to be big endian. However, the current processors are x86 and ARM CPUs which use little endian. We could send
 value as-is, but what if a new model iPhone comes out that uses a different byte ordering, and then the byte
 ordering one device sends to another could be different and thus incompatible? To plan ahead for this
 possibility, we decide on one specific byte ordering: big endian (ideal for network programming).
 
 int value = 0x11223344
 
 [11][22][33][44]   [44][33][22][11]
 Big endian         Little endian
 (network order)
 */

- (void)rw_appendInt8:(char)value {
    [self appendBytes:&value length:1];
}

- (void)rw_appendInt16:(short)value {
    value = htons(value);
    [self appendBytes:&value length:2];
}

- (void)rw_appendInt32:(int)value {
    value = htonl(value);
    [self appendBytes:&value length:4];
}

- (void)rw_appendString:(NSString *)string {
    const char *cString = [string UTF8String];
    [self appendBytes:cString length:strlen(cString) + 1]; // +1 for UTF8String's nill-termination byte
}

@end
