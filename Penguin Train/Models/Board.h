//
//  Board.h
//  Penguin Train
//
//  Created by Victor Ingman on 2014-02-25.
//  Copyright (c) 2014 Victor Ingman. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Block.h"

@interface Board : NSObject

@property (nonatomic) CGSize grid;

- (BOOL) blockIsInsideBoard:(Block *)block;
- (Board *) initBoardWithBlockCountOf: (CGSize)requestedGrid;
- (CGSize) realDimension;
- (CGPoint)randomizePointInsideOfBoard;

+ (CGSize) blockDimensionForDimension:(CGSize)dimension;

@end
