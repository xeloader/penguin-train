//
//  IntroductionViewController.m
//  Penguin Train
//
//  Created by Victor Ingman on 2014-03-10.
//  Copyright (c) 2014 Victor Ingman. All rights reserved.
//

#import "IntroductionViewController.h"
#import "EasterEggViewController.h"

@interface IntroductionViewController () {
    
    NSInteger eggTaps;
    
}

@end

@implementation IntroductionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        eggTaps = 0;
        self.eastereggButton.hidden = YES;
        // Custom initialization
    }
    return self;
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

- (IBAction)startGame:(id)sender {
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
