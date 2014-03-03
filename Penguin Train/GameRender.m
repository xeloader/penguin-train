//
//  MyScene.m
//  Penguin Train
//
//  Created by Victor Ingman on 2014-02-25.
//  Copyright (c) 2014 Victor Ingman. All rights reserved.
//

#import "GameRender.h"

@interface GameRender() {

    CGSize screenSize;
    
    NSInteger scoreLabelFontSize;
    NSString * fontname;

}

@end

@implementation GameRender

- (id)initWithSize:(CGSize)size { //once
    
    if (self = [super initWithSize:size]) {
        
        scoreLabelFontSize = 12;
        fontname = @"Verdana";
        
        self.backgroundColor = [UIColor blackColor];
        
    }
    
    return self;
    
}

- (void) didMoveToView: (SKView *) view  {
    
    /*VARIABLE SETUP*/
    screenSize = [view frame].size;
    
    /*GAME SETUP*/
    CGSize screenDimension = [Board blockDimensionForDimension:screenSize]; //calculate grid from screen dimension.
    self.currentGame = [[Game alloc] initGameForPlayers:1 onGridDimension:screenDimension]; //initiate the game.
    
    /*GESTURE SETUP*/
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    UISwipeGestureRecognizer *upRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    UISwipeGestureRecognizer *downRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    leftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    upRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    downRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    
    NSArray * gestures = @[rightRecognizer,
                           leftRecognizer,
                           upRecognizer,
                           downRecognizer];
    
    for(UISwipeGestureRecognizer * swipeDirection in gestures) {
        
        [view addGestureRecognizer:swipeDirection];
        
    }
    
}

- (void)update:(CFTimeInterval)currentTime { //always
    
    [self renderTrainBlocks];
    [self renderActionBlocks];
    [self renderScores];
    
}

- (void)renderScores {
    
    SKSpriteNode * scoreNode = (SKSpriteNode *)[self childNodeWithName:@"scorebar"];
    
    if(!scoreNode) {
        
        CGSize scorebarDimension;
        scorebarDimension.width = screenSize.width;
        scorebarDimension.height = screenSize.height - [self.currentGame.board realDimension].height;
        
        scoreNode = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithWhite:0.15 alpha:1] size:scorebarDimension];
        scoreNode.name = @"scorebar";
        scoreNode.anchorPoint = CGPointMake(0, 1);
        scoreNode.position = CGPointMake(0, screenSize.height);
        [self addChild:scoreNode];
        
    }
    
    NSInteger trainCount = [self.currentGame.trains count];
    
    if(trainCount == 1) {
        
        SKLabelNode * highscoreLabel = (SKLabelNode *)[scoreNode childNodeWithName:[NSString stringWithFormat:@"highscore"]];
        
        if(!highscoreLabel) {
            
            CGPoint highscorePosition;
            highscorePosition.x = screenSize.width - BLOCK_SIZE;
            highscorePosition.y = (scoreNode.size.height / 2) * -1; //relative to parent
            
            highscoreLabel = [SKLabelNode node];
            highscoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
            highscoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
            highscoreLabel.fontColor = [UIColor whiteColor];
            highscoreLabel.fontName = fontname;
            highscoreLabel.fontSize = scoreLabelFontSize;
            highscoreLabel.position = highscorePosition;
            highscoreLabel.text = [NSString stringWithFormat:@"Highscore: %ld", (long)[ScoreCounter Highscore]];
            highscoreLabel.name = @"highscore";
            
            [scoreNode addChild:highscoreLabel];
            
        }
        
    }
    
    for(Train * currentTrain in self.currentGame.trains) {
        
        SKLabelNode * scoreLabelNode = (SKLabelNode *)[scoreNode childNodeWithName:[NSString stringWithFormat:@"%lu", (long)currentTrain.identifier]];
        
        if(!scoreLabelNode) {
            
            CGPoint scorePosition;
            scorePosition.x = BLOCK_SIZE + (currentTrain.identifier * (BLOCK_SIZE * 2));
            scorePosition.y = (scoreNode.size.height / 2) * -1; //relative to parent.
            
            scoreLabelNode = [SKLabelNode node];
            scoreLabelNode.position = scorePosition;
            scoreLabelNode.fontColor = currentTrain.colorIdentifier;
            scoreLabelNode.fontSize = scoreLabelFontSize;
            scoreLabelNode.fontName = fontname;
            scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
            scoreLabelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
            scoreLabelNode.text = [NSString stringWithFormat:@"%ld", (long)currentTrain.score.count];
            scoreLabelNode.name = [NSString stringWithFormat:@"%ld", (long)currentTrain.identifier];
            
            [scoreNode addChild:scoreLabelNode];
            
        } else {
            
            scoreLabelNode.text = [NSString stringWithFormat:@"%ld", (long)currentTrain.score.count];
            
        }
        
    }
    
}

