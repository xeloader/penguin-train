//
//  MyScene.m
//  Penguin Train
//
//  Created by Victor Ingman on 2014-02-25.
//  Copyright (c) 2014 Victor Ingman. All rights reserved.
//

#import "iAd/iAd.h"

#import "GameRender.h"

#define AD_TIME 3000

@interface GameRender() {
    
    NSInteger players;

    CGSize screenSize;
    
    NSInteger scoreLabelFontSize;
    NSString * fontname;
    
    NSTimer * timer;
    BOOL timerStarted;
    
    NSInteger adCountdown;

}

@end

@implementation GameRender

- (id)initWithSize:(CGSize)size { //once
    
    if (self = [super initWithSize:size]) {
        
        adCountdown = AD_TIME;
        timerStarted = NO;
        
        players = 1;
        
        scoreLabelFontSize = 12;
        fontname = @"Verdana";
        
        self.theme = THEME_PENGUIN;
        self.backgroundColor = [self.class backgroundForTheme:self.theme];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                         target:self
                                       selector:@selector(timerLoop)
                                       userInfo:nil
                                        repeats:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReciever:) name:@"render" object:nil];
        
        [self performSelectorOnMainThread:@selector(timerLoop) withObject:nil waitUntilDone:YES];
        
    }
    
    return self;
    
}

- (void)messageReciever:(NSNotification *)notification {
    
    if([notification.object isKindOfClass:[NSString class]]) {
        
        NSString * message = (NSString *) notification.object;
        
        if([message isEqualToString:@"pausegame"]) {
            
            [self pauseGame];
            
        }
        
        if([message isEqualToString:@"forcestartgame"]) {
            
            //[self stopCountdown];
            [self unpauseGame];
            
        }
        
        if([message isEqualToString:@"toggleplayers"]) {
            
            if(players == 1) {
                
                players = 2;
                
            } else {
                
                players = 1;
                
            }
            
        }
        
        if([message isEqualToString:@"startgame"]) {
            
            [self countdownAndStartgame];
            //[self unpauseGame];
            
        }
        
    }
    
}

- (void)timerLoop {
    
    if(timerStarted == YES) {
        
        if(adCountdown > 0) {
        
            adCountdown -= 100;
            
        } else {
            
            [self hideAd];
            
        }
        
    }
    
}

- (void)stopCountdown {
    
    SKLabelNode * countdown = (SKLabelNode *)[self childNodeWithName:@"countdown"];
    
    if(countdown) {
        
        [countdown removeAllActions];
        [countdown removeFromParent];
        
    }
    
}

- (void)countdownAndStartgame {
    
    self.paused = NO;
    
    SKLabelNode * countdown = (SKLabelNode *)[self childNodeWithName:@"countdown"];
    
    if(!countdown) {
    
        countdown = [SKLabelNode node];
        countdown.name = @"countdown";
        countdown.text = [NSString stringWithFormat:@"%ld", (long)3];
        countdown.fontSize = 24;
        countdown.fontName = [NSString stringWithFormat:@"%@-bold", fontname];
        countdown.fontColor = [UIColor blackColor];
        countdown.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
        
        [self addChild:countdown];
        
    }
    
    countdown.alpha = 1;
    countdown.text = [NSString stringWithFormat:@"%ld", (long)3];
    
    [countdown runAction:[SKAction fadeOutWithDuration:1] completion:^{
        
        countdown.text = [NSString stringWithFormat:@"%ld", (long)2];
        [countdown runAction:[SKAction fadeInWithDuration:0.01] completion:^{
            
            [countdown runAction:[SKAction fadeOutWithDuration:1] completion:^{
                
                countdown.text = [NSString stringWithFormat:@"%ld", (long)1];
                [countdown runAction:[SKAction fadeInWithDuration:0.01] completion:^{
                    
                    [countdown runAction:[SKAction fadeOutWithDuration:1] completion:^{
                        
                        [countdown removeFromParent];
                        [self unpauseGame];
                        
                    }];
                    
                }];
                
            }];
            
        }];
        
        
    }];
    
}

- (void) didMoveToView:(SKView *) view  {
    
    /*VARIABLE SETUP*/
    screenSize = [view frame].size;
    
    /*GAME SETUP*/
    CGSize screenDimension = [Board blockDimensionForDimension:screenSize]; //calculate grid from screen dimension.
    self.currentGame = [[Game alloc] initGameForPlayers:players onGridDimension:screenDimension]; //initiate the game.
    
    /*GESTURE SETUP*/
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    UISwipeGestureRecognizer *upRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    UISwipeGestureRecognizer *downRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    
    UITapGestureRecognizer *touchRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    
    touchRecognizer.cancelsTouchesInView = YES;
    touchRecognizer.numberOfTapsRequired = 1;
    touchRecognizer.numberOfTouchesRequired = 1;
    
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    leftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    upRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    downRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    
    NSArray * gestures = @[rightRecognizer,
                           leftRecognizer,
                           upRecognizer,
                           downRecognizer];
    
    /*ADD RECOGNIZERS TO VIEW*/
    
    [view addGestureRecognizer:touchRecognizer];
    
    for(UISwipeGestureRecognizer * swipeDirection in gestures) {
        
        [view addGestureRecognizer:swipeDirection];
        
    }
    
}

