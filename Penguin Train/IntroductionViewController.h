//
//  IntroductionViewController.h
//  Penguin Train
//
//  Created by Victor Ingman on 2014-03-10.
//  Copyright (c) 2014 Victor Ingman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroductionViewController : UIViewController

- (IBAction)startGame:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *eggButton;
@property (weak, nonatomic) IBOutlet UIButton *eastereggButton;

@end
