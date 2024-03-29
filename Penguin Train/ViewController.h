//
//  ViewController.h
//  Penguin Train
//

//  Copyright (c) 2014 Victor Ingman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

@interface ViewController : UIViewController <ADBannerViewDelegate, GADBannerViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *gameSection;
@property (weak, nonatomic) IBOutlet UILabel *highscoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *subheaderLabel;
@property (weak, nonatomic) IBOutlet UIView *highscoreView;

@property (weak, nonatomic) IBOutlet UIView *adView;

@end
