
#import "__BETInternalManager+Delegate.h"
#import "BETURLSession.h"
#import "__BETInternalShared.private"

@interface NSURLSession (Privates)
typedef void (^BETDogmaPerformerBlock)(__BETInternalSession * internalSession, __BETInternalSessionTask * internalSessionTask, BOOL *stop);

-(void)bet_delegateWithSession:(NSURLSession *)theSession
                         task:(NSURLSessionTask *)theTask
                  selector:(SEL)theSelector
                    sharedBefore:(BETDogmaPerformerBlock)theSharedBeforeBlock
                     taskBlock:(BETDogmaPerformerBlock)theTaskBlock
                  delegate:(BETDogmaPerformerBlock)theDelegateBlock
                  internal:(BETDogmaPerformerBlock)theInternalBlock;

@end

@implementation NSObject (Privates)

-(void)bet_delegateWithSession:(NSURLSession *)theSession
                         task:(NSURLSessionTask *)theTask
                  selector:(SEL)theSelector
                    sharedBefore:(BETDogmaPerformerBlock)theSharedBeforeBlock
                     taskBlock:(BETDogmaPerformerBlock)theTaskBlock
                  delegate:(BETDogmaPerformerBlock)theDelegateBlock
                  internal:(BETDogmaPerformerBlock)theInternalBlock; {
  

  NSParameterAssert(theSelector);


  __BETInternalSession * internalSession = theSession.bet_internalSession;
  __BETInternalSessionTask * internalSessionTask = nil;


  if(theTask) internalSessionTask = [internalSession.mapTasks objectForKey:theTask];

  
  if(theSharedBeforeBlock)theSharedBeforeBlock(internalSession,internalSessionTask, NO);
  BOOL shouldStopHere = NO;
  if(shouldStopHere == NO && theTaskBlock)
    theTaskBlock(internalSession, internalSessionTask, &shouldStopHere);
  
  if(shouldStopHere == NO && theDelegateBlock && internalSession.bet_delegate && [internalSession.bet_delegate respondsToSelector:theSelector])
    theDelegateBlock(internalSession, internalSessionTask, &shouldStopHere);

  if(shouldStopHere == NO && theInternalBlock)
    theInternalBlock(internalSession, internalSessionTask, &shouldStopHere);
}

@end


@implementation __BETInternalManager (Delegate)


#pragma mark - <NSURLSessionDelegate>

/* The last message a session receives.  A session will only become
 * invalid because of a systemic error or when it has been
 * explicitly invalidated, in which case it will receive an
 * { NSURLErrorDomain, NSURLUserCanceled } error.
 */

