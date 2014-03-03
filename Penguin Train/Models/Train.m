//
//  Train.m
//  Penguin Train
//
//  Created by Victor Ingman on 2014-02-25.
//  Copyright (c) 2014 Victor Ingman. All rights reserved.
//

#import "Train.h"

#define PADDING BLOCK BLOCK//one block
#define STARTING_BLOCKS 4

@interface Train() {
    
    CGPoint startingPosition;
    
    CGVector currentDirections;
    CGVector lastDirections;
    
}

@property (nonatomic, readwrite) NSInteger identifier;

@end

@implementation Train

#pragma initiations

- (Train *) initWithIdentifier: (NSInteger) requestedIdentifier {
    
    self = [super init];
    
    if(self) {
        
        self.identifier = requestedIdentifier;
        self.colorIdentifier = [self.class colorForPlayerIdentifier:self.identifier];
        self.blockCount = STARTING_BLOCKS;
        self.dead = NO;
        self.score = [[ScoreCounter alloc] initScoreCounter];
        
        lastDirections.dx = DIRECTION_RIGHT;
        lastDirections.dy = DIRECTION_UNDEFINED;
        
        [self calculateStartingPosition];
        [self addStartingBlocks];
        
    }
    
    return self;
    
}

- (void) calculateStartingPosition {
    
    startingPosition.x = BLOCK; //one block
    startingPosition.y = self.identifier + BLOCK;
    
}

- (void) addStartingBlocks {
    
    for(int count = 0; count < STARTING_BLOCKS; count++) {
        
        CGPoint position;
        position.x = startingPosition.x * count;
        position.y = startingPosition.y;
        
        [self.blocks addObject:[[Block alloc] initWithBlockPoint:position]];
        
    }
    
}

- (Block *) getNextBlockPosition {
    
    CGPoint headPosition = [self headPosition];
    CGPoint nextPosition;
    
    nextPosition.x = (headPosition.x + currentDirections.dx);
    nextPosition.y = (headPosition.y + currentDirections.dy);
    
    return [[Block alloc] initWithBlockPoint:nextPosition];
    
}

- (CGPoint) headPosition {
    
    return [[self headBlock] point];
    
}

- (Block *) headBlock {
    
    return [self.blocks lastObject];
    
}

- (void) removeInvisibleBlocks {
    
    NSInteger everyBlockCount = [self.blocks count]; //maximum index -= 1
    
    if(everyBlockCount > self.blockCount) {
     
        NSRange blockIndexesToRemove;
        blockIndexesToRemove.location = 0;
        blockIndexesToRemove.length = (everyBlockCount - self.blockCount);
        
        [self.blocks removeObjectsInRange:blockIndexesToRemove];
        
    }
    
}

- (BOOL) directionsChanged {
    
    return ((currentDirections.dx == DIRECTION_UNDEFINED) && (currentDirections.dy == DIRECTION_UNDEFINED)) == NO;
    
}

- (BOOL) checkIfNextDirectionIsValid {
        
    //handles the speed turn bug
    if(currentDirections.dx != DIRECTION_UNDEFINED) {
        
        return ((lastDirections.dx * currentDirections.dx) > -1);
        
    } else if(currentDirections.dy != DIRECTION_UNDEFINED) {
        
        return ((lastDirections.dy * currentDirections.dy) > -1);
        
    }
    
    return NO;
    
}

- (void) setLastDirectionsAsCurrentDirections {
    
    currentDirections = lastDirections;
    
}

- (void) setDirectionsAsLastDirections {
    
    lastDirections = currentDirections;
    
}

- (BOOL) collisionWithSelf:(Block *)coordinateToCheck {
    
    for(Block * currentBlock in self.blocks) {
        
        if(CGPointEqualToPoint(currentBlock.point, coordinateToCheck.point)) {
            
            return YES;
            
        }
        
    }
    
    return NO;
    
}

#pragma functions

- (void) move {
    
    if(self.dead == NO) {
    
        if([self directionsChanged]) {
            
            if([self checkIfNextDirectionIsValid]) {
                
                [self setDirectionsAsLastDirections];
                
            } else {
                
                [self setLastDirectionsAsCurrentDirections]; //set old direction
                
            }
            
        } else {
            
            [self setLastDirectionsAsCurrentDirections]; //set old direction
            
        }
        
        if([self collisionWithSelf:[self getNextBlockPosition]] == NO) { //check collision with self.
            
            [self.blocks addObject:[self getNextBlockPosition]];
            [self removeInvisibleBlocks];
            
        } else {
            
            [self died];
            
        }
        
    }
    
}

- (void)ateBlock:(ActionBlock *)block {
    
    self.score.count += block.value;
    
    switch(block.type) {
    
        case TYPE_FOOD:
            
            self.blockCount++;
            
            break;
            
        case TYPE_BONUS:
            
            self.blockCount += 2;
            
            break;
            
    }
    
}

- (void) died {
    
    [self.score resetCounter];
    
    self.dead = YES;
    
}

- (void) setDirection:(CGVector)requestedDirections {
    
    /*The check if the direction is valid is made inside of the move method, as well as the checkIfNextDirectionIsValid*/
    currentDirections = requestedDirections;
    
}

#pragma getters

- (NSMutableArray *) blocks { //lazy instanziation.
    
    if(!_blocks) {
        
        _blocks = [[NSMutableArray alloc] init];
        
    }
    
    return _blocks;
    
}

#pragma class methods
+ (UIColor *) colorForPlayerIdentifier:(NSInteger)playerIdentifier {
    
    NSArray * colors = @[[UIColor redColor], [UIColor blueColor], [UIColor orangeColor]];
    
    return colors[playerIdentifier];
    
}

@end