//
//  SHAppDelegate.m
//  Example
//
//  Created by Seivan Heidari on 7/15/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//

#import "SHAppDelegate.h"
#import <BETURLSession.h>

@interface SHAppDelegate ()

@end


@implementation SHAppDelegate

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification;{
  NSURLSession * session = [NSURLSession bet_sessionWithName:@"Random" baseURLString:@"http://localhost:3000"];
  
  NSMutableArray * bigData = @[].mutableCopy;
  for (NSInteger i = 0; i!=50000; i++) {
    [bigData addObject:@(i)];
  }
  
//  NSURLSessionTask * task = [session bet_taskPOSTResource:@"post" withParams:@{@"POST" : bigData} completion:^(BETResponse *response) {
//    NSLog(@"POST completed with code %@ & error %@", @(response.HTTPURLResponse.statusCode), response.error);
//  }];

  //  NSURLSessionTask * task = [session bet_taskPOSTResource:@"post" withParams:@{@"POST" : bigData} completion:^(BETResponse *response) {
  //    NSLog(@"POST completed with code %@ & error %@", @(response.HTTPURLResponse.statusCode), response.error);
  //  }];

  
  NSURLSessionTask * task = [session bet_customTaskOnResource:@"users" requestHandler:^NSURLRequest *(NSMutableURLRequest *modifierRequest) {
    
    
    NSDictionary *parameters = @{@"user" :
                                   @{@"avatar":[[NSImage imageNamed:@"sample_image"] TIFFRepresentation],@"name":@"se<>ivan", @"weight" : @(1)}
                                 };
    
    
    [self addMultipartDataWithParameters:parameters toURLRequest:modifierRequest];
    
    modifierRequest.HTTPMethod = @"POST";
    return modifierRequest;
  } completionHandler:^(NSURL *location, NSData *responseObjectData, NSHTTPURLResponse *HTTPURLResponse, NSURLSessionTask *task, NSError *error) {
    NSString * response = [[NSString alloc] initWithData:responseObjectData encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@ \n %@ \n %@ \n %@ \n %@ \n", location, response, HTTPURLResponse, task, error);
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



#pragma mark - Content-type: multipart/form-data

- (void)addMultipartDataWithParameters:(NSDictionary *)parameters toURLRequest:(NSMutableURLRequest *)request
{
  NSString *boundary = nil;
  NSData *post = [self multipartDataWithParameters:parameters boundary:&boundary];
  [request setValue:[@"multipart/form-data; boundary=" stringByAppendingString:boundary] forHTTPHeaderField:@"Content-type"];
  request.HTTPBody = post;
}

- (NSData *)multipartDataWithParameters:(NSDictionary *)parameters boundary:(NSString **)boundary
{
  NSMutableData *result = [[NSMutableData alloc] init];
  if (boundary && !*boundary) {
    char buffer[32];
    for (NSUInteger i = 0; i < 32; i++) buffer[i] = "0123456789ABCDEF"[rand() % 16];
    NSString *random = [[NSString alloc] initWithBytes:buffer length:32 encoding:NSASCIIStringEncoding];
    *boundary = [NSString stringWithFormat:@"MyApp--%@", random];
  }
  NSData *newline = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
  NSData *boundaryData = [[NSString stringWithFormat:@"--%@\r\n", boundary ? *boundary : @""] dataUsingEncoding:NSUTF8StringEncoding];
  
  for (NSArray *pair in [self flatten:parameters]) {
    [result appendData:boundaryData];
    [self appendToMultipartData:result key:pair[0] value:pair[1]];
    [result appendData:newline];
  }
  NSString *end = [NSString stringWithFormat:@"--%@--\r\n", boundary ? *boundary : @""];
  [result appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
  return result;
}

- (void)appendToMultipartData:(NSMutableData *)data key:(NSString *)key value:(id)value
{
  if ([value isKindOfClass:NSData.class]) {
    NSString *name = key;
    if ([key rangeOfString:@"%2F"].length) {
      NSRange r = [name rangeOfString:@"%2F"];
      key = [key substringFromIndex:r.location + r.length];
      name = [name substringToIndex:r.location];
    }
    NSString *string = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: application/octet-stream\r\n\r\n", name, key];
    [data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:value];
  }
  else {
    NSString *string = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", key, value];
    [data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
  }
}

- (NSString *)unescape:(NSString *)string
{
  return CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)string, CFSTR(""), kCFStringEncodingUTF8));
}

- (NSString *)escape:(NSString *)string
{
  return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)string, NULL, CFSTR("*'();:@&=+$,/?!%#[]"), kCFStringEncodingUTF8));
}
-(NSArray *)flatten:(NSDictionary *)dictionary
{
  NSMutableArray *result = [NSMutableArray arrayWithCapacity:dictionary.count];
  NSArray *keys = [dictionary.allKeys sortedArrayUsingSelector:@selector(compare:)];
  for (NSString *key in keys) {
    id value = [dictionary objectForKey:key];
    if ([value isKindOfClass:NSArray.class] || [value isKindOfClass:NSSet.class]) {
      NSString *k = [[self escape:key] stringByAppendingString:@"[]"];
      for (id v in value) {
        [result addObject:@[k, v]];
      }
    } else if ([value isKindOfClass:NSDictionary.class]) {
      for (NSString *k in value) {
        NSString *kk = [[self escape:key] stringByAppendingFormat:@"[%@]", [self escape:k]];
        [result addObject:@[kk, [value valueForKey:k]]];
      }
    } else {
      [result addObject:@[[self escape:key], value]];
    }
  }
  return result;
}

@end
