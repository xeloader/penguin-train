//
//  ScoreCounter.m
//  Penguin Train
//
//  Created by Victor Ingman on 2014-02-27.
//  Copyright (c) 2014 Victor Ingman. All rights reserved.
//

#import "ScoreCounter.h"

@implementation ScoreCounter

- (ScoreCounter *) initScoreCounter {
    
    self = [super init];
    
    if(self) {
        
        [self resetCounter];
        
    }
    
    return self;
    
}

- (void)resetCounter {
    
    [self saveHighscore];
    
    self.count = 0;
    
}

- (void)saveHighscore {
    
    if(self.count > [self.class Highscore]) {
        
        [[NSUserDefaults standardUserDefaults] setInteger:self.count forKey:@"highscore"];
        
    }
    
}

+ (NSInteger)Highscore {
    
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"highscore"];
    
}

@end