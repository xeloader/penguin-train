//
//  Game.m
//  Penguin Train
//
//  Created by Victor Ingman on 2014-02-25.
//  Copyright (c) 2014 Victor Ingman. All rights reserved.
//

#import "Game.h"

#define MAXIMUM_PLAYER_COUNT 2

@implementation Game

- (Game *) initGameForPlayers:(NSInteger)playerCount onGridDimension:(CGSize)gridDimension {
    
    self = [super init];
    
    if(self) {
        
        [self setDefaultSettingsForPlayers:playerCount onGridDimension:gridDimension];
        
    }
    
    return self;
    
}

- (void)setDefaultSettingsForPlayers:(NSInteger)playerCount onGridDimension:(CGSize)gridDimension  {
    
    //the gamespeed is set in block.h because of inheritance.
    self.paused = NO;
    self.gameSpeed = [Block gamespeed]; //ms
    
    /*TRAINS*/
    for(int count = 0; count < playerCount; count++) {
        
        Train * playerTrain = [[Train alloc] initWithIdentifier:count];
        
        [self.trains addObject:playerTrain];
        
    }
    
    /*BOARD*/
    self.board = [[Board alloc] initBoardWithBlockCountOf:gridDimension]; //?x? blocks
    
    /*ACTIONBLOCKS*/
    ActionBlock * actionBlock = [[ActionBlock alloc] initActionBlockAsType:TYPE_RANDOM atPoint:[self.board randomizePointInsideOfBoard]];
    
    [self.actionBlocks addObject:actionBlock];
    
    /*TIMER*/
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:[self gameSpeedInSeconds]
                                                      target:self
                                                    selector:@selector(loop)
                                                    userInfo:nil
                                                     repeats:YES];
    
    [self performSelectorOnMainThread:@selector(loop)
                           withObject:nil
                        waitUntilDone:YES];
    
}

- (void) loop {
    
    if(!self.paused) {
    
        if([self gameIsStillOn]) {
            
            for(Train * playerTrain in self.trains) {
                
                if([self trainInsideBoard:playerTrain]) {
                    
                    [playerTrain move];
                    [self collisionWithActionBlockForTrain:playerTrain]; //looking for collisions with actionblocks.
                    
                } else {
                    
                    [playerTrain died];
                    
                }
                
            }
            
            [self performDecrementLoopOnActionBlocks]; //temporary actionblocks.
            [self performActionsOnInactiveActionBlocks]; //always last.
            
        } else {
            
            [self setViewKey:@"died" forData:[NSNumber numberWithBool:YES]];
            
            Board * board = self.board;
            NSInteger players = [self.trains count];
            
            [self reset];
            [self setDefaultSettingsForPlayers:players onGridDimension:[board grid]];
            
        }
        
    }
    
}

- (void)reset {
    
    self.trains = nil;
    self.board = nil;
    self.actionBlocks = nil;
    
    self.gameSpeed = nil;
    
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    
}

- (BOOL)gameIsStillOn {
    
    NSInteger deadCount = 0;
    
    for(Train * playerTrain in self.trains) {
        
        if(playerTrain.dead == YES) {
            
            deadCount++;
            
        }
        
    }
    
    return(deadCount < [self.trains count]);
    
    
}

- (float)gameSpeedInSeconds {
    
    return ([self.gameSpeed floatValue] / 1000);
    
}