- (void) renderTrainBlocks {
    
    NSInteger trainIndex = 0;
    
    for(Train * playerTrain in self.currentGame.trains) {
        
        SKNode * trainNode = [self childNodeWithName:[NSString stringWithFormat:@"train%ld", (long)trainIndex]];
        
        if(!trainNode) {
        
            trainNode = [SKNode node];
            trainNode.name = [NSString stringWithFormat:@"train%ld", (long)trainIndex];
            
            [self addChild:trainNode];
            
        } else {
            
            if(![trainNode hasActions]) {
            
                //run effects?
                
            }
            
        }
        
        NSInteger blockIndex = 0;
        
        for(Block * trainBlock in playerTrain.blocks) {
            
            SKSpriteNode * blockNode = (SKSpriteNode *)[trainNode childNodeWithName:[NSString stringWithFormat:@"%ld", (long)blockIndex]];
            
            if(!blockNode) {
                
                CGSize blockSize = trainBlock.realPixelSize;
                
                blockNode = [SKSpriteNode spriteNodeWithColor:[playerTrain colorIdentifier] size:blockSize];
                blockNode.position = [trainBlock realPixelPoint];
                blockNode.name = [NSString stringWithFormat:@"%ld", (long)blockIndex];
                
                [blockNode runAction:[SKAction scaleTo:1.2 duration:0.2] completion:^{
                    
                    [blockNode runAction:[SKAction scaleTo:1 duration:0.1]];
                    
                }];
            
                [trainNode addChild:blockNode];
                
            } else {
                
                if(![blockNode hasActions]) {
                
                    blockNode.position = [trainBlock realPixelPoint];
                    
                }
                
            }
            
            blockIndex++;
            
        }
        
        NSInteger renderedBlockCount = [trainNode.children count];
        NSInteger blockCount = playerTrain.blockCount;
        
        if(renderedBlockCount > blockCount) {
        
            NSRange blocksToRemove;
            blocksToRemove.location = blockCount;
            blocksToRemove.length = renderedBlockCount - blockCount;
            
            NSArray * dataToRemove = [trainNode children];
            NSArray * renderedBlocksToRemove = [dataToRemove subarrayWithRange:blocksToRemove];
            
            for(SKSpriteNode * renderedBlock in renderedBlocksToRemove) {
                
            }
            
            [trainNode removeChildrenInArray:renderedBlocksToRemove];
            
        }
        
        trainIndex++;
        
    }
    
}

- (void) renderActionBlocks {

    SKNode * actionBlocksNode = [self childNodeWithName:@"actionblocks"];
    SKNode * emittersNode = [self childNodeWithName:@"emitterblocks"];
    
    if(!emittersNode) {
        
        emittersNode = [SKNode node];
        emittersNode.name = @"emitterblocks";
        [self addChild:emittersNode];
        
    }
    
    if(!actionBlocksNode) {
        
        actionBlocksNode = [SKNode node];
        actionBlocksNode.name = @"actionblocks";
        [self addChild:actionBlocksNode];
        
    }
    
    if(emittersNode && actionBlocksNode) {
        
        NSInteger actionBlockIndex = 0;
        
        for(ActionBlock * actionBlock in self.currentGame.actionBlocks) {
        
            SKSpriteNode * blockNode = (SKSpriteNode *)[actionBlocksNode childNodeWithName:[NSString stringWithFormat:@"%ld", (long)actionBlockIndex]];
            SKEmitterNode * emitterNode = (SKEmitterNode *)[emittersNode childNodeWithName:[NSString stringWithFormat:@"%ld", (long)actionBlockIndex]];
            
            NSString * spriteImageName = [self.class spriteForType:actionBlock.type];
            UIColor * blockColor = actionBlock.colorIdentifier;
            CGPoint blockPoint = [actionBlock realPixelPoint];
            long actionBlockType = actionBlock.type;
            
            NSString * particleName = [self.class particleNameForType:actionBlock.type];
            
            if(!emitterNode) {
                
                if(particleName) {
                    
                    emitterNode = [self.class extractedParticleForType:actionBlockType];
                    emitterNode.position = blockPoint;
                    
                } else {
                    
                    emitterNode = [SKEmitterNode node];
                    emitterNode.hidden = YES;
                    
                }
                
                emitterNode.name = [NSString stringWithFormat:@"%ld", (long)actionBlockIndex];
                [emittersNode addChild:emitterNode];
                
            } else {
                
                if(!particleName) {
                    
                    emitterNode.hidden = YES;
                    
                } else {

                    emitterNode.hidden = NO;
                    
                }
                
                emitterNode.position = blockPoint;
                
            }
            
            if(!blockNode) {
                
                if(spriteImageName) {
                    
                    blockNode = [SKSpriteNode spriteNodeWithImageNamed:spriteImageName];
                    blockNode.size = [actionBlock realPixelSize];
                    
                } else {
                
                    blockNode = [SKSpriteNode spriteNodeWithColor:blockColor size:[actionBlock realPixelSize]];
                    
                }
                
                blockNode.position = blockPoint;
                blockNode.name = [NSString stringWithFormat:@"%ld", (long)actionBlockIndex];
                
                [actionBlocksNode addChild:blockNode];
                
            } else {
            
                blockNode.position = blockPoint;
                
                if(!spriteImageName) {
                
                    blockNode.color = blockColor;
                    
                } else {
                    
                    blockNode.texture = [SKTexture textureWithImageNamed:spriteImageName];
                    
                }
                
                if(![blockNode hasActions]) {
                    
                    SKAction * engorge = [SKAction scaleTo:1.2 duration:0.2];
                    SKAction * normal = [SKAction scaleTo:1 duration:0.2];
                    
                    [blockNode runAction:engorge completion:^{
                        
                        [blockNode runAction:normal];
                        
                    }];
                    
                }
                
            }
            
            actionBlockIndex++;
            
        }
        
    }
    
    [self removeInactiveActionBlocks];
    
    //end
    
}

