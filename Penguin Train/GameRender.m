//
//  MyScene.m
//  Penguin Train
//
//  Created by Victor Ingman on 2014-02-25.
//  Copyright (c) 2014 Victor Ingman. All rights reserved.
//

#import "iAd/iAd.h"

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
        
        self.theme = THEME_PENGUIN;
        
        self.backgroundColor = [self.class backgroundForTheme:self.theme];
        
    }
    
    return self;
    
}

- (void) didMoveToView:(SKView *) view  {
    
    ADBannerView * ad = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    ad.frame = CGRectMake(ad.frame.origin.x, screenSize.height, ad.frame.size.width, ad.frame.size.height);
    [self.view addSubview:ad];
    /*to be continued, can't add delegate in skscene...*/
    
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
    
    [self renderScorePopups];
    [self renderEarthquakeIfDead];
    
    [self renderEmitters];
    [self renderActionBlocks];
    
    [self renderTrainBlocks];
    [self renderScores];
    
}

- (void)renderEarthquakeIfDead {
    
    id data = [self.currentGame getViewKey:@"died"];
    
    if(data != nil && data != [NSNull null]) {
        
        data = (NSNumber *)data;
        
        [self runAction:[SKAction moveByX:4.0 y:0 duration:0.05] completion:^{
            
            [self runAction:[SKAction moveByX:-8.0 y:0 duration:0.05] completion:^{
               
                [self runAction:[SKAction moveByX:4.0 y:0 duration:0.05] completion:^{
                    
                }];
                
            }];
            
        }];
        
    }
    
}

- (void)pauseGame {
    
    [self setPaused:YES];
    self.currentGame.paused = YES;
    
}

- (void)unpauseGame {
    
    [self setPaused:NO];
    self.currentGame.paused = NO;
    
}

- (void)renderScorePopups {
    
    id data = [self.currentGame getViewKey:@"ateblock"];
    
    if(data != nil && data != [NSNull null]) {
        
        ActionBlock * block = data;
        
        NSInteger scoreAchieved = block.value;
        
        SKNode * popupParent = [self childNodeWithName:@"scorePopups"];
        
        if(!popupParent) {
            
            popupParent = [SKNode node];
            popupParent.name = @"scorePopups";
            
            [self addChild:popupParent];
            
        }
        
        SKLabelNode * scorePopup = [[SKLabelNode alloc] initWithFontNamed:fontname];
        scorePopup.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        scorePopup.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        scorePopup.fontSize = 18;
        scorePopup.fontName = [NSString stringWithFormat:@"%@-bold", fontname];
        
        if(scoreAchieved > 0) {
            
            scorePopup.fontColor = [UIColor orangeColor];
            
        } else {
            
            scorePopup.fontColor = [UIColor redColor];
            
        }
        
        /*[self runAction:[SKAction moveByX:BLOCK_SIZE y:0 duration:0.2] completion:^{
            
            [self runAction:[SKAction moveByX:-BLOCK_SIZE y:0 duration:0.2]];
            
        }];*/ //shake
    
        scorePopup.text = [NSString stringWithFormat:@"%d", [[self.currentGame getViewKey:@"ateblockvalue"] integerValue]];
        
        CGPoint blockPoint = [[self.currentGame.trains[0] headBlock] realPixelPoint];
        
        scorePopup.position = blockPoint;
        
        [popupParent addChild:scorePopup];
        
        [scorePopup runAction:[SKAction moveByX:0 y:BLOCK_SIZE duration:1.5]];
        [scorePopup runAction:[SKAction fadeOutWithDuration:1.5] completion:^{
            
            [scorePopup removeFromParent];
            
        }];
        
    }
    
}

