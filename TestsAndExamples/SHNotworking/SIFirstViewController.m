//
//  SIFirstViewController.m
//  SINotworking
//
//  Created by Seivan Heidari on 2013-10-29.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//

#import "SIFirstViewController.h"
#import <SIURLSessionBlocks.h>
#define CLIENT_ID  @"7y7gp0495bt7acqbqdaw7y7gp0495bt7"
#define APP_SECRET @"ckm6ssv30cwz1zg7xu2pckm6ssv30cwz1zg7xu2p"
#define REDIRECT_URI @"etalio7y7gp0495bt7acqbqdaw7y7gp0495bt7://authentication"


@interface SIFirstViewController ()

@end

@implementation SIFirstViewController

-(void)viewWillAppear:(BOOL)animated;{
  [super viewWillAppear:animated];
  
  
//  NSString * login = [NSString stringWithFormat:@"https://api-etalio.3fs.si/oauth2?response_type=code&client_id=%@&redirect_uri=%@&state=trolololol", CLIENT_ID, REDIRECT_URI];
//  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:login]];
  
  
  
//  NSString *imageUrl = @"http://www.raywenderlich.com/images/store/iOS7_PDFonly_280@2x_authorTBA.png";
  
  NSData * imageData = UIImagePNGRepresentation([UIImage imageNamed:@"666"]);
  
  __block NSDictionary *mapData = @{@"user" : @{@"name" : @"Seivan", @"avatar" :  [imageData base64EncodedStringWithOptions:0]}};

  
  NSURLSession * session = [NSURLSession SI_fetchSessionWithName:@"Seivan"];
  
  
  if(session == nil) session = [NSURLSession SI_buildDefaultSessionWithName:@"Seivan" withBaseURLString:@"http://0.0.0.0:3000"];
  
//  session.SI_delegate = self;
  NSURLSessionTask * task =[session SI_taskPOSTResource:@"users" withParams:mapData
                                          completeBlock:^(NSError *error, NSDictionary *responseObject, NSHTTPURLResponse *urlResponse, NSURLSessionTask *task) {
                                            NSLog(@"SI_setRequestCompleteBlock: %@  %@ ", error,responseObject) ;
                                          }];
  

 
  [task SI_setDownloadProgressBlock:^(NSURLSessionTask *task, NSInteger bytes, NSInteger totalBytes, NSInteger totalBytesExpected) {
        NSLog(@"DOWNLOAD: %@ - %@ - %@ - %@", @(bytes), @(totalBytes), @(totalBytesExpected), task);
    [task SI_setDownloadProgressBlock:nil];
  }];
  

  [task SI_setUploadProgressBlock:^(NSURLSessionTask *task, NSInteger bytes, NSInteger totalBytes, NSInteger totalBytesExpected) {
        NSLog(@"UPLOAD: %@ - %@ - %@ - %@", @(bytes), @(totalBytes), @(totalBytesExpected), task);
    [task SI_setUploadProgressBlock:nil];
  }];
  

  if([NSURLSession SI_fetchSessionWithName:@"Seivanx"] == nil) [NSURLSession SI_buildDefaultSessionWithName:@"Seivanx" withBaseURLString:@"http://0.0.0.0:3000"];
  

  [task SI_setTaskDidCompleteWithErrorBlock:^(NSURLSessionTask *task, NSError *error) {
    double delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      mapData = @{@"my" : @{@"dictionary" : @[@"With", @"Arrays", @"Arrays", @"and", [NSOrderedSet orderedSetWithArray:@[@"ordered",@"ordered",@"set"]]]}};
      
      NSURLSessionTask * xask = [[NSURLSession SI_fetchSessionWithName:@"Seivanx"] SI_taskGETResource:@"users" withParams:mapData completeBlock:^(NSError *error, NSDictionary *responseObject, NSHTTPURLResponse *urlResponse, NSURLSessionTask *task) {
        NSLog(@"XASK QUERY PARAMETERS %@", responseObject);
      }] ;
      
      
      [xask SI_setDownloadProgressBlock:^(NSURLSessionTask *task, NSInteger bytes, NSInteger totalBytes, NSInteger totalBytesExpected) {
        NSLog(@"XASK DOWNLOAD: %@ - %@ - %@ - %@", @(bytes), @(totalBytes), @(totalBytesExpected), task);
        //        [task SI_setDownloadProgressBlock:nil];
      }];
      
      
      [xask SI_setUploadProgressBlock:^(NSURLSessionTask *task, NSInteger bytes, NSInteger totalBytes, NSInteger totalBytesExpected) {
        NSLog(@"XASK UPLOAD: %@ - %@ - %@ - %@", @(bytes), @(totalBytes), @(totalBytesExpected), task);
        //        [task SI_setUploadProgressBlock:nil];
      }];
      
      [xask resume];
      
    });

  }];
  [task resume];
    

}
-(void)viewDidAppear:(BOOL)animated; {
  
}


/* The last message a session receives.  A session will only become
 * invalid because of a systemic error or when it has been
 * explicitly invalidated, in which case it will receive an
 * { NSURLErrorDomain, NSURLUserCanceled } error.
 */
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error; {
    NSParameterAssert(session);
}

