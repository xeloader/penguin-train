//
//  ScoreCounter.h
//  Penguin Train
//
//  Created by Victor Ingman on 2014-02-27.
//  Copyright (c) 2014 Victor Ingman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScoreCounter : NSObject

@property (nonatomic) NSInteger count;
@property (nonatomic) NSDate * timestamp;

- (ScoreCounter *)initScoreCounter;
- (void)saveHighscore;
- (void)resetCounter;

+ (NSInteger)Highscore;

@end
