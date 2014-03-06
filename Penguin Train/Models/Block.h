//
//  Block.h
//  Penguin Train
//
//  Created by Victor Ingman on 2014-02-25.
//  Copyright (c) 2014 Victor Ingman. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BLOCK_SIZE 16
#define BLOCK 1

@interface Block : NSObject

@property (nonatomic) CGPoint point; //the position in block grid space.
@property (nonatomic) CGSize size; //size defined in blocks.

@property (nonatomic) BOOL active; //is the block still active?

- (Block *) initWithBlockPoint: (CGPoint) desiredPoint;
- (CGPoint)realPixelPoint; //the real pixel position.
- (CGSize)realPixelSize; //the real pixel size.

+ (NSNumber *)gamespeed;

@end