- (void)removeInactiveActionBlocks {
    
    SKNode * actionBlocksNode = [self childNodeWithName:@"actionblocks"];
    //SKNode * emitterBlocksNode = [self childNodeWithName:@"emitterblocks"];
    
    if(actionBlocksNode) {
        
        NSInteger renderedBlockCount = [actionBlocksNode.children count];
        NSInteger blockCount = [self.currentGame.actionBlocks count];
        
        if(renderedBlockCount > blockCount) {
            
            NSRange blocksToRemove;
            blocksToRemove.location = blockCount;
            blocksToRemove.length = renderedBlockCount - blockCount;
            
            //NSArray * emittersToRemove = [emitterBlocksNode children];
            NSArray * dataToRemove = [actionBlocksNode children];
            
            //NSArray * renderedEmittersToRemove = [emittersToRemove subarrayWithRange:blocksToRemove];
            //[emitterBlocksNode removeChildrenInArray:renderedEmittersToRemove];
            
            NSArray * renderedBlocksToRemove = [dataToRemove subarrayWithRange:blocksToRemove];
            
            [renderedBlocksToRemove enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL * stop) {
                
                [object runAction:[SKAction rotateByAngle:M_PI duration:self.currentGame.gameSpeedInSeconds]];
                [object runAction:[SKAction scaleTo:0 duration:self.currentGame.gameSpeedInSeconds] completion:^{
                    
                    [actionBlocksNode removeChildrenInArray:@[object]];
                    
                }];
                
            }];
            
        }
        
    }
    
}

- (void) swipeHandler:(UISwipeGestureRecognizer *)gestureRecognizer {
    
    CGVector directionRequested;
    directionRequested.dx = DIRECTION_UNDEFINED;
    directionRequested.dy = DIRECTION_UNDEFINED;
    
    if(gestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        
        directionRequested.dx = DIRECTION_LEFT;
        
    } else if(gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        
        directionRequested.dx = DIRECTION_RIGHT;
        
    } else if(gestureRecognizer.direction == UISwipeGestureRecognizerDirectionUp) {
        
        directionRequested.dy = DIRECTION_UP;
        
    } else if(gestureRecognizer.direction == UISwipeGestureRecognizerDirectionDown) {
        
        directionRequested.dy = DIRECTION_DOWN;
        
    }
    
    NSInteger playerTrainChanged = 0;
    
    if([self.currentGame.trains count] > 1) {
        
        CGPoint location = [gestureRecognizer locationInView:self.view];
        playerTrainChanged = [self playerScreenTouched:location];
        
    }
    
    Train * trainAffected = self.currentGame.trains[playerTrainChanged];
    [trainAffected setDirection:directionRequested];
    
}

- (NSInteger)playerScreenTouched:(CGPoint)swipeStartLocation {
    
    CGSize boardDimension = [self.currentGame.board realDimension];
    NSInteger screenHeightInHalf = (NSInteger)((boardDimension.height / 2) + 0.5); //round up.
    
    if(swipeStartLocation.y > screenHeightInHalf) {
        
        return 0;
        
    } else {
        
        return 1;
        
    }
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        
        /*CGPoint location = [touch locationInNode:self];
        
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        [sprite setScale:0.1];
        
        sprite.position = location;
        
        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
        
        [sprite runAction:[SKAction repeatActionForever:action]];
        
        [self addChild:sprite];*/
        
    }
}

+ (id)extractedParticleForType:(NSInteger)requestedType {
    
    NSString * path = [[NSBundle mainBundle] pathForResource:[self.class particleNameForType:requestedType] ofType:@"sks"];
    
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
}

+ (NSString *)particleNameForType:(NSInteger)requestedType {
    
    switch(requestedType) {
            
        case TYPE_BONUS:
            
            return @"BonusAura";
            
            break;
            
        case TYPE_BONUSRAIN:
            
            return @"WaterDrops";
            
            break;
            
        default:
            
            return nil;
            
            break;
            
    }
    
}

+ (NSString *)spriteForType:(NSInteger)requestedType {
    
    switch(requestedType) {
            
        case TYPE_BONUS:
            
            return @"egg_golden@2x";
            
            break;
            
        case TYPE_FOOD:
            
            return @"egg@2x";
            
            break;
            
        case TYPE_BONUSRAIN:
            
            return @"egg_ice@2x";
            
            break;
            
        default:
            
            return nil;
            
            break;
            
    }
    
}

@end