#warning Got to take care of this at some point - invalidated Sessions from sessionMap on invalidation callback
-(void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error; {

  [self bet_delegateWithSession:session task:nil selector:_cmd
               sharedBefore:nil
                      taskBlock:nil
                   delegate:^void(__BETInternalSession *internalSession, __unused __BETInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     [internalSession.bet_delegate URLSession:session didBecomeInvalidWithError:error];
                   }
                   internal:^void(__unused __BETInternalSession *internalSession, __unused __BETInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     [[[__BETInternalManager sharedManager] mapSessions] removeObjectForKey:session];
                   }];

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
-(void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler; {

//  completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialWithUser:@"12345" password:@"12345" persistence:NSURLCredentialPersistenceForSession]);
//  
  [self bet_delegateWithSession:session task:nil selector:_cmd
               sharedBefore:nil
                      taskBlock:nil
                   delegate:^void(__BETInternalSession *internalSession, __unused __BETInternalSessionTask *internalSessionTask, BOOL *stop) {
                     [internalSession.bet_delegate URLSession:session didReceiveChallenge:challenge completionHandler:completionHandler];
                     *stop = YES;
                     
                   }
                   internal:^void(__unused __BETInternalSession *internalSession, __unused __BETInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
                   }];

}

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
/* If an application has received an
 * -application:handleEventsForBackgroundURLSession:completionHandler:
 * message, the session delegate will receive this message to indicate
 * that all messages previously enqueued for this session have been
 * delivered.  At this time it is safe to invoke the previously stored
 * completion handler, or to begin any internal updates that will
 * result in invoking the completion handler.
 */
-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session NS_AVAILABLE_IOS(7_0); {

  [self bet_delegateWithSession:session task:nil selector:_cmd
               sharedBefore:nil
                      taskBlock:nil
                   delegate:^void(__BETInternalSession *internalSession, __unused __BETInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     [internalSession.bet_delegate URLSessionDidFinishEventsForBackgroundURLSession:session];
                   }
                   internal:nil];
  
}
#endif
#pragma mark - <NSURLSessionTaskDelegate>

/* An HTTP request is attempting to perform a redirection to a different
 * URL. You must invoke the completion routine to allow the
 * redirection, allow the redirection with a modified request, or
 * pass nil to the completionHandler to cause the body of the redirection
 * response to be delivered as the payload of this request. The default
 * is to follow redirections.
 */
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler; {
  
  [self bet_delegateWithSession:session task:task selector:_cmd
               sharedBefore:nil
                      taskBlock:^void(__BETInternalSession *internalSession, __BETInternalSessionTask *internalSessionTask, BOOL *stop) {
                        if(internalSessionTask.bet_taskWillPerformHTTPRedirectionHandler) {
                          internalSessionTask.bet_taskWillPerformHTTPRedirectionHandler(task,response,request,completionHandler);
                          *stop = YES;
                        }
                      }
                   delegate:^void(__BETInternalSession *internalSession, __BETInternalSessionTask *internalSessionTask, BOOL *stop) {
                     [internalSession.bet_delegate URLSession:session task:task willPerformHTTPRedirection:response newRequest:request completionHandler:completionHandler];
                     *stop = YES;
                   }
                   internal:^void(__unused __BETInternalSession *internalSession, __unused __BETInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     completionHandler(request);
                   }];
}

/* The task has received a request specific authentication challenge.
 * If this delegate is not implemented, the session specific authentication challenge
 * will *NOT* be called and the behavior will be the same as using the default handling
 * disposition.
 */
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler; {
  
  [self bet_delegateWithSession:session task:task selector:_cmd
                  sharedBefore:nil
                      taskBlock:^(__unused __BETInternalSession *internalSession, __BETInternalSessionTask *internalSessionTask, BOOL *stop) {
                        if(internalSessionTask.bet_taskDidReceiveChallengeHandler) {
                          internalSessionTask.bet_taskDidReceiveChallengeHandler(task, challenge, completionHandler);
                          *stop = YES;
                        }
                      }
                   delegate:^(__BETInternalSession *internalSession, __unused __BETInternalSessionTask *internalSessionTask, BOOL *stop) {
                     [internalSession.bet_delegate URLSession:session task:task didReceiveChallenge:challenge completionHandler:completionHandler];
                     *stop = YES;
                   }
                   internal:^(__unused __BETInternalSession *internalSession, __unused __BETInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
                   }];
  
}

/* Sent if a task requires a new, unopened body stream.  This may be
 * necessary when authentication has failed for any request that
 * involves a body stream.
 */
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler; {
  
  [self bet_delegateWithSession:session task:task selector:_cmd
               sharedBefore:nil
                      taskBlock:^(__unused __BETInternalSession *internalSession, __BETInternalSessionTask *internalSessionTask, BOOL *stop) {
                        if(internalSessionTask.bet_taskNeedNewBodyStreamHandler) {
                          internalSessionTask.bet_taskNeedNewBodyStreamHandler(task, completionHandler);
                          *stop = YES;
                        }
                      }
                   delegate:^(__BETInternalSession *internalSession, __unused __BETInternalSessionTask *internalSessionTask, BOOL *stop) {
                     [internalSession.bet_delegate URLSession:session task:task needNewBodyStream:completionHandler];
                     *stop = YES;
                   }
                   internal:^(__unused __BETInternalSession *internalSession, __unused __BETInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     completionHandler(nil);
                   }];

}

/* Sent periodically to notify the delegate of upload progress.  This
 * information is also available as properties of the task.
 */
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend; {
  
  [self bet_delegateWithSession:session task:task selector:_cmd
               sharedBefore:nil
                      taskBlock:^(__unused __BETInternalSession *internalSession, __BETInternalSessionTask *internalSessionTask, BOOL *stop) {
                        if(internalSessionTask.bet_uploadProgressHandler) {
                          internalSessionTask.bet_uploadProgressHandler(task, (NSInteger)bytesSent,(NSInteger)totalBytesSent,(NSInteger)totalBytesExpectedToSend);
                          *stop = YES;
                        }
                      }
                   delegate:^(__BETInternalSession *internalSession, __unused __BETInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     [internalSession.bet_delegate URLSession:session task:task didSendBodyData:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
                   }
                   internal:nil];

}


/* Sent as the last message related to a specific task.  Error may be
 * nil, which implies that no error occurred and this task is complete.
 */
#warning Sooo probably remove completed tasks from mapTasks, maybe delay the removal.
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error; {
  
  [self bet_delegateWithSession:session task:task selector:_cmd
               sharedBefore:^(__BETInternalSession *internalSession, __BETInternalSessionTask *internalSessionTask, __unused BOOL *stop) {


                 internalSessionTask.bet_error = error;

                 if(internalSessionTask.bet_requestCompletion) {

                   [session.bet_serializerForResponse buildObjectForResponse:task.response responseData:internalSessionTask.bet_data onCompletion:^(id obj, NSError *responseError) {
                     internalSessionTask.bet_parseResponseError = responseError;
                     if(internalSessionTask.bet_error == nil) internalSessionTask.bet_error = error;
                     if(internalSessionTask.bet_error == nil) internalSessionTask.bet_error = responseError;
                     internalSessionTask.bet_parsedObject = obj;
                     NSObject<NSFastEnumeration> * enumerableObject = obj;
                     internalSessionTask.bet_requestCompletion(enumerableObject,
                                                                 (NSHTTPURLResponse *)task.response,
                                                                  task,
                                                                 internalSessionTask.bet_error);

                   }];


                 }
                 if(internalSessionTask.bet_requestDataCompletion) {
                   internalSessionTask.bet_requestDataCompletion(internalSessionTask.bet_downloadLocation,
                                                                    internalSessionTask.bet_data,
                                                                    (NSHTTPURLResponse *)task.response,
                                                                    task,
                                                                    internalSessionTask.bet_error);
                   
                 }


               }
                     taskBlock:^(__unused __BETInternalSession *internalSession, __BETInternalSessionTask *internalSessionTask, BOOL *stop) {
                       if(internalSessionTask.bet_taskDidCompleteWithErrorHandler){
                         internalSessionTask.bet_taskDidCompleteWithErrorHandler(task, error);
                         *stop = YES;
                       }

                      }
                   delegate:^(__BETInternalSession *internalSession, __unused __BETInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     [internalSession.bet_delegate URLSession:session task:task didCompleteWithError:error];
                   }
                   internal:^(__BETInternalSession *internalSession, __BETInternalSessionTask *internalSessionTask, BOOL *stop) {

                   }];

}


#pragma mark - <NSURLSessionDataDelegate>
/* The task has received a response and no further messages will be
 * received until the completion block is called. The disposition
 * allows you to cancel a request or to turn a data task into a
 * download task. This delegate message is optional - if you do not
 * implement it, you can get the response as a property of the task.
 */
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler; {
  
  [self bet_delegateWithSession:session task:dataTask selector:_cmd
               sharedBefore:^(__BETInternalSession *internalSession, __BETInternalSessionTask *internalSessionTask, __unused BOOL *stop) {

               }
                     taskBlock:^(__unused __BETInternalSession *internalSession, __BETInternalSessionTask *internalSessionTask, BOOL *stop) {
                        if(internalSessionTask.bet_taskDidReceiveResponseHandler) {
                          internalSessionTask.bet_taskDidReceiveResponseHandler(dataTask,response,completionHandler);
                          *stop = YES;
                        }
                      }
                   delegate:^(__BETInternalSession *internalSession, __unused __BETInternalSessionTask *internalSessionTask, BOOL *stop) {
                     [internalSession.bet_delegate URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
                     *stop = YES;
                   }
                   internal:^(__unused __BETInternalSession *internalSession, __unused __BETInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     completionHandler(NSURLSessionResponseBecomeDownload);
                   }];

  
}

/* Notification that a data task has become a download task.  No
 * future messages will be sent to the data task.
 */
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask; {
  __BETInternalSessionTask * internalSessionTask = [session.bet_internalSession.mapTasks objectForKey:dataTask];
  [session.bet_internalSession.mapTasks setObject:internalSessionTask forKey:downloadTask];
  
  [self bet_delegateWithSession:session task:downloadTask selector:_cmd
                  sharedBefore:nil
                     taskBlock:^(__unused __BETInternalSession *internalSession, __BETInternalSessionTask *internalSessionTask, BOOL *stop) {
                        if(internalSessionTask.bet_taskBecomeDownloadTaskHandler) {
                          internalSessionTask.bet_taskBecomeDownloadTaskHandler(dataTask,downloadTask);
                          *stop = YES;
                        }
                      }
                   delegate:^(__BETInternalSession *internalSession, __unused __BETInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     [internalSession.bet_delegate URLSession:session dataTask:dataTask didBecomeDownloadTask:downloadTask];
                   }
                   internal:nil];

}



/* Sent when data is available for the delegate to consume.  It is
 * assumed that the delegate will retain and not copy the data.  As
 * the data may be discontiguous, you should use
 * [NSData enumerateByteRangesUsingtaskBlock:] to access it.
 */
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data; {

  
  [self bet_delegateWithSession:session task:dataTask selector:_cmd
               sharedBefore:^(__BETInternalSession *internalSession, __BETInternalSessionTask *internalSessionTask, BOOL *stop) {
                 internalSessionTask.bet_data = data;
                 
               }
                     taskBlock:^(__BETInternalSession *internalSession, __BETInternalSessionTask *internalSessionTask, BOOL *stop) {
                       if(internalSessionTask.bet_taskDidReceiveDataHandler) {
                         internalSessionTask.bet_taskDidReceiveDataHandler(dataTask,data);
                         *stop = YES;
                       }
                     }
                   delegate:^(__BETInternalSession *internalSession, __unused __BETInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     [internalSession.bet_delegate URLSession:session dataTask:dataTask didReceiveData:data];
                   }
                   internal:nil];

}

/* Invoke the completion routine with a valid NSCachedURLResponse to
 * allow the resulting data to be cached, or pass nil to prevent
 * caching. Note that there is no guarantee that caching will be
 * attempted for a given resource, and you should not rely on this
 * message to receive the resource data.
 */
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler; {

  [self bet_delegateWithSession:session task:dataTask selector:_cmd
               sharedBefore:nil
                      taskBlock:^(__unused __BETInternalSession *internalSession, __BETInternalSessionTask *internalSessionTask, BOOL *stop) {
                        if(internalSessionTask.bet_taskWillCacheResponseHandler) {
                          internalSessionTask.bet_taskWillCacheResponseHandler(dataTask,proposedResponse,completionHandler);
                          *stop = YES;
                        }
                      }
                   delegate:^(__BETInternalSession *internalSession, __unused __BETInternalSessionTask *internalSessionTask, BOOL *stop) {
                     [internalSession.bet_delegate URLSession:session dataTask:dataTask willCacheResponse:proposedResponse completionHandler:completionHandler];
                     *stop = YES;
                     
                   }
                   internal:^(__unused __BETInternalSession *internalSession, __unused __BETInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     completionHandler(proposedResponse);
                   }];
 
}


#pragma mark - <NSURLSessionDownloadDelegate>
/* Sent when a download task that has completed a download.  The delegate should
 * copy or move the file at the given location to a new location as it will be
 * removed when the delegate message returns. URLSession:task:didCompleteWithError: will
 * still be called.
 */


-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location; {
  
  [self bet_delegateWithSession:session task:downloadTask selector:_cmd
               sharedBefore:^(__BETInternalSession *internalSession, __BETInternalSessionTask *internalSessionTask, BOOL *stop) {
                 NSData * data = [NSData dataWithContentsOfURL:location];
                 internalSessionTask.bet_data = data;
                 internalSessionTask.bet_downloadLocation = location;

               }
                     taskBlock:^(__unused __BETInternalSession *internalSession, __BETInternalSessionTask *internalSessionTask, BOOL *stop) {
                        if(internalSessionTask.bet_taskDidFinishDownloadingToURLHandler) {
                          internalSessionTask.bet_taskDidFinishDownloadingToURLHandler(downloadTask,location);
                          *stop = YES;
                        }
                      }
                   delegate:^(__BETInternalSession *internalSession, __unused __BETInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     [internalSession.bet_delegate URLSession:session downloadTask:downloadTask didFinishDownloadingToURL:location];
                   }
                   internal:nil];

  
}

/* Sent periodically to notify the delegate of download progress. */
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite; {

  [self bet_delegateWithSession:session task:downloadTask selector:_cmd
               sharedBefore:nil
                      taskBlock:^(__unused __BETInternalSession *internalSession, __BETInternalSessionTask *internalSessionTask, BOOL *stop) {
                        if(internalSessionTask.bet_downloadProgressHandler) {
                          internalSessionTask.bet_downloadProgressHandler(downloadTask, (NSInteger)bytesWritten,(NSInteger)totalBytesWritten,(NSInteger)totalBytesExpectedToWrite);
                          *stop = YES;
                        }
                      }
                   delegate:^(__BETInternalSession *internalSession, __BETInternalSessionTask *internalSessionTask, BOOL *stop) {
                     [internalSession.bet_delegate URLSession:session task:downloadTask didSendBodyData:bytesWritten totalBytesSent:totalBytesWritten totalBytesExpectedToSend:totalBytesExpectedToWrite];
                   }
                   internal:nil];

}


/* Sent when a download has been resumed. If a download failed with an
 * error, the -userInfo dictionary of the error will contain an
 * NSURLSessionDownloadTaskResumeData key, whose value is the resume
 * data.
 */
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes; {
 
  [self bet_delegateWithSession:session task:downloadTask selector:_cmd
               sharedBefore:nil
                      taskBlock:^(__unused __BETInternalSession *internalSession, __BETInternalSessionTask *internalSessionTask, BOOL *stop) {
                        if(internalSessionTask.bet_taskDidResumeAtOffsetHandler) {
                          internalSessionTask.bet_taskDidResumeAtOffsetHandler(downloadTask, (NSInteger)fileOffset, (NSInteger)expectedTotalBytes);
                          *stop = YES;
                        }
                      }
                   delegate:^(__BETInternalSession *internalSession, __unused __BETInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     [internalSession.bet_delegate URLSession:session downloadTask:downloadTask didResumeAtOffset:fileOffset expectedTotalBytes:expectedTotalBytes];
                   }
                   internal:nil];

}
@end