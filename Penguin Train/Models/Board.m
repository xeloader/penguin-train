//
//  Board.m
//  Penguin Train
//
//  Created by Victor Ingman on 2014-02-25.
//  Copyright (c) 2014 Victor Ingman. All rights reserved.
//

#import "Board.h"

@interface Board() { }

@end

@implementation Board

- (Board *) initBoardWithBlockCountOf: (CGSize)requestedGrid {
    
    self = [super init];
    
    if(self) {
        
        self.grid = requestedGrid;
        
    }
    
    return self;
    
}

- (Board *) initWithRealDimensionOf:(CGSize)dimension {
    
    self = [super init];
    
    if(self) {
        
        self.grid = [self.class blockDimensionForDimension:dimension];
        
    }
    
    return self;
    
}

- (CGPoint)randomizePointInsideOfBoard {
    
    CGPoint randomPoint;
    randomPoint.x = arc4random() % (int)self.grid.width;
    randomPoint.y = arc4random() % (int)self.grid.height;
    
    return randomPoint;
    
}

- (BOOL) blockIsInsideBoard:(Block *)block {
    
    BOOL insideOfHorizontalSpan = ((block.point.x >= 0) && (block.point.x <= (self.grid.width - block.size.width))); //calculates the visual overflow as well. Remember to change if the anchor point is moved.
    BOOL insideOfVerticalSpan = ((block.point.y >= 0) && (block.point.y <= (self.grid.height - block.size.height)));
    
    return (insideOfHorizontalSpan && insideOfVerticalSpan);
    
}

+ (CGSize) blockDimensionForDimension:(CGSize)dimension {
    
    CGSize blockDimension;
    blockDimension.height = (int) ((dimension.height / BLOCK_SIZE) - 0.5 - BLOCK);
    blockDimension.width = (int) ((dimension.width / BLOCK_SIZE) + 0.5);
    
    return blockDimension;
    
}

- (CGSize) realDimension {
    
    CGSize realDimension;
    realDimension.height = self.grid.height * BLOCK_SIZE;
    realDimension.width = self.grid.width * BLOCK_SIZE;
    
    return realDimension;
    
}

@end
