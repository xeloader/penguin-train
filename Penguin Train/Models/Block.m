//
//  Block.m
//  Penguin Train
//
//  Created by Victor Ingman on 2014-02-25.
//  Copyright (c) 2014 Victor Ingman. All rights reserved.
//

#import "Block.h"

@implementation Block

- (Block *) initWithBlockPoint:(CGPoint)desiredPoint {
    
    self = [super init];
    
    if(self) {
        
        self.point = desiredPoint;
        self.size = CGSizeMake(1, 1); //1x1 block in size.
        self.active = YES;
        
    }
    
    return self;
    
}

- (CGSize)realPixelSize {
    
    CGSize realPixelSize;
    realPixelSize.width = self.size.width * BLOCK_SIZE;
    realPixelSize.height = self.size.height * BLOCK_SIZE;
    
    return realPixelSize;
    
}

- (CGPoint) realPixelPoint {
    
    CGPoint realPixelPoint;
    realPixelPoint.x = self.point.x * BLOCK_SIZE + (BLOCK_SIZE / 2); //as the anchor point is in the center of the block.
    realPixelPoint.y = self.point.y * BLOCK_SIZE + (BLOCK_SIZE / 2);
    
    return realPixelPoint;
    
}

+ (NSNumber *)gamespeed {
    
    return @100;
    
}

@end
