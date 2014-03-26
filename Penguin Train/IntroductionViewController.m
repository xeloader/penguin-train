//
//  IntroductionViewController.m
//  Penguin Train
//
//  Created by Victor Ingman on 2014-03-10.
//  Copyright (c) 2014 Victor Ingman. All rights reserved.
//

#import "GameKit/GameKit.h"

#import "IntroductionViewController.h"
#import "EasterEggViewController.h"

@interface IntroductionViewController () {
    
    NSInteger eggTaps;
    
}

@end

@implementation IntroductionViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self authenticateLocalPlayer];
    
    eggTaps = 0;
    self.eastereggButton.hidden = YES;
    
}

- (IBAction)easterEggTapped:(id)sender {
    
    eggTaps = 0;
    
    self.eastereggButton.hidden = YES;
    
    UIImage * crackedEgg = [UIImage imageNamed:@"egg-shadow@2x"];
    [self.eggButton setImage:crackedEgg forState:UIControlStateNormal];
    
}

- (IBAction)crackEgg:(id)sender {
    
    eggTaps++;
    
    if(eggTaps == 10) {
        
        UIImage * crackedEgg = [UIImage imageNamed:@"egg-crack@2x"];
        [sender setImage:crackedEgg forState:UIControlStateNormal];
        
    } else if(eggTaps == 25) {
        
        UIImage * crackedEgg = [UIImage imageNamed:@"penguin-shadow@2x"];
        [sender setImage:crackedEgg forState:UIControlStateNormal];
        
    } else if(eggTaps == 40) {
        
        self.eggButton.hidden = YES;
        self.eastereggButton.hidden = NO;
        
    }
    
}

- (void) authenticateLocalPlayer {
    
    GKLocalPlayer *player = [GKLocalPlayer localPlayer];
    
    [player authenticateHandler];
    
}

- (IBAction)startGame:(id)sender {
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
