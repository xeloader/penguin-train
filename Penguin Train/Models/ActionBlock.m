//
//  ActionBlock.m
//  Penguin Train
//
//  Created by Victor Ingman on 2014-02-25.
//  Copyright (c) 2014 Victor Ingman. All rights reserved.
//

#import "ActionBlock.h"

@implementation ActionBlock

- (ActionBlock *) initActionBlockAsType:(NSInteger)requestedType atPoint:(CGPoint)startingPoint {
    
    self = [super initWithBlockPoint:startingPoint];
    
    if(self) {
        
        self.type = requestedType;
        
        self.recentlyEaten = NO;
        self.lifeCycles = [self.class lifeCyclesForType:self.type]; //set once.
        
    }
    
    return self;
    
}

- (void)setType:(NSInteger)type {
    
    if(type == TYPE_RANDOM) {
        
        [self randomizeNextActionBlock];
        
    } else {
    
        _type = type;
    
        self.value = [self.class valueForType:_type];
        self.colorIdentifier = [self.class colorForType:_type];
        self.loopCycles = [self convertSecondsIntoLoopCycles:[self.class lifeLengthInSeconds:_type]];
        
    }
    
}

- (void)decrementLoopCycle {
    
    if(self.loopCycles != LIFECYCLE_INVINCIBLE && self.loopCycles != LIFECYCLE_DEAD) {
        
        self.loopCycles--;
     
        if(self.loopCycles <= LIFECYCLE_DEAD) {
            
            if(self.lifeCycles == LIFECYCLE_INVINCIBLE) {
                
                [self randomizeNextActionBlock];
                
            } else {
            
                self.lifeCycles = LIFECYCLE_DEAD;
                self.active = NO; //inactive, remove.
                
            }
            
        }
        
    }
    
}

- (void) eaten {
    
    if(self.lifeCycles != LIFECYCLE_INVINCIBLE && self.lifeCycles != LIFECYCLE_DEAD) { //not dead, not invincible.
    
        self.lifeCycles--;
        
        if(self.lifeCycles <= LIFECYCLE_DEAD) {
            
            self.active = NO; //inactive, remove.
            
        }
        
    }
    
    self.recentlyEaten = YES;
    
}

- (void)randomizeNextActionBlock {
    
    NSInteger random = arc4random() % 100;
    
    BOOL bonusChance = (random > (100 - CHANCE_BONUS));
    
    if(bonusChance) {
        
        self.type = TYPE_BONUS;
        
    } else {
        
        self.type = TYPE_FOOD;
        
    }
    
}

- (float)convertSecondsIntoLoopCycles:(float)seconds {
    
    if(seconds != LIFECYCLE_INVINCIBLE) {
    
        return [self.class convertSecondsIntoLoopCycles:seconds forLoopIntervalOf:[[self.class gamespeed] floatValue]];
        
    }
    
    return LIFECYCLE_INVINCIBLE;
    
}

+ (float)convertSecondsIntoLoopCycles:(float)seconds forLoopIntervalOf:(float)loopInterval {
    
    return (seconds / (loopInterval / 1000));
    
}

+ (NSInteger)valueForType:(NSInteger)requestedType {
    
    switch(requestedType) {
            
        case TYPE_BONUSRAIN:
            
            return 5;
            
            break;
            
        case TYPE_FOOD:
            
            return 10;
            
            break;
            
        case TYPE_BONUS:
            
            return 25;
            
            break;
            
        default:
            
            return 0;
            
            break;
            
    }
    
}

+ (int) lifeCyclesForType:(NSInteger)requestedType {
    
    switch(requestedType) {
            
        case TYPE_BONUS:
        case TYPE_FOOD:
            
            return LIFECYCLE_INVINCIBLE;
            
            break;
            
        case TYPE_BONUSRAIN:
            
            return 1;
            
            break;
            
        default:
            
            return LIFECYCLE_DEAD;
            
            break;
            
    }
    
}

+ (float)lifeLengthInSeconds:(NSInteger)requestedType {
    
    switch(requestedType) {
        
        case TYPE_FOOD:
            
            return LIFECYCLE_INVINCIBLE;
            
            break;
            
        case TYPE_BONUS:
            
            return 5;
            
            break;
            
        case TYPE_BONUSRAIN:
            
            return 7.5;
            
            break;
            
        default:
            
            return LIFECYCLE_DEAD;
            
            break;
            
    }
    
}

+ (UIColor *) colorForType:(NSInteger)requestedType {
    
    switch(requestedType) {
            
        case TYPE_BONUS:
            
            return [UIColor yellowColor];
            
            break;
            
        case TYPE_BONUSRAIN:
            
            return [UIColor cyanColor];
            
            break;
            
        case TYPE_FOOD:
            
            return [UIColor greenColor];
            
            break;
            
        default:
            
            return [UIColor grayColor];
            
            break;
            
    }
    
}

+ (NSArray *)everyType {
    
    return @[@TYPE_BONUS, @TYPE_BONUSRAIN, @TYPE_FOOD];
    
}

@end