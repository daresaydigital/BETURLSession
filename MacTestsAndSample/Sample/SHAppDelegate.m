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
  
}

@end
