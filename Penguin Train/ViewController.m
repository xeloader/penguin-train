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

@interface ViewController() {

    ADBannerView * ad;

}

@property (nonatomic) SKView * gameView;
@property (nonatomic) SKScene * gameScene;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(communication:) name:@"MyFunkyViewSwitcherooNotification" object:nil];
    
    ad = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    ad.frame = CGRectMake(ad.frame.origin.x, self.view.frame.size.height - ad.frame.size.height, ad.frame.size.width, ad.frame.size.height);
    [self.view addSubview:ad];
    
    /*VIEW SETUP*/
    self.gameView = (SKView *) self.view;
    
    self.gameView.showsFPS = YES;
    self.gameView.showsNodeCount = YES;
    
    self.gameScene = [GameRender sceneWithSize:self.gameView.bounds.size];
    self.gameScene.scaleMode = SKSceneScaleModeAspectFill;
    
    /*PRESENT*/
    [self.gameView presentScene:self.gameScene];
    
}

- (void)communication:(NSString *)notification {
    
    //to be continued
    NSLog(@"%@", notification);
    
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