/* If implemented, when a connection level authentication challenge
 * has occurred, this delegate will be given the opportunity to
 * provide authentication credentials to the underlying
 * connection. Some types of authentication will apply to more than
 * one request on a given connection to a server (SSL Server Trust
 * challenges).  If this delegate message is not implemented, the
 * behavior will be to use the default handling, which may involve user
 * interaction.
 */
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler;{
  NSParameterAssert(session);
  NSParameterAssert(challenge);
  NSParameterAssert(completionHandler);
}

/* If an application has received an
 * -application:handleEventsForBackgroundURLSession:completionHandler:
 * message, the session delegate will receive this message to indicate
 * that all messages previously enqueued for this session have been
 * delivered.  At this time it is safe to invoke the previously stored
 * completion handler, or to begin any internal updates that will
 * result in invoking the completion handler.
 */
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session NS_AVAILABLE_IOS(7_0);{
  
  
}



/*
 * Messages related to the operation of a specific task.
 */

/* An HTTP request is attempting to perform a redirection to a different
 * URL. You must invoke the completion routine to allow the
 * redirection, allow the redirection with a modified request, or
 * pass nil to the completionHandler to cause the body of the redirection
 * response to be delivered as the payload of this request. The default
 * is to follow redirections.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler;{
  NSParameterAssert(session);
  NSParameterAssert(task);
  NSParameterAssert(response);
  NSParameterAssert(request);
  NSParameterAssert(completionHandler);

  
}

/* The task has received a request specific authentication challenge.
 * If this delegate is not implemented, the session specific authentication challenge
 * will *NOT* be called and the behavior will be the same as using the default handling
 * disposition.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler;{
  NSParameterAssert(session);
  NSParameterAssert(task);
  NSParameterAssert(completionHandler);
}

/* Sent if a task requires a new, unopened body stream.  This may be
 * necessary when authentication has failed for any request that
 * involves a body stream.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler;{
  NSParameterAssert(session);
  NSParameterAssert(task);
  NSParameterAssert(completionHandler);

}

/* Sent periodically to notify the delegate of upload progress.  This
 * information is also available as properties of the task.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend;{
  NSParameterAssert(session);
  NSParameterAssert(task);
  NSParameterAssert(totalBytesExpectedToSend > 0);
}

/* Sent as the last message related to a specific task.  Error may be
 * nil, which implies that no error occurred and this task is complete.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error;{
  NSParameterAssert(session);
  NSParameterAssert(task);
  NSParameterAssert(error == nil);
}



/*
 * Messages related to the operation of a task that delivers data
 * directly to the delegate.
 */
/* The task has received a response and no further messages will be
 * received until the completion block is called. The disposition
 * allows you to cancel a request or to turn a data task into a
 * download task. This delegate message is optional - if you do not
 * implement it, you can get the response as a property of the task.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler;{
  NSParameterAssert(session);
  NSParameterAssert(dataTask);
  NSParameterAssert(completionHandler);
  completionHandler(NSURLSessionResponseBecomeDownload);

}

/* Notification that a data task has become a download task.  No
 * future messages will be sent to the data task.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask;{
  NSParameterAssert(session);
  NSParameterAssert(dataTask);
  NSParameterAssert(downloadTask);

}

/* Sent when data is available for the delegate to consume.  It is
 * assumed that the delegate will retain and not copy the data.  As
 * the data may be discontiguous, you should use
 * [NSData enumerateByteRangesUsingBlock:] to access it.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data;{
  NSParameterAssert(session);
  NSParameterAssert(dataTask);
  NSParameterAssert(data);
}

/* Invoke the completion routine with a valid NSCachedURLResponse to
 * allow the resulting data to be cached, or pass nil to prevent
 * caching. Note that there is no guarantee that caching will be
 * attempted for a given resource, and you should not rely on this
 * message to receive the resource data.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler;{
  NSParameterAssert(session);
  NSParameterAssert(dataTask);
  NSParameterAssert(proposedResponse);
  NSParameterAssert(completionHandler);

}



/*
 * Messages related to the operation of a task that writes data to a
 * file and notifies the delegate upon completion.
 */


/* Sent when a download task that has completed a download.  The delegate should
 * copy or move the file at the given location to a new location as it will be
 * removed when the delegate message returns. URLSession:task:didCompleteWithError: will
 * still be called.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location;{
  NSParameterAssert(session);
  NSParameterAssert(downloadTask);
  NSParameterAssert(location);
  
}

/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;{
  NSParameterAssert(session);
  NSParameterAssert(downloadTask);
  NSParameterAssert(totalBytesExpectedToWrite > 0);
  
}

/* Sent when a download has been resumed. If a download failed with an
 * error, the -userInfo dictionary of the error will contain an
 * NSURLSessionDownloadTaskResumeData key, whose value is the resume
 * data.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes;{
  NSParameterAssert(session);
  NSParameterAssert(downloadTask);
  
  
}


@end

