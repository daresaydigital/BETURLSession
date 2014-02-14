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
  
//  NSURLSessionTask * task = [session bet_taskPOSTResource:@"post" withParams:@{@"POST" : bigData} completion:^(BETResponse *response) {
//    NSLog(@"POST completed with code %@ & error %@", @(response.HTTPURLResponse.statusCode), response.error);
//  }];

  //  NSURLSessionTask * task = [session bet_taskPOSTResource:@"post" withParams:@{@"POST" : bigData} completion:^(BETResponse *response) {
  //    NSLog(@"POST completed with code %@ & error %@", @(response.HTTPURLResponse.statusCode), response.error);
  //  }];

  
  NSURLSessionTask * task = [session bet_customTaskOnResource:@"post" requestHandler:^NSURLRequest *(NSMutableURLRequest *modifierRequest) {
    modifierRequest.HTTPMethod = @"POST";
    NSString *boundary = [self boundaryString];
    [modifierRequest addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    
    NSData *fileData = [[NSImage imageNamed:@"sample_image"] TIFFRepresentation];
    NSData *data = [self createBodyWithBoundary:boundary username:@"rob" password:@"password" data:fileData filename:@"theFileorSo.png"];
    
    [modifierRequest setHTTPBody:data];
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

- (NSData *) createBodyWithBoundary:(NSString *)boundary username:(NSString*)username password:(NSString*)password data:(NSData*)data filename:(NSString *)filename
{
  NSMutableData *body = [NSMutableData data];
  
  if (data) {
    //only send these methods when transferring data as well as username and password
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", [self mimeTypeForPath:filename]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:data];
  }
  
  [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"username\"\r\n\r\n%@", username] dataUsingEncoding:NSUTF8StringEncoding]];
  
  [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"password\"\r\n\r\n%@", password] dataUsingEncoding:NSUTF8StringEncoding]];
  
  [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  
  return body;
}
- (NSString *)boundaryString
{
  // generate boundary string
  //
  // adapted from http://developer.apple.com/library/ios/#samplecode/SimpleURLConnections
  
  CFUUIDRef  uuid;
  NSString  *uuidStr;
  
  uuid = CFUUIDCreate(NULL);
  assert(uuid != NULL);
  
  uuidStr = CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
  assert(uuidStr != NULL);
  
  CFRelease(uuid);
  
  return [NSString stringWithFormat:@"Boundary-%@", uuidStr];
}

- (NSString *)mimeTypeForPath:(NSString *)path
{
  // get a mime type for an extension using MobileCoreServices.framework
  
  CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
  CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
  assert(UTI != NULL);
  
  NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
  assert(mimetype != NULL);
  
  CFRelease(UTI);
  
  return mimetype;
}
@end
