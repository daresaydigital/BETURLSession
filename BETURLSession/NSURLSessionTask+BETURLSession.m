

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

-(BETURLSessionTaskRequestDataCompletionBlock)bet_requestDataCompleteBlock; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setRequestDataCompleteBlock:(BETURLSessionTaskRequestDataCompletionBlock)theBlock; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theBlock];
}

-(BETURLSessionTaskRequestCompletionBlock)bet_requestCompleteBlock; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setRequestCompleteBlock:(BETURLSessionTaskRequestCompletionBlock)theBlock; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theBlock];
}

-(BETURLSessionTaskProgressBlock)bet_uploadProgressBlock; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setUploadProgressBlock:(BETURLSessionTaskProgressBlock)theBlock; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theBlock];
}

-(BETURLSessionTaskProgressBlock)bet_downloadProgressBlock; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setDownloadProgressBlock:(BETURLSessionTaskProgressBlock)theBlock; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theBlock];
}

#pragma mark - Privates
//Could always swizzle this for performance in the future or build a better map. 
-(__BETInternalSessionTask *)bet_internalSessionTask; {
  return [__BETInternalManager internalSessionTaskForURLSessionTask:(NSURLSessionTask *)self];
}

#pragma mark - <NSURLSessionTaskDelegate>

#pragma mark - taskWillPerformHTTPRedirection

-(BETURLSessionTaskRedirectBlock)bet_taskWillPerformHTTPRedirectionBlock; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setTaskWillPerfWormHTTPRedirectionBlock:(BETURLSessionTaskRedirectBlock)theBlock; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theBlock];
}


#pragma mark - taskDidReceiveChallenge

-(BETURLSessionTaskDidRecieveChallengeBlock)bet_taskDidReceiveChallenge; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setTaskDidReceiveChallenge:(BETURLSessionTaskDidRecieveChallengeBlock)theBlock; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theBlock];
}


#pragma mark - taskNeedNewBodyStream

-(BETURLSessionTaskNeedNewBodyStreamBlock)bet_taskNeedNewBodyStreamBlock; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setTaskNeedNewBodyStreamBlock:(BETURLSessionTaskNeedNewBodyStreamBlock)theBlock; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theBlock];
}


#pragma mark - taskDidCompleteWithError


-(BETURLSessionTaskDidCompleteWithErrorBlock)bet_taskDidCompleteWithErrorBlock; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setTaskDidCompleteWithErrorBlock:(BETURLSessionTaskDidCompleteWithErrorBlock)theBlock; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theBlock];
}



#pragma mark - <NSURLSessionDataDelegate>

#pragma mark - taskDidReceiveResponse
-(BETURLSessionTaskDidReceiveResponseBlock)bet_taskDidReceiveResponseBlock; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setTaskDidReceiveResponseBlock:(BETURLSessionTaskDidReceiveResponseBlock)theBlock; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theBlock];
}



#pragma mark - taskDidBecomeDownloadTask

-(BETURLSessionTaskDidBecomeDownloadTaskBlock)bet_taskBecomeDownloadTaskBlock; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setTaskBecomeDownloadTaskBlock:(BETURLSessionTaskDidBecomeDownloadTaskBlock)theBlock; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theBlock];
}


#pragma mark - taskDidReceiveData

-(BETURLSessionTaskDidReceiveDataBlock)bet_taskDidReceiveDataBlock; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setTaskDidReceiveDataBlock:(BETURLSessionTaskDidReceiveDataBlock)theBlock; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theBlock];
}



#pragma mark - taskWillCacheResponse

-(BETURLSessionTaskWillCacheResponseBlock)bet_taskWillCacheResponseBlock; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setTaskWillCacheResponseBlock:(BETURLSessionTaskWillCacheResponseBlock)theBlock; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theBlock];
}

#pragma mark - <NSURLSessionDownloadDelegate>


#pragma mark - taskDidFinishDownloadingToURL

-(BETURLSessionTaskDidFinishDownloadingToURLBlock)bet_taskDidFinishDownloadingToURLBlock; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setTaskDidFinishDownloadingToURLBlock:(BETURLSessionTaskDidFinishDownloadingToURLBlock)theBlock; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theBlock];
}


#pragma mark - taskDidResumeAtOffset

-(BETURLSessionTaskDidResumeAtOffsetBlock)bet_taskDidResumeAtOffsetBlock; {
  return [self.bet_internalSessionTask bet_performSelector:_cmd];
}

-(void)bet_setTaskDidResumeAtOffsetBlock:(BETURLSessionTaskDidResumeAtOffsetBlock)theBlock; {
  [self.bet_internalSessionTask bet_performSelector:_cmd withObject:theBlock];
}





@end
