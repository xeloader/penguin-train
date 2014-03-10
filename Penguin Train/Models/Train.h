//
//  Train.h
//  Penguin Train
//
//  Created by Victor Ingman on 2014-02-25.
//  Copyright (c) 2014 Victor Ingman. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ActionBlock.h"
#import "ScoreCounter.h"

#define DIRECTION_LEFT -1
#define DIRECTION_RIGHT 1
#define DIRECTION_UP 1
#define DIRECTION_DOWN -1
#define DIRECTION_UNDEFINED 0

@interface Train : NSObject

@property (nonatomic, readonly) NSInteger identifier;
@property (nonatomic) UIColor * colorIdentifier;

@property (nonatomic) BOOL dead;

@property (nonatomic) NSInteger blockCount;
@property (nonatomic) NSMutableArray * blocks;
@property (nonatomic) ScoreCounter * score;

- (void) move;
- (void) died;
- (Train *) initWithIdentifier: (NSInteger) playerIdentifier;
- (CGPoint) headPosition;
- (Block *) headBlock;
- (void) setDirection:(CGVector)requestedDirections;
- (void)ateBlock:(ActionBlock *)block;
- (CGVector)lastDirections;

@end
