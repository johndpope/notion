//
//  NSData+SnapAdditions.h
//  Snap
//
//  Created by Scott Gardner on 12/19/12.
//  Copyright (c) 2012 inyago LLC. All rights reserved.
//

@interface NSData (SnapAdditions)

- (char)rw_int8AtOffset:(size_t)offset;
- (short)rw_int16AtOffset:(size_t)offset; //assumes the data is in network byte-order (big endian) int value = 0x11223344   [11][22][33][44]
- (int)rw_int32AtOffset:(size_t)offset;
- (NSString *)rw_stringAtOffset:(size_t)offset bytesRead:(size_t *)amount;

@end

@interface NSMutableData (SnapAdditions)

- (void)rw_appendInt8:(char)value;
- (void)rw_appendInt16:(short)value;
- (void)rw_appendInt32:(int)value;
- (void)rw_appendString:(NSString *)string;

@end
