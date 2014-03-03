//
//  ActionBlock.h
//  Penguin Train
//
//  Created by Victor Ingman on 2014-02-25.
//  Copyright (c) 2014 Victor Ingman. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Block.h"

#define TYPE_RANDOM -1
#define TYPE_FOOD 1
#define TYPE_BONUS 2
#define TYPE_BONUSRAIN 3

#define CHANCE_BONUS 50

#define LIFECYCLE_INVINCIBLE -1
#define LIFECYCLE_DEAD 0

@interface ActionBlock : Block

@property (nonatomic) UIColor * colorIdentifier;
@property (nonatomic, setter = setType:) NSInteger type;
@property (nonatomic) NSInteger value; //the value of the actionblock given when eaten.

@property (nonatomic) BOOL recentlyEaten; //this will be set to yes when something eats it, then reset by the loop.
@property (nonatomic) int lifeCycles; //decremements once eaten.
@property (nonatomic) float loopCycles; //decrements by one every time the game loop is executed.

- (void) eaten;
- (ActionBlock *) initActionBlockAsType:(NSInteger)requestedType atPoint:(CGPoint)startingPoint;
- (void)randomizeNextActionBlock;
- (void)decrementLoopCycle;

+ (NSArray *)everyType;

@end