- (void)collisionWithActionBlockForTrain:(Train *)train {
    
    BOOL collision = NO;
    NSInteger collisionBlock;
    NSInteger collisionValue = 0; //total of eaten blocks.
    
    for(ActionBlock * actionBlock in self.actionBlocks) {
        
        if(CGPointEqualToPoint([train headPosition], actionBlock.point)) {
            
            collisionValue += actionBlock.value;
            
            [train ateBlock:actionBlock];
            [actionBlock eaten];
            
            collision = YES;
            collisionBlock = actionBlock.type;
            
        }
        
    }
    
    if(collision) {
        
        [self setViewKey:@"blocktype" forData:[NSNumber numberWithInteger:collisionBlock]];
        [self setViewKey:@"ateblockvalue" forData:[NSNumber numberWithInteger:collisionValue]];
        [self setViewKey:@"scoreupdated" forData:[NSNumber numberWithBool:YES]];
        
        if(collisionBlock == TYPE_BONUS) {
            
            [self bonusRain];
            
        }
        
        if(collisionBlock != TYPE_BOMB) {
        
            [self bombField];
            
        }
        
    }
    
}

- (void)bombField {
    
    NSInteger chance = arc4random() % 100;
    
    if(chance > (100 - 5)) { //100 - x% chance
    
        NSInteger amount = (arc4random() % 5) + 5; //5 to 10 bombs.
        
        for(int count = 0; count < amount; count++) {
            
            ActionBlock * actionBlock = [[ActionBlock alloc] initActionBlockAsType:TYPE_BOMB atPoint:[self.board randomizePointInsideOfBoard]];
            
            [self.actionBlocks addObject:actionBlock];
            
        }
        
    }
    
}

- (void)setViewKey:(NSString *)key forData:(id)data {
    
    [self.viewData setValue:data forKey:key];
    
}

- (id)getViewKey:(NSString *)key {
    
    id data = [self.viewData objectForKey:key];
    
    if(data) {
        
        [self.viewData setObject:[NSNull null] forKey:key]; //remove data after reading it.
        
    }
    
    return data;
    
}

- (void)bonusRain {
    
    for(int count = 0; count < 15; count++) {
        
        ActionBlock * actionBlock = [[ActionBlock alloc] initActionBlockAsType:TYPE_BONUSRAIN atPoint:[self.board randomizePointInsideOfBoard]];
        
        [self.actionBlocks addObject:actionBlock];
        
    }
    
}

- (void)performDecrementLoopOnActionBlocks {
    
    for(ActionBlock * actionBlock in self.actionBlocks) {
        
        [actionBlock decrementLoopCycle];
        
        if(actionBlock.active && actionBlock.loopCycles == LIFECYCLE_DEAD) {
            
            [self randomizeNewPointForActionBlock:actionBlock];
            
        }
        
    }
    
}

- (void)performActionsOnInactiveActionBlocks {
    
    NSMutableIndexSet * blocksToRemove = [[NSMutableIndexSet alloc] init];
    NSUInteger index = 0;
    
    for(ActionBlock * actionBlock in self.actionBlocks) {
        
        if(!actionBlock.active) {
            
            [blocksToRemove addIndex:index];
            
        } else if(actionBlock.recentlyEaten) {
            
            [self randomizeNewPointForActionBlock:actionBlock];
            [actionBlock randomizeNextActionBlock];
            actionBlock.recentlyEaten = NO;
            
        }
        
        index++;
        
    }
    
    [self.actionBlocks removeObjectsAtIndexes:blocksToRemove];
    
}

- (void)randomizeNewPointForActionBlock:(ActionBlock *)actionBlock {
    
    actionBlock.point = [self.board randomizePointInsideOfBoard];
    
}

- (BOOL)trainInsideBoard:(Train *)train {
    
    return [self.board blockIsInsideBoard:[train headBlock]];
    
}

#pragma getters

- (NSMutableDictionary *)viewData {
    
    if(!_viewData) {
        
        _viewData = [[NSMutableDictionary alloc] init];
        
    }
    
    return _viewData;
    
}

- (NSMutableArray *) actionBlocks {
    
    if(!_actionBlocks) {
        
        _actionBlocks = [[NSMutableArray alloc] init];
        
    }
    
    return _actionBlocks;
    
}

- (NSMutableArray *) trains {
    
    if(!_trains) {
        
        _trains = [[NSMutableArray alloc] init];
        
    }
    
    return _trains;
    
}

@end