- (void)tapHandler:(UITapGestureRecognizer *)tapRecognizer {
 
    CGPoint tapPosition = [tapRecognizer locationInView:self.view];
    
    Train * firstTrain = self.currentGame.trains[0];
    CGVector lastDirections = [firstTrain lastDirections];
    CGVector newDirections = lastDirections;
    
    //NSLog(@"%f : %f", lastDirections.dx, lastDirections.dy);
    
    if(tapPosition.x > (screenSize.width / 2)) {
        
        //NSLog(@"left");
        newDirections.dy = newDirections.dx  * -1;
        newDirections.dx = lastDirections.dy;
        
    } else {
        
        /*WORKS*/
        newDirections.dy = newDirections.dx;
        newDirections.dx = lastDirections.dy * -1;
        
    }
    
    [firstTrain setDirection:newDirections];
    
}

- (void)update:(CFTimeInterval)currentTime { //always
    
    [self renderBackgroundActions];
    
    [self renderScorePopups];
    [self renderEarthquakeIfDead];
    
    [self renderActionblocksWithEmitters];
    
    [self renderActionEffects];
    
    [self renderTrainBlocks];
    [self renderScores];
    
}

- (void)renderBackgroundActions {
    
    SKEmitterNode * snow = (SKEmitterNode *)[self childNodeWithName:@"snow"];
    
    if(!snow) {
        
        snow = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Snow" ofType:@"sks"]];
        snow.position = CGPointMake(screenSize.width / 2, screenSize.height);
        snow.name = @"snow";
        
        [self addChild:snow];
        
    }
    
}

- (void)renderEarthquakeIfDead {
    
    id data = [self.currentGame getViewKey:@"died"];
    
    if(data != nil && data != [NSNull null]) {

        data = (NSNumber *)data;
        
        [self showAd];
        //[self pauseGame]; //stops countdown.
        //[self countdownAndStartgame];
        
        [self runAction:[SKAction moveByX:4.0 y:0 duration:0.05] completion:^{
            
            [self runAction:[SKAction moveByX:-8.0 y:0 duration:0.05] completion:^{
               
                [self runAction:[SKAction moveByX:4.0 y:0 duration:0.05] completion:^{
                    
                }];
                
            }];
            
        }];
        
    }
    
}

- (void)showAd {
    
    timerStarted = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"viewcontroller" object:@"showad"];
    
}

- (void)hideAd {
    
    timerStarted = NO;
    adCountdown = AD_TIME;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"viewcontroller" object:@"hidead"];
    
}

- (void)pauseGame {
    
    [self setPaused:YES];
    self.currentGame.paused = YES;
    //[self stopCountdown];
    
}

- (void)unpauseGame {
    
    [self setPaused:NO];
    self.currentGame.paused = NO;
    
}

- (void)renderScorePopups {
    
    id data = [self.currentGame getViewKey:@"ateblockvalue"];
    
    if(data != nil && data != [NSNull null]) {
        
        data = (NSNumber *)data;
        NSInteger scoreAchieved = [data integerValue];
        
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
    
        scorePopup.text = [NSString stringWithFormat:@"%ld", (long)scoreAchieved];
        
        CGPoint blockPoint = [[self.currentGame.trains[0] headBlock] realPixelPoint];
        
        scorePopup.position = blockPoint;
        
        [popupParent addChild:scorePopup];
        
        [scorePopup runAction:[SKAction moveByX:0 y:BLOCK_SIZE duration:1.5]];
        [scorePopup runAction:[SKAction fadeOutWithDuration:1.5] completion:^{
            
            [scorePopup removeFromParent];
            
        }];
        
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

- (void)renderTrainBlocks {
    
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
                blockNode = [SKSpriteNode spriteNodeWithImageNamed:@"penguin-shadow@2x"];
                
                CGSize penguinSize = CGSizeMake(blockSize.width, blockSize.height + (BLOCK_SIZE / 16));
                
                blockNode.size = penguinSize;
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
            
            SKAction * dropDead = [SKAction sequence:@[
                                                       [SKAction rotateToAngle:M_PI_2 duration:0.2],
                                                       [SKAction waitForDuration:0.1],
                                                       [SKAction fadeOutWithDuration:0.2]
                                                       ]];
            
            for(SKSpriteNode * renderedBlock in renderedBlocksToRemove) {
                
                [dropDead setTimingMode:SKActionTimingEaseIn];
                
                [renderedBlock runAction:dropDead completion:^{
                    
                    [renderedBlock removeFromParent];
                    
                }];
                
            }
            
        }
        
        trainIndex++;
        
    }
    
}

