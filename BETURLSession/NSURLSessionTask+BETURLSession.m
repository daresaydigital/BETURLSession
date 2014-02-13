

#import "NSURLSessionTask+BETURLSession.h"

#import "BETURLSessionAbstractSerializer.h"
#import "NSURLSession+BETURLSession.h"

#import "__BETInternalManager.h"
#import "__BETInternalShared.private"



//Use NSObject for implementation because NSURLSessionTask is exposing __NSFCURLSessionTask instead of the right class, causing unrecognized selectors exception

@implementation NSObject (BETURLSession)


-(NSError *)bet_parseRequestError; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(NSError *)bet_parseResponseError; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(NSError *)bet_error; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(NSData *)bet_data; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(NSURL*)bet_downloadLocation; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(id)bet_parsedObject; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(BETURLSessionTaskRequestDataCompletionBlock)bet_requestDataCompletion; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setRequestDataCompletion:(BETURLSessionTaskRequestDataCompletionBlock)theCompletion; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theCompletion];
}

-(BETURLSessionTaskRequestCompletionBlock)bet_requestCompletion; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setRequestCompletion:(BETURLSessionTaskRequestCompletionBlock)theCompletion; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theCompletion];
}

-(BETURLSessionTaskProgressHandlerBlock)bet_uploadProgressHandler; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setUploadProgressHandler:(BETURLSessionTaskProgressHandlerBlock)theHandler; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theHandler];
}

-(BETURLSessionTaskProgressHandlerBlock)bet_downloadProgressHandler; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setDownloadProgressHandler:(BETURLSessionTaskProgressHandlerBlock)theHandler; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theHandler];
}

#pragma mark - Privates
//Could always swizzle this for performance in the future or build a better map. 
-(__BETInternalSessionTask *)bet_internalSessionTask; {
  return [__BETInternalManager internalSessionTaskForURLSessionTask:(NSURLSessionTask *)self];
}

#pragma mark - <NSURLSessionTaskDelegate>

#pragma mark - taskWillPerformHTTPRedirection

-(BETURLSessionTaskRedirectHandlerBlock)bet_taskWillPerformHTTPRedirectionHandler; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setTaskWillPerformHTTPRedirectionHandler:(BETURLSessionTaskRedirectHandlerBlock)theHandler; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theHandler];
}


#pragma mark - taskDidReceiveChallenge

-(BETURLSessionTaskDidRecieveChallengeHandlerBlock)bet_taskDidReceiveChallengeHandler; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setTaskDidReceiveChallengeHandler:(BETURLSessionTaskDidRecieveChallengeHandlerBlock)theHandler; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theHandler];
}


#pragma mark - taskNeedNewBodyStream

-(BETURLSessionTaskNeedNewBodyStreamHandlerBlock)bet_taskNeedNewBodyStreamHandler; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setTaskNeedNewBodyStreamHandler:(BETURLSessionTaskNeedNewBodyStreamHandlerBlock)theHandler; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theHandler];
}


#pragma mark - taskDidCompleteWithError


-(BETURLSessionTaskDidCompleteWithErrorHandlerBlock)bet_taskDidCompleteWithErrorHandler; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setTaskDidCompleteWithErrorHandler:(BETURLSessionTaskDidCompleteWithErrorHandlerBlock)theHandler; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theHandler];
}



#pragma mark - <NSURLSessionDataDelegate>

#pragma mark - taskDidReceiveResponse
-(BETURLSessionTaskDidReceiveResponseHandlerBlock)bet_taskDidReceiveResponseHandler; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setTaskDidReceiveResponseHandler:(BETURLSessionTaskDidReceiveResponseHandlerBlock)theHandler; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theHandler];
}



#pragma mark - taskDidBecomeDownloadTask

-(BETURLSessionTaskDidBecomeDownloadTaskCompletionBlock)bet_taskBecomeDownloadTaskCompletion; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setTaskBecomeDownloadTaskCompletion:(BETURLSessionTaskDidBecomeDownloadTaskCompletionBlock)theCompletion; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theCompletion];
}


#pragma mark - taskDidReceiveData

-(BETURLSessionTaskDidReceiveDataCompletionBlock)bet_taskDidReceiveDataCompletion; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setTaskDidReceiveDataCompletion:(BETURLSessionTaskDidReceiveDataCompletionBlock)theCompletion; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theCompletion];
}



#pragma mark - taskWillCacheResponse

-(BETURLSessionTaskWillCacheResponseHandlerBlock)bet_taskWillCacheResponseHandler; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setTaskWillCacheResponseHandler:(BETURLSessionTaskWillCacheResponseHandlerBlock)theHandler; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theHandler];
}

#pragma mark - <NSURLSessionDownloadDelegate>


#pragma mark - taskDidFinishDownloadingToURL

-(BETURLSessionTaskDidFinishDownloadingToURLCompletion)bet_taskDidFinishDownloadingToURLCompletion; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setTaskDidFinishDownloadingToURLCompletion:(BETURLSessionTaskDidFinishDownloadingToURLCompletion)theCompletion; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theCompletion];
}


#pragma mark - taskDidResumeAtOffset

-(BETURLSessionTaskDidResumeAtOffsetHandler)bet_taskDidResumeAtOffsetHandler; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setTaskDidResumeAtOffsetHandler:(BETURLSessionTaskDidResumeAtOffsetHandler)theHandler; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theHandler];
}





@end