- (void)renderEmitters {
    
    SKNode * emitterParentNode = [self childNodeWithName:@"emitterblocks"];
    
    if(!emitterParentNode) {
        
        emitterParentNode = [SKNode node];
        emitterParentNode.name = @"emitterblocks";
        
        [self addChild:emitterParentNode];
        
    }
        
    NSInteger actionBlockCount = 0;
    
    for(ActionBlock * actionBlock in self.currentGame.actionBlocks) {
        
        SKEmitterNode * emitterBlock = (SKEmitterNode *)[emitterParentNode childNodeWithName:[NSString stringWithFormat:@"%ld", (long)actionBlockCount]];
        
        NSInteger blockType = actionBlock.type;
        CGPoint blockPoint = [actionBlock realPixelPoint];
        
        if(!emitterBlock) {
            
            NSString * particlePath = [[NSBundle mainBundle] pathForResource:[self.class particleNameForType:blockType andTheme:self.theme] ofType:@"sks"];
            
            emitterBlock = [NSKeyedUnarchiver unarchiveObjectWithFile:particlePath];
            emitterBlock.particleScale = emitterBlock.particleScale * ((float)BLOCK_SIZE / 16.0);
            emitterBlock.name = [NSString stringWithFormat:@"%ld", (long)actionBlockCount];
            //emitterBlock.targetNode = [[self childNodeWithName:@"actionblocks"] childNodeWithName:[NSString stringWithFormat:@"%d", actionBlockCount]];
            
            [emitterParentNode addChild:emitterBlock];
            
        }
        
        if(blockType == TYPE_FOOD) {
            
            emitterBlock.hidden = YES;
            
        } else {
            
            emitterBlock.hidden = NO;
            
        }
        
        emitterBlock.position = blockPoint;
        
        actionBlockCount++;
        
    }
    
    [self removeInactiveEmitters];
    
}

- (void)removeInactiveEmitters {
    
    SKNode * actionBlocksNode = [self childNodeWithName:@"emitterblocks"];
    
    if(actionBlocksNode) {
        
        NSInteger renderedBlockCount = [actionBlocksNode.children count];
        NSInteger blockCount = [self.currentGame.actionBlocks count];
        
        if(renderedBlockCount > blockCount) {
            
            NSRange blocksToRemove;
            blocksToRemove.location = blockCount;
            blocksToRemove.length = renderedBlockCount - blockCount;
            
            NSArray * dataToRemove = [actionBlocksNode children];
            NSArray * renderedBlocksToRemove = [dataToRemove subarrayWithRange:blocksToRemove];
            
            [actionBlocksNode removeChildrenInArray:renderedBlocksToRemove];
            
        }
        
    }
    
}

