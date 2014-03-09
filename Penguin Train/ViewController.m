//
//  ViewController.m
//  Penguin Train
//
//  Created by Victor Ingman on 2014-02-25.
//  Copyright (c) 2014 Victor Ingman. All rights reserved.
//
#import "iAd/iAd.h"

#import "ViewController.h"
#import "IntroductionViewController.h"
#import "GameRender.h"

#define INTRODUCTION_TAG 5

@interface ViewController() {

    ADBannerView * ad;
    //googleAd * gad;
    
    BOOL firstTime;

}

@property (nonatomic) SKView * gameView;
@property (nonatomic) SKScene * gameScene;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self presentGameScene];
    
}

- (void)viewDidAppear {
    
    if(YES) {
        
        //[defaults setBool:NO forKey:@"first"];
        
        UIStoryboard *storyboard = self.storyboard;
        IntroductionViewController *viewController = (IntroductionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"introduction"];
        
        [self presentViewController:viewController animated:YES completion:nil];
        
        //[[[[UIApplication sharedApplication] delegate] window] setRootViewController:viewController];
        //[self presentViewController:viewController animated:YES completion:nil];
        
    } else {
        
    }
    
}

- (void)presentGameScene {
    
    /*Messaging between subviews*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReciever:) name:@"viewcontroller" object:nil];
    
    /*iAd*/
    ad = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    ad.frame = CGRectMake(ad.frame.origin.x, self.view.frame.size.height - ad.frame.size.height, ad.frame.size.width, ad.frame.size.height);
    ad.hidden = YES;
    ad.delegate = self;
    [self.view addSubview:ad];
    
    /*VIEW SETUP*/
    self.gameView = (SKView *) self.view;
    
    self.gameView.showsFPS = YES;
    self.gameView.showsNodeCount = NO;
    
    self.gameScene = [GameRender sceneWithSize:self.gameView.bounds.size];
    self.gameScene.scaleMode = SKSceneScaleModeAspectFill;
    
    [self.gameView presentScene:self.gameScene];
    
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
    
    [self startGame];
    
}

- (void)startGame {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"render" object:@"startgame"];
    
}

- (void)forceStartGame {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"render" object:@"forcestartgame"];
    
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"render" object:@"pausegame"];
    
    return YES;
    
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    
    [self forceStartGame];
    
    if(YES) {
    
        //NSLog(@"Fuck, no ad.");
    
    }
    
}

- (void)messageReciever:(NSNotification *)notification {
    
    if([notification.object isKindOfClass:[NSString class]]) {

        NSString * message = (NSString *)notification.object;
        
        if([message isEqualToString:@"showad"]) {
            
            [self showAd];
            
        }
        
        if([message isEqualToString:@"hidead"]) {
            
            [self hideAd];
            
        }
        
    }
    
}

- (void)showAd {
    
    /*if((arc4random() % 4) > 1.0) {
        
        [self bannerView:nil didFailToReceiveAdWithError:nil];
        
    } else {*/
    
    if([ad isBannerLoaded]) {
        
        ad.hidden = NO;
        
    }/*else if([gad isBannerLoaded]) {
        
        
        
    }*/

    //}
    
}

- (void)hideAd {
    
    ad.hidden = YES;
    
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
