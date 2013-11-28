
#import "SIInternalManager+Delegate.h"
#import "SIURLSessionBlocks.h"
#include "SIInternalShared.private"

@interface NSURLSession (Privates)
typedef void (^SIDogmaPerformerBlock)(SIInternalSession * internalSession, SIInternalSessionTask * internalSessionTask, BOOL *stop);

-(void)SI_delegateWithSession:(NSURLSession *)theSession
                         task:(NSURLSessionTask *)theTask
                  selector:(SEL)theSelector
                    sharedBefore:(SIDogmaPerformerBlock)theSharedBeforeBlock
                     taskBlock:(SIDogmaPerformerBlock)theTaskBlock
                  delegate:(SIDogmaPerformerBlock)theDelegateBlock
                  internal:(SIDogmaPerformerBlock)theInternalBlock;

@end

@implementation NSObject (Privates)

-(void)SI_delegateWithSession:(NSURLSession *)theSession
                         task:(NSURLSessionTask *)theTask
                  selector:(SEL)theSelector
                    sharedBefore:(SIDogmaPerformerBlock)theSharedBeforeBlock
                     taskBlock:(SIDogmaPerformerBlock)theTaskBlock
                  delegate:(SIDogmaPerformerBlock)theDelegateBlock
                  internal:(SIDogmaPerformerBlock)theInternalBlock; {
  

  NSParameterAssert(theSelector);


  SIInternalSession * internalSession = theSession.SI_internalSession;
  SIInternalSessionTask * internalSessionTask = nil;

  #warning fetching from map
  if(theTask) internalSessionTask = [internalSession.mapTasks objectForKey:theTask];
//  internalSessionTask = theTask.SI_internalSessionTask;
  
  if(theSharedBeforeBlock)theSharedBeforeBlock(internalSession,internalSessionTask, NO);
  BOOL shouldStopHere = NO;
  if(shouldStopHere == NO && theTaskBlock)
    theTaskBlock(internalSession, internalSessionTask, &shouldStopHere);
  
  if(shouldStopHere == NO && theDelegateBlock && internalSession.SI_delegate && [internalSession.SI_delegate respondsToSelector:theSelector])
    theDelegateBlock(internalSession, internalSessionTask, &shouldStopHere);

  if(shouldStopHere == NO && theInternalBlock)
    theInternalBlock(internalSession, internalSessionTask, &shouldStopHere);
}

@end


@implementation SIInternalManager (Delegate)


#pragma mark - <NSURLSessionDelegate>

/* The last message a session receives.  A session will only become
 * invalid because of a systemic error or when it has been
 * explicitly invalidated, in which case it will receive an
 * { NSURLErrorDomain, NSURLUserCanceled } error.
 */
