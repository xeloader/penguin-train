//
//  MyScene.h
//  Penguin Train
//

//  Copyright (c) 2014 Victor Ingman. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#import "Game.h"

#define THEME_BLOCK 1
#define THEME_PENGUIN 2

@interface GameRender : SKScene

@property (nonatomic) Game * currentGame;
@property (nonatomic) NSInteger theme;

@end
