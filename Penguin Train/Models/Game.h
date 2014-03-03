//
//  Game.h
//  Penguin Train
//
//  Created by Victor Ingman on 2014-02-25.
//  Copyright (c) 2014 Victor Ingman. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Train.h"
#import "ActionBlock.h"
#import "Board.h"

@interface Game : NSObject

@property (nonatomic) NSTimer * gameTimer;

@property (nonatomic) Board * board;
@property (nonatomic) NSMutableArray * trains;
@property (nonatomic) NSMutableArray * actionBlocks;
@property (nonatomic) NSNumber * gameSpeed;

- (void) loop;
- (Game *) initGameForPlayers:(NSInteger)playerCount onGridDimension:(CGSize)gridDimension;
- (float)gameSpeedInSeconds;

@end