- (void)renderActionEffects {
    
    /*ATE BLOCK*/
    id data = [self.currentGame getViewKey:@"blocktype"];
    
    if(data && data != [NSNull null]) {
        
        data = (NSNumber *)data;
        
        if([data integerValue] == TYPE_BOMB) {
            
            SKNode * train = [self childNodeWithName:@"train0"];
            
            if(train) {
                
                SKAction * colorRed = [SKAction sequence:@[
                                                           [SKAction colorizeWithColor:[UIColor redColor] colorBlendFactor:1 duration:0.2],
                                                           [SKAction colorizeWithColor:[UIColor redColor] colorBlendFactor:0 duration:0.2]
                                                           ]];
                
                [[train children] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    
                    [obj runAction:colorRed];
                    
                }];
                
                [self runAction:[SKAction moveByX:2 y:0 duration:0.05] completion:^{
                    
                    [self runAction:[SKAction moveByX:-2 y:0 duration:0.05]];
                    
                }];
                
            }
            
        }
        
    }
    
    
}

- (void)renderActionblocksWithEmitters {
    
    NSInteger index = 0; //will change in the loop later on.
    
    SKNode * actionblocksContainer = [self childNodeWithName:@"actionblocks"];
    
    if(!actionblocksContainer) {
        
        actionblocksContainer = [SKNode node];
        actionblocksContainer.name = @"actionblocks";
        
        [self addChild:actionblocksContainer];
        
    }
    
    for(ActionBlock * actionblock in self.currentGame.actionBlocks) {
        
        NSString * identifier = [NSString stringWithFormat:@"%ld", (long)index];
        NSString * imageIdentifier = [self.class spriteForType:actionblock.type];
        
        SKSpriteNode * renderedActionblock = (SKSpriteNode *)[actionblocksContainer childNodeWithName:identifier];
        
        if(!renderedActionblock) {
            
            renderedActionblock = [SKSpriteNode node];
            renderedActionblock.name = identifier;
            
            CGSize eggSize = CGSizeMake([actionblock realPixelSize].width, [actionblock realPixelSize].height + (BLOCK_SIZE / 16));
            
            renderedActionblock.size = eggSize;
            
            [actionblocksContainer addChild:renderedActionblock];
            
        }
        
        renderedActionblock.position = [actionblock realPixelPoint];
        renderedActionblock.texture = [SKTexture textureWithImageNamed:imageIdentifier];
        
        if(![renderedActionblock hasActions] && actionblock.type != TYPE_BOMB) {
            
            SKAction * sizeWobble = [SKAction sequence:@[
                                                         [SKAction scaleTo:1.2 duration:0.2],
                                                         [SKAction scaleTo:1.0 duration:0.2]
                                                         ]];
            
            [renderedActionblock runAction:sizeWobble];
            
        }
        
        /*EMITTER*/
        
        NSString * emitterIdentifier = [self.class particleNameForType:actionblock.type andTheme:self.theme];
        NSString * emitterPath = [[NSBundle mainBundle] pathForResource:emitterIdentifier ofType:@"sks"];
        
        SKEmitterNode * renderedEmitter = (SKEmitterNode *)[renderedActionblock childNodeWithName:emitterIdentifier];
        
        if(!renderedEmitter) {
            
            renderedEmitter = (emitterPath) ? [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath] : [SKEmitterNode node];
            renderedEmitter.name = emitterIdentifier;
            
            
            [renderedActionblock removeAllChildren]; //remove old emitters.
            [renderedActionblock addChild:renderedEmitter];
            
        }
        
        renderedEmitter.zPosition = (actionblock.type == TYPE_BOMB) ? 1 : -1; //bombs burn in front of egg
        renderedEmitter.position = (actionblock.type == TYPE_BOMB) ? CGPointMake(renderedEmitter.position.x, -(BLOCK_SIZE / 2)) : renderedEmitter.position;
        renderedEmitter.hidden = (actionblock.type == TYPE_FOOD); //if food, hidden.
        
        index++;
        
    }
    
    [self removeInactiveActionBlocks];
    
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

- (void)swipeHandler:(UISwipeGestureRecognizer *)gestureRecognizer {
    
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
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
            
        case TYPE_BONUS:
            
                return @"BonusAura";
            
            break;
            
        case TYPE_MOTHER:
            
            return @"MotherAura";
            
            break;
            
        case TYPE_BONUSRAIN:
            
            return @"WaterDrops";
            
            break;
            
        case TYPE_BOMB:
            
            return @"Fire";
            
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
            
            return @"egg_golden-shadow@2x";
            
            break;
            
        case TYPE_FOOD:
            
            return @"egg-shadow@2x";
            
            break;
            
        case TYPE_BONUSRAIN:
            
            return @"egg_icey-shadow@2x";
            
            break;
            
        case TYPE_MOTHER:
            
            return @"egg_mother-shadow@2x";
            
            break;
            
        case TYPE_BOMB:
            
            return @"egg_dark-shadow@2x";
            
            break;
            
        default:
            
            return nil;
            
            break;
            
    }
    
}

@end