- (void)renderScores {
    
    SKSpriteNode * scoreNode = (SKSpriteNode *)[self childNodeWithName:@"scorebar"];
    
    if(!scoreNode) {
        
        CGSize scorebarDimension;
        scorebarDimension.width = screenSize.width;
        scorebarDimension.height = screenSize.height - [self.currentGame.board realDimension].height;
        
        UIColor * barColor = [UIColor colorWithHue:(200.0/360.0) saturation:(5.0/100.0) brightness:(79.0/100.0) alpha:1];
        scoreNode = [SKSpriteNode spriteNodeWithColor:barColor size:scorebarDimension];
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
            highscoreLabel.fontColor = [UIColor blackColor];
            highscoreLabel.fontName = [NSString stringWithFormat:@"%@-bold", fontname];
            highscoreLabel.fontSize = scoreLabelFontSize;
            highscoreLabel.position = highscorePosition;
            highscoreLabel.text = [NSString stringWithFormat:@"Highscore: %ld", (long)[ScoreCounter Highscore]];
            highscoreLabel.name = @"highscore";
            
            [scoreNode addChild:highscoreLabel];
            
        } else {
            
            highscoreLabel.text = [NSString stringWithFormat:@"Highscore: %ld", (long)[ScoreCounter Highscore]];
            
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
            
            if(trainCount == 1) {
                
                scoreLabelNode.fontColor = [UIColor blackColor];
                
            } else {
                
                scoreLabelNode.fontColor = currentTrain.colorIdentifier;
                
            }
            
            scoreLabelNode.fontSize = scoreLabelFontSize;
            scoreLabelNode.fontName = fontname;
            scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
            scoreLabelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
            scoreLabelNode.text = [NSString stringWithFormat:@"%ld", (long)currentTrain.score.count];
            scoreLabelNode.name = [NSString stringWithFormat:@"%ld", (long)currentTrain.identifier];
            
            [scoreNode addChild:scoreLabelNode];
            
        } else {
            
            id data = [self.currentGame getViewKey:@"scoreupdated"];
            
            if(data != nil && data != [NSNull null]) {
                
                data = (NSNumber *)data;
                
                if([data boolValue] == YES) {
                    
                    [scoreLabelNode runAction:[SKAction scaleTo:1.1 duration:[self.currentGame gameSpeedInSeconds]] completion:^{
                        
                        [scoreLabelNode runAction:[SKAction scaleTo:1.0 duration:([self.currentGame gameSpeedInSeconds] / 2.0)]];
                        
                    }];
                }
                
            }
            
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

                
            }
            
        }
        
        NSInteger blockIndex = 0;
        
        for(Block * trainBlock in playerTrain.blocks) {
            
            SKSpriteNode * blockNode = (SKSpriteNode *)[trainNode childNodeWithName:[NSString stringWithFormat:@"%ld", (long)blockIndex]];
            
            if(!blockNode) {
                
                CGSize blockSize = trainBlock.realPixelSize;
                
                //blockNode = [SKSpriteNode spriteNodeWithColor:[playerTrain colorIdentifier] size:blockSize];
                blockNode = [SKSpriteNode spriteNodeWithImageNamed:@"penguin@2x"];
                blockNode.size = blockSize;
                blockNode.position = [trainBlock realPixelPoint];
                blockNode.name = [NSString stringWithFormat:@"%ld", (long)blockIndex];
                
                [blockNode runAction:[SKAction scaleTo:1.2 duration:0.2] completion:^{
                    
                    [blockNode runAction:[SKAction scaleTo:1 duration:0.1]];
                    
                }];
            
                [trainNode addChild:blockNode];
                
            } else {
                
                blockNode.position = [trainBlock realPixelPoint];
                
                if(![blockNode hasActions]) {
                    
                    float halfGameSpeed = ([self.currentGame gameSpeedInSeconds]);
                    float angle = (45.0/360.0);
                    
                    [blockNode runAction:[SKAction rotateToAngle:-angle duration:halfGameSpeed] completion:^{
                        
                        [blockNode runAction:[SKAction rotateToAngle:(angle) duration:halfGameSpeed]];
                        
                    }];
                    
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
    
    if(!actionBlocksNode) {
        
        actionBlocksNode = [SKNode node];
        actionBlocksNode.name = @"actionblocks";
        [self addChild:actionBlocksNode];
        
    }
    
    if(actionBlocksNode) {
        
        NSInteger actionBlockIndex = 0;
        
        for(ActionBlock * actionBlock in self.currentGame.actionBlocks) {
        
            SKSpriteNode * blockNode = (SKSpriteNode *)[actionBlocksNode childNodeWithName:[NSString stringWithFormat:@"%ld", (long)actionBlockIndex]];
            
            NSString * spriteImageName = [self.class spriteForType:actionBlock.type];
            UIColor * blockColor = actionBlock.colorIdentifier;
            CGPoint blockPoint = [actionBlock realPixelPoint];
            
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
    
    if(actionBlocksNode) {
        
        NSInteger renderedBlockCount = [actionBlocksNode.children count];
        NSInteger blockCount = [self.currentGame.actionBlocks count];
        
        if(renderedBlockCount > blockCount) {
            
            NSRange blocksToRemove;
            blocksToRemove.location = blockCount;
            blocksToRemove.length = renderedBlockCount - blockCount;

            NSArray * dataToRemove = [actionBlocksNode children];
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

+ (id)extractedParticleForType:(NSInteger)requestedType andTheme:(NSInteger)theme {
    
    NSString * path = [[NSBundle mainBundle] pathForResource:[self.class particleNameForType:requestedType andTheme:theme] ofType:@"sks"];
    
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
}

+ (UIColor *)backgroundForTheme:(NSInteger)theme {
    
    CGFloat hue, brightness, saturation;
    
    switch(theme) {
            
        case THEME_PENGUIN:
            
            hue = 202.0;
            saturation = 5.0;
            brightness = 88.0;
            
            break;
            
        case THEME_BLOCK:
            
            hue = 0;
            saturation = 0;
            brightness = 0;
            
            break;
            
    }
    
    return [UIColor colorWithHue:(hue / 360.0) saturation:(saturation / 100.0) brightness:(brightness / 100.0) alpha:1];
    
}

+ (NSString *)particleNameForType:(NSInteger)requestedType andTheme:(NSInteger)theme {
    
    if(theme == THEME_PENGUIN) {
    
    switch(requestedType) {
            
        case TYPE_FOOD:
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
        
    } else {
        
        switch(requestedType) {
                
            default:
                
                return nil;
                
                break;
                
        }
        
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
