//
//  AppDelegate.m
//  Penguin Train
//
//  Created by Victor Ingman on 2014-02-25.
//  Copyright (c) 2014 Victor Ingman. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"viewcontroller" object:@"pausegame"];

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"viewcontroller" object:@"startgame"];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

@end
