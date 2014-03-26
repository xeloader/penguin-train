//
//  ScoreCounter.m
//  Penguin Train
//
//  Created by Victor Ingman on 2014-02-27.
//  Copyright (c) 2014 Victor Ingman. All rights reserved.
//

#import "GameKit/GameKit.h"
#import "ScoreCounter.h"

@implementation ScoreCounter

- (ScoreCounter *) initScoreCounter {
    
    self = [super init];
    
    if(self) {
        
        //[self resetCounter];
        self.count = 0;
        
    }
    
    return self;
    
}

- (void)resetCounter {
    
    [self saveHighscore];
    
    self.count = 0;
    
}

- (void)saveHighscore {
    
    if(self.count > [self.class Highscore]) {
        
        GKScore * score = [[GKScore alloc] init];
        score.value = self.count;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"viewcontroller" object:@"newhighscore" userInfo:@{@"score":[NSNumber numberWithLong:self.count]}];
        
        [[NSUserDefaults standardUserDefaults] setInteger:self.count forKey:@"highscore"];
        
    }
    
}

+ (NSInteger)Highscore {
    
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"highscore"];
    
}

@end
