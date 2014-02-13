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
  
  NSMutableArray * bigData = @[].mutableCopy;
  for (NSInteger i = 0; i!=50000; i++) {
    [bigData addObject:@(i)];
  }
  
  NSURLSessionTask * task = [session bet_taskPOSTResource:@"post" withParams:@{@"POST" : bigData} completion:^(BETResponse *response) {
    NSLog(@"POST completed with code %@ & error %@", @(response.HTTPURLResponse.statusCode), response.error);
  }];
  
  BETURLSessionTaskProgressHandlerBlock (^progressHandlerWithName)(NSString *) = ^BETURLSessionTaskProgressHandlerBlock(NSString * name) {
    return ^(NSURLSessionTask *task, NSInteger bytes, NSInteger totalBytes, NSInteger totalBytesExpected) {
      NSLog(@"%@ : %@ <-> %@ <-> %@", name, @(bytes), @(totalBytes), @(totalBytesExpected));
    };
  };


  
  [task bet_setUploadProgressHandler:progressHandlerWithName(@"Upload")];
  
  [task bet_setDownloadProgressHandler:progressHandlerWithName(@"Download")];
  
  [task resume];
  
}

@end
