//
//  ViewController.m
//  Penguin Train
//
//  Created by Victor Ingman on 2014-02-25.
//  Copyright (c) 2014 Victor Ingman. All rights reserved.
//
#import "iAd/iAd.h"

#import "ViewController.h"
#import "GameRender.h"

@interface ViewController() { }

@property (nonatomic) SKView * gameView;
@property (nonatomic) SKScene * gameScene;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*VIEW SETUP*/
    self.gameView = (SKView *) self.view;
    
    self.gameView.showsFPS = YES;
    self.gameView.showsNodeCount = YES;
    
    self.gameScene = [GameRender sceneWithSize:self.gameView.bounds.size];
    self.gameScene.scaleMode = SKSceneScaleModeAspectFill;
    
    /*PRESENT*/
    [self.gameView presentScene:self.gameScene];
    
}


- (BOOL)shouldAutorotate {
    
    return NO;
    
}

- (NSUInteger)supportedInterfaceOrientations {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        return UIInterfaceOrientationMaskAllButUpsideDown;
        
    } else {
        
        return UIInterfaceOrientationMaskAll;
        
    }
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

@end