-(void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error; {

  [self SI_delegateWithSession:session task:nil selector:_cmd
               sharedBefore:nil
                      taskBlock:nil
                   delegate:^void(SIInternalSession *internalSession, __unused SIInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     [internalSession.SI_delegate URLSession:session didBecomeInvalidWithError:error];
                   }
                   internal:^void(__unused SIInternalSession *internalSession, __unused SIInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     [[[SIInternalManager sharedManager] mapSessions] removeObjectForKey:session];
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
  [self SI_delegateWithSession:session task:nil selector:_cmd
               sharedBefore:nil
                      taskBlock:nil
                   delegate:^void(SIInternalSession *internalSession, __unused SIInternalSessionTask *internalSessionTask, BOOL *stop) {
                     [internalSession.SI_delegate URLSession:session didReceiveChallenge:challenge completionHandler:completionHandler];
                     *stop = YES;
                     
                   }
                   internal:^void(__unused SIInternalSession *internalSession, __unused SIInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
                   }];

}

/* If an application has received an
 * -application:handleEventsForBackgroundURLSession:completionHandler:
 * message, the session delegate will receive this message to indicate
 * that all messages previously enqueued for this session have been
 * delivered.  At this time it is safe to invoke the previously stored
 * completion handler, or to begin any internal updates that will
 * result in invoking the completion handler.
 */
-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session NS_AVAILABLE_IOS(7_0); {

  [self SI_delegateWithSession:session task:nil selector:_cmd
               sharedBefore:nil
                      taskBlock:nil
                   delegate:^void(SIInternalSession *internalSession, __unused SIInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     [internalSession.SI_delegate URLSessionDidFinishEventsForBackgroundURLSession:session];
                   }
                   internal:nil];
  
}

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
  
  [self SI_delegateWithSession:session task:task selector:_cmd
               sharedBefore:nil
                      taskBlock:^void(SIInternalSession *internalSession, SIInternalSessionTask *internalSessionTask, BOOL *stop) {
                        if(internalSessionTask.SI_taskWillPerformHTTPRedirectionBlock) {
                          internalSessionTask.SI_taskWillPerformHTTPRedirectionBlock(task,response,request,completionHandler);
                          *stop = YES;
                        }
                      }
                   delegate:^void(SIInternalSession *internalSession, SIInternalSessionTask *internalSessionTask, BOOL *stop) {
                     [internalSession.SI_delegate URLSession:session task:task willPerformHTTPRedirection:response newRequest:request completionHandler:completionHandler];
                     *stop = YES;
                   }
                   internal:^void(__unused SIInternalSession *internalSession, __unused SIInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
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
  
  [self SI_delegateWithSession:session task:task selector:_cmd
                  sharedBefore:nil
                      taskBlock:^(__unused SIInternalSession *internalSession, SIInternalSessionTask *internalSessionTask, BOOL *stop) {
                        if(internalSessionTask.SI_taskDidReceiveChallenge) {
                          internalSessionTask.SI_taskDidReceiveChallenge(task, challenge, completionHandler);
                          *stop = YES;
                        }
                      }
                   delegate:^(SIInternalSession *internalSession, __unused SIInternalSessionTask *internalSessionTask, BOOL *stop) {
                     [internalSession.SI_delegate URLSession:session task:task didReceiveChallenge:challenge completionHandler:completionHandler];
                     *stop = YES;
                   }
                   internal:^(__unused SIInternalSession *internalSession, __unused SIInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
                   }];
  
}

/* Sent if a task requires a new, unopened body stream.  This may be
 * necessary when authentication has failed for any request that
 * involves a body stream.
 */
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler; {
  
  [self SI_delegateWithSession:session task:task selector:_cmd
               sharedBefore:nil
                      taskBlock:^(__unused SIInternalSession *internalSession, SIInternalSessionTask *internalSessionTask, BOOL *stop) {
                        if(internalSessionTask.SI_taskNeedNewBodyStreamBlock) {
                          internalSessionTask.SI_taskNeedNewBodyStreamBlock(task, completionHandler);
                          *stop = YES;
                        }
                      }
                   delegate:^(SIInternalSession *internalSession, __unused SIInternalSessionTask *internalSessionTask, BOOL *stop) {
                     [internalSession.SI_delegate URLSession:session task:task needNewBodyStream:completionHandler];
                     *stop = YES;
                   }
                   internal:^(__unused SIInternalSession *internalSession, __unused SIInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
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
  
  [self SI_delegateWithSession:session task:task selector:_cmd
               sharedBefore:nil
                      taskBlock:^(__unused SIInternalSession *internalSession, SIInternalSessionTask *internalSessionTask, BOOL *stop) {
                        if(internalSessionTask.SI_uploadProgressBlock) {
                          internalSessionTask.SI_uploadProgressBlock(task, (NSInteger)bytesSent,(NSInteger)totalBytesSent,(NSInteger)totalBytesExpectedToSend);
                          *stop = YES;
                        }
                      }
                   delegate:^(SIInternalSession *internalSession, __unused SIInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     [internalSession.SI_delegate URLSession:session task:task didSendBodyData:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
                   }
                   internal:nil];

}


/* Sent as the last message related to a specific task.  Error may be
 * nil, which implies that no error occurred and this task is complete.
 */
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error; {
  
  [self SI_delegateWithSession:session task:task selector:_cmd
               sharedBefore:^(SIInternalSession *internalSession, SIInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                  if(internalSession.SI_taskWillEndRequestBlock) internalSession.SI_taskWillEndRequestBlock(task,error);

                 internalSessionTask.SI_error = error;
                 if(internalSessionTask.SI_requestCompleteBlock) {
                   SIURLSessionResponseSerializerAbstract<SIURLSessionResponseSerializing> * serializer = session.SI_serializerForResponse;
                   if(serializer == nil) serializer = session.SI_internalSession.SI_serializerForResponse;

                   NSParameterAssert(serializer);
                   [serializer buildObjectForResponse:task.response responseData:internalSessionTask.SI_data onCompletion:^(id obj, NSError *responseError) {
                     internalSessionTask.SI_parseResponseError = responseError;
                     if(internalSessionTask.SI_error == nil) internalSessionTask.SI_error = internalSessionTask.SI_parseResponseError;
                     if(internalSessionTask.SI_error == nil) internalSessionTask.SI_error = internalSessionTask.SI_parseRequestError;
                     if(internalSessionTask.SI_error == nil) internalSessionTask.SI_error = error;
                     
                     internalSessionTask.SI_parsedObject = obj;
                     internalSessionTask.SI_requestCompleteBlock(internalSessionTask.SI_error,
                                                                 obj,
                                                                 (NSHTTPURLResponse *)task.response,
                                                                 task);

                   }];


                 }
                 if(internalSessionTask.SI_requestDataCompleteBlock) {
                   internalSessionTask.SI_requestDataCompleteBlock(internalSessionTask.SI_error,
                                                                   internalSessionTask.SI_downloadLocation,
                                                                   internalSessionTask.SI_data,
                                                               (NSHTTPURLResponse *)task.response,
                                                               task);
                   
                 }


               }
                     taskBlock:^(__unused SIInternalSession *internalSession, SIInternalSessionTask *internalSessionTask, BOOL *stop) {
                       if(internalSessionTask.SI_taskDidCompleteWithErrorBlock){
                         internalSessionTask.SI_taskDidCompleteWithErrorBlock(task, error);
                         *stop = YES;
                       }

                      }
                   delegate:^(SIInternalSession *internalSession, __unused SIInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     [internalSession.SI_delegate URLSession:session task:task didCompleteWithError:error];
                   }
                   internal:^(SIInternalSession *internalSession, SIInternalSessionTask *internalSessionTask, BOOL *stop) {
                     if(internalSession.SI_taskDidEndRequestBlock) internalSession.SI_taskDidEndRequestBlock(task,error);
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
  
  [self SI_delegateWithSession:session task:dataTask selector:_cmd
               sharedBefore:^(SIInternalSession *internalSession, SIInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                 if(internalSession.SI_taskDidRequestBlock) internalSession.SI_taskDidRequestBlock(dataTask, nil);
               }
                     taskBlock:^(__unused SIInternalSession *internalSession, SIInternalSessionTask *internalSessionTask, BOOL *stop) {
                        if(internalSessionTask.SI_taskDidReceiveResponseBlock) {
                          internalSessionTask.SI_taskDidReceiveResponseBlock(dataTask,response,completionHandler);
                          *stop = YES;
                        }
                      }
                   delegate:^(SIInternalSession *internalSession, __unused SIInternalSessionTask *internalSessionTask, BOOL *stop) {
                     [internalSession.SI_delegate URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
                     *stop = YES;
                   }
                   internal:^(__unused SIInternalSession *internalSession, __unused SIInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     completionHandler(NSURLSessionResponseBecomeDownload);
                   }];

  
}

/* Notification that a data task has become a download task.  No
 * future messages will be sent to the data task.
 */
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask; {
  SIInternalSessionTask * internalSessionTask = [session.SI_internalSession.mapTasks objectForKey:dataTask];
  [session.SI_internalSession.mapTasks setObject:internalSessionTask forKey:downloadTask];
  
  [self SI_delegateWithSession:session task:downloadTask selector:_cmd
                  sharedBefore:nil
                     taskBlock:^(__unused SIInternalSession *internalSession, SIInternalSessionTask *internalSessionTask, BOOL *stop) {
                        if(internalSessionTask.SI_taskBecomeDownloadTaskBlock) {
                          internalSessionTask.SI_taskBecomeDownloadTaskBlock(dataTask,downloadTask);
                          *stop = YES;
                        }
                      }
                   delegate:^(SIInternalSession *internalSession, __unused SIInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     [internalSession.SI_delegate URLSession:session dataTask:dataTask didBecomeDownloadTask:downloadTask];
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

  
  [self SI_delegateWithSession:session task:dataTask selector:_cmd
               sharedBefore:^(SIInternalSession *internalSession, SIInternalSessionTask *internalSessionTask, BOOL *stop) {
                 internalSessionTask.SI_data = data;
                 
               }
                     taskBlock:^(SIInternalSession *internalSession, SIInternalSessionTask *internalSessionTask, BOOL *stop) {
                       if(internalSessionTask.SI_taskDidReceiveDataBlock) {
                         internalSessionTask.SI_taskDidReceiveDataBlock(dataTask,data);
                         *stop = YES;
                       }
                     }
                   delegate:^(SIInternalSession *internalSession, __unused SIInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     [internalSession.SI_delegate URLSession:session dataTask:dataTask didReceiveData:data];
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

  [self SI_delegateWithSession:session task:dataTask selector:_cmd
               sharedBefore:nil
                      taskBlock:^(__unused SIInternalSession *internalSession, SIInternalSessionTask *internalSessionTask, BOOL *stop) {
                        if(internalSessionTask.SI_taskWillCacheResponseBlock) {
                          internalSessionTask.SI_taskWillCacheResponseBlock(dataTask,proposedResponse,completionHandler);
                          *stop = YES;
                        }
                      }
                   delegate:^(SIInternalSession *internalSession, __unused SIInternalSessionTask *internalSessionTask, BOOL *stop) {
                     [internalSession.SI_delegate URLSession:session dataTask:dataTask willCacheResponse:proposedResponse completionHandler:completionHandler];
                     *stop = YES;
                     
                   }
                   internal:^(__unused SIInternalSession *internalSession, __unused SIInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
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
  
  [self SI_delegateWithSession:session task:downloadTask selector:_cmd
               sharedBefore:^(SIInternalSession *internalSession, SIInternalSessionTask *internalSessionTask, BOOL *stop) {
                 NSData * data = [NSData dataWithContentsOfURL:location];
                 internalSessionTask.SI_data = data;
                 internalSessionTask.SI_downloadLocation = location;

               }
                     taskBlock:^(__unused SIInternalSession *internalSession, SIInternalSessionTask *internalSessionTask, BOOL *stop) {
                        if(internalSessionTask.SI_taskDidFinishDownloadingToURLBlock) {
                          internalSessionTask.SI_taskDidFinishDownloadingToURLBlock(downloadTask,location);
                          *stop = YES;
                        }
                      }
                   delegate:^(SIInternalSession *internalSession, __unused SIInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     [internalSession.SI_delegate URLSession:session downloadTask:downloadTask didFinishDownloadingToURL:location];
                   }
                   internal:nil];

  
}

/* Sent periodically to notify the delegate of download progress. */
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite; {

  [self SI_delegateWithSession:session task:downloadTask selector:_cmd
               sharedBefore:nil
                      taskBlock:^(__unused SIInternalSession *internalSession, SIInternalSessionTask *internalSessionTask, BOOL *stop) {
                        if(internalSessionTask.SI_downloadProgressBlock) {
                          internalSessionTask.SI_downloadProgressBlock(downloadTask, (NSInteger)bytesWritten,(NSInteger)totalBytesWritten,(NSInteger)totalBytesExpectedToWrite);
                          *stop = YES;
                        }
                      }
                   delegate:^(SIInternalSession *internalSession, SIInternalSessionTask *internalSessionTask, BOOL *stop) {
                     [internalSession.SI_delegate URLSession:session task:downloadTask didSendBodyData:bytesWritten totalBytesSent:totalBytesWritten totalBytesExpectedToSend:totalBytesExpectedToWrite];
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
 
  [self SI_delegateWithSession:session task:downloadTask selector:_cmd
               sharedBefore:nil
                      taskBlock:^(__unused SIInternalSession *internalSession, SIInternalSessionTask *internalSessionTask, BOOL *stop) {
                        if(internalSessionTask.SI_taskDidResumeAtOffsetBlock) {
                          internalSessionTask.SI_taskDidResumeAtOffsetBlock(downloadTask, (NSInteger)fileOffset, (NSInteger)expectedTotalBytes);
                          *stop = YES;
                        }
                      }
                   delegate:^(SIInternalSession *internalSession, __unused SIInternalSessionTask *internalSessionTask, __unused BOOL *stop) {
                     [internalSession.SI_delegate URLSession:session downloadTask:downloadTask didResumeAtOffset:fileOffset expectedTotalBytes:expectedTotalBytes];
                   }
                   internal:nil];

}
@end