//
//  ViewController.m
//  Penguin Train
//
//  Created by Victor Ingman on 2014-02-25.
//  Copyright (c) 2014 Victor Ingman. All rights reserved.
//

#import "iAd/iAd.h"
#import "GADBannerView.h"

#import "ViewController.h"
#import "IntroductionViewController.h"
#import "GameRender.h"

#define INTRODUCTION_TAG 5

@interface ViewController() {

    ADBannerView * ad;
    GADBannerView * gad;
    
    BOOL firstTime;

}

@property (nonatomic) SKView * gameView;
@property (nonatomic) SKScene * gameScene;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self presentGameScene];
    
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
    
    /*Google AdMob*/
    gad = [[GADBannerView alloc] initWithFrame:CGRectMake(ad.frame.origin.x, self.view.frame.size.height - ad.frame.size.height, ad.frame.size.width, ad.frame.size.height)];
    //gad = [[GADBannerView alloc] init];
    gad.adUnitID = @"ca-app-pub-0463981839037305/3884569784";
    gad.rootViewController = self;
    gad.delegate = self;
    [self.view addSubview:gad];
    
    /*VIEW SETUP*/
    self.gameView = (SKView *) self.gameSection;
    
    //self.gameView.showsFPS = YES;
    //self.gameView.showsNodeCount = YES;
    
    self.gameScene = [GameRender sceneWithSize:self.gameView.bounds.size];
    self.gameScene.scaleMode = SKSceneScaleModeAspectFill;
    
    [self.gameView presentScene:self.gameScene];
    
    //Start the ads
    [self showAd];
    
}

- (void)startGame {
    
    if(self.highscoreView.hidden == YES) {
    
        [[NSNotificationCenter defaultCenter] postNotificationName:@"render" object:@"startgame"];
        
    }
    
}

- (void)pauseGame {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"render" object:@"pausegame"];
    
}

- (void)forceStartGame {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"render" object:@"forcestartgame"];
    
}

/**ADS**/

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {

    if(self.highscoreView.hidden == YES) {
     
        [self forceStartGame];
        
    }
    
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    
    [self pauseGame];
    
    return YES;
    
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error { //iAD
    
    NSLog(@"apple failed");
    ad.hidden = YES; //hide iAD
    
    [self showAd]; //give google a shot.
    
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error { //adMob

    NSLog(@"google failed");
    gad.hidden = YES;
    
}

- (void)showAd {
    
    /*if((arc4random() % 4) > 1.0) {
        
        [self bannerView:nil didFailToReceiveAdWithError:nil];
        
        [self fetchGoogleAd];
        
    } else {*/
    
    if([ad isBannerLoaded]) {
        
        ad.hidden = NO;
        
    } else {
        
        [self fetchGoogleAd];
        
    }
    
    //}
    
}

- (void)showHighscoreOf:(NSInteger)score {
    
    [self pauseGame];
    
    [self.highscoreLabel setText:[NSString stringWithFormat:@"%ld", (long)score]];

    self.highscoreView.hidden = NO;
    
}

- (IBAction)dismissHighscoreAndPlay:(id)sender {
    
    self.highscoreView.hidden = YES;
    [self forceStartGame];
    
}

- (void)fetchGoogleAd {
    
    GADRequest *request = [GADRequest request];
    /*request.testDevices = @[
                                GAD_SIMULATOR_ID, //simulator
                                @"140aad9b7b0c32689b0f6a227c6295e903ecff1b", //philip
                                @"7e45ff6a0cb8620012b5e40aa90dac3f744a7963", //mamma
                                @"2a3b02b899773df63ccfce8506da9fbed14cc882", //macce
                                @"566cec4b6d686932e8bbdcff3261a1c699d1fb35", //min
                                @"31af3530f342a6a428830ed6caf88bd5891e8eda", //pappa
                                @"d327c47116d7e7f84cfed831d6dd742c11926d1d", //johanna
                            ];*/
    
    [gad loadRequest:request];
    
}

- (void)adViewDidReceiveAd:(GADBannerView *)view { //pretty much the same as [ad isBannerLoaded]
    
    if(ad.hidden) { //if apple ad is hidden.
    
        gad.hidden = NO; //only show if iAd is hidden.
        
    }
    
}

- (void)bannerViewWillLoadAd:(ADBannerView *)banner {
    
    ad.hidden = NO;
    gad.hidden = YES;
    
}

- (void)hideAd {
    
    ad.hidden = YES;
    gad.hidden = YES;
    
}

/*EOF ADS*/

- (void)messageReciever:(NSNotification *)notification {
    
    if([notification.object isKindOfClass:[NSString class]]) {

        NSString * message = (NSString *)notification.object;
        
        if([message isEqualToString:@"showad"]) {
            
            //[self showAd];
            
        }
        
        if([message isEqualToString:@"hidead"]) {
            
            //[self hideAd];
            
        }

        if([message isEqualToString:@"startgame"]) {
            
            [self startGame];
            
        }
        
        
        if([message isEqualToString:@"newhighscore"]) {
            
            NSLog(@"RECIEVED MESSAGE ABOUT HIGHSCORE");
            
            long score = [notification.userInfo[@"score"] longValue];
            
            [self showHighscoreOf:score];
            
        }
        
        if([message isEqualToString:@"pausegame"]) {
            
            [self pauseGame];
            
        }
        
    }
    
}

- (BOOL)shouldAutorotate { return NO; }

- (NSUInteger)supportedInterfaceOrientations {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        return UIInterfaceOrientationMaskAllButUpsideDown;
        
    } else {
        
        return UIInterfaceOrientationMaskAll;
        
    }
    
}

@end
