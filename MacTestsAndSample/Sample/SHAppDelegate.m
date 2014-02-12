//
//  SHAppDelegate.m
//  Example
//
//  Created by Seivan Heidari on 7/15/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//

#import "SHAppDelegate.h"
#import <BETURLSession.h>



@implementation SHAppDelegate

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification;{
  NSURLSession * session = [NSURLSession bet_sessionWithName:@"Random" baseURLString:@"http://httpbin.org"];
//  session.bet_autoResumed = YES;
  [[session bet_taskGETResource:@"get" withParams:@[@"x", @{@"y" : @"f"}] completion:^(NSError *error, NSObject<NSFastEnumeration> *responseObject, NSHTTPURLResponse *HTTPURLResponse, NSURLSessionTask *task) {
    NSLog(@"%@ - %@ - %@", HTTPURLResponse, task, responseObject);
  }] resume];
//  [[session bet_taskPOSTResource:@"post" withParams:@[@"x", @{@"y" : @"f"}] completion:^(NSError *error, NSObject<NSFastEnumeration> *responseObject, NSHTTPURLResponse *HTTPURLResponse, NSURLSessionTask *task) {
//    NSLog(@"%@ - %@ - %@", HTTPURLResponse, task, responseObject);
//  }] resume];
  
  
  
}

@end
