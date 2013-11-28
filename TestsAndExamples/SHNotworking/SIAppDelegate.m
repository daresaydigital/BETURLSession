//
//  SIAppDelegate.m
//  SINotworking
//
//  Created by Seivan Heidari on 2013-10-29.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//

#import "SIAppDelegate.h"
#import <SIURLSessionBlocks.h>
#define CLIENT_ID  @"7y7gp0495bt7acqbqdaw7y7gp0495bt7"
#define APP_SECRET @"ckm6ssv30cwz1zg7xu2pckm6ssv30cwz1zg7xu2p"
#define REDIRECT_URI @"etalio7y7gp0495bt7acqbqdaw7y7gp0495bt7://authentication"

@implementation SIAppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;{
  // Override point for customization after application launch.
  return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation; {
  NSLog(@"%@ %@ %@", url.query, sourceApplication, annotation);
  NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
  for (NSString *param in [[url query] componentsSeparatedByString:@"&"]) {
    NSArray *parts = [param componentsSeparatedByString:@"="];
    if([parts count] < 2) continue;
    [params setObject:[parts objectAtIndex:1] forKey:[parts objectAtIndex:0]];
  }
  
  NSDictionary * postData = @{@"grant_type" : @"authorization_code",
                              @"code" : params[@"code"],
                              @"redirect_uri" : REDIRECT_URI,
                              @"client_secret" : APP_SECRET,
                              @"client_id" : CLIENT_ID
                              };
  
  [NSURLSession SI_buildDefaultSessionWithName:@"x" withBaseURLString:@"https://api-etalio.3fs.si"];
  [[[NSURLSession SI_fetchSessionWithName:@"x"] SI_taskPOSTResource:@"oauth2/token" withParams:postData completeBlock:^(NSError *error, NSDictionary *responseObject, NSHTTPURLResponse *urlResponse, NSURLSessionTask *task) {
    
  }] resume];
  
  return YES;
}

							
-(void)applicationWillResignActive:(UIApplication *)application; {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

-(void)applicationDidEnterBackground:(UIApplication *)application; {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

-(void)applicationWillEnterForeground:(UIApplication *)application; {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

-(void)applicationDidBecomeActive:(UIApplication *)application;{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


-(void)applicationWillTerminate:(UIApplication *)application;{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
