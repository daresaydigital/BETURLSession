

#import "NSURLSessionTask+SIURLSessionBlocks.h"

#import "SIURLSessionBlocksSerializers.h"
#import "NSURLSession+SIURLSessionBlocks.h"

#import "SIInternalManager.h"
#include "SIInternalShared.private"



//Use NSObject for implementation because NSURLSessionTask is exposing __NSFCURLSessionTask instead of the right class, causing unrecognized selectors exception

@implementation NSObject (SIURLSessionBlocks)


-(NSError *)SI_parseRequestError; {
  return [self.SI_internalSessionTask SI_performSelector:_cmd];
}

-(NSError *)SI_parseResponseError; {
  return [self.SI_internalSessionTask SI_performSelector:_cmd];
}

-(NSError *)SI_error; {
  return [self.SI_internalSessionTask SI_performSelector:_cmd];
}

-(NSData *)SI_data; {
  return [self.SI_internalSessionTask SI_performSelector:_cmd];
}

-(NSURL*)SI_downloadLocation; {
  return [self.SI_internalSessionTask SI_performSelector:_cmd];
}

-(id)SI_parsedObject; {
  return [self.SI_internalSessionTask SI_performSelector:_cmd];
}
-(SIURLSessionTaskRequestDataCompleteBlock)SI_requestDataCompleteBlock; {
  return [self.SI_internalSessionTask SI_performSelector:_cmd];
}

-(void)SI_setRequestDataCompleteBlock:(SIURLSessionTaskRequestDataCompleteBlock)theBlock; {
  [self.SI_internalSessionTask SI_performSelector:_cmd withObject:theBlock];
}

-(SIURLSessionTaskRequestCompleteBlock)SI_requestCompleteBlock; {
  return [self.SI_internalSessionTask SI_performSelector:_cmd];
}

-(void)SI_setRequestCompleteBlock:(SIURLSessionTaskRequestCompleteBlock)theBlock; {
  [self.SI_internalSessionTask SI_performSelector:_cmd withObject:theBlock];
}

-(SIURLSessionTaskProgressBlock)SI_uploadProgressBlock; {
  return [self.SI_internalSessionTask SI_performSelector:_cmd];
}

-(void)SI_setUploadProgressBlock:(SIURLSessionTaskProgressBlock)theBlock; {
  [self.SI_internalSessionTask SI_performSelector:_cmd withObject:theBlock];
}

-(SIURLSessionTaskProgressBlock)SI_downloadProgressBlock; {
  return [self.SI_internalSessionTask SI_performSelector:_cmd];
}

-(void)SI_setDownloadProgressBlock:(SIURLSessionTaskProgressBlock)theBlock; {
  [self.SI_internalSessionTask SI_performSelector:_cmd withObject:theBlock];
}

#pragma mark - Privates
//Could always swizzle this for performance in the future or build a better map. 
-(SIInternalSessionTask *)SI_internalSessionTask; {
  return [SIInternalManager internalSessionTaskForURLSessionTask:(NSURLSessionTask *)self];
}

#pragma mark - <NSURLSessionTaskDelegate>

#pragma mark - taskWillPerformHTTPRedirection

-(SIURLSessionTaskRedirectBlock)SI_taskWillPerformHTTPRedirectionBlock; {
  return [self.SI_internalSessionTask SI_performSelector:_cmd];
}

-(void)SI_setTaskWillPerfWormHTTPRedirectionBlock:(SIURLSessionTaskRedirectBlock)theBlock; {
  [self.SI_internalSessionTask SI_performSelector:_cmd withObject:theBlock];
}


#pragma mark - taskDidReceiveChallenge

-(SIURLSessionTaskDidRecieveChallengeBlock)SI_taskDidReceiveChallenge; {
  return [self.SI_internalSessionTask SI_performSelector:_cmd];
}

-(void)SI_setTaskDidReceiveChallenge:(SIURLSessionTaskDidRecieveChallengeBlock)theBlock; {
  [self.SI_internalSessionTask SI_performSelector:_cmd withObject:theBlock];
}


#pragma mark - taskNeedNewBodyStream

-(SIURLSessionTaskNeedNewBodyStreamBlock)SI_taskNeedNewBodyStreamBlock; {
  return [self.SI_internalSessionTask SI_performSelector:_cmd];
}

-(void)SI_setTaskNeedNewBodyStreamBlock:(SIURLSessionTaskNeedNewBodyStreamBlock)theBlock; {
  [self.SI_internalSessionTask SI_performSelector:_cmd withObject:theBlock];
}


#pragma mark - taskDidCompleteWithError


-(SIURLSessionTaskDidCompleteWithErrorBlock)SI_taskDidCompleteWithErrorBlock; {
  return [self.SI_internalSessionTask SI_performSelector:_cmd];
}

-(void)SI_setTaskDidCompleteWithErrorBlock:(SIURLSessionTaskDidCompleteWithErrorBlock)theBlock; {
  [self.SI_internalSessionTask SI_performSelector:_cmd withObject:theBlock];
}



#pragma mark - <NSURLSessionDataDelegate>

#pragma mark - taskDidReceiveResponse
-(SIURLSessionTaskDidReceiveResponseBlock)SI_taskDidReceiveResponseBlock; {
  return [self.SI_internalSessionTask SI_performSelector:_cmd];
}

-(void)SI_setTaskDidReceiveResponseBlock:(SIURLSessionTaskDidReceiveResponseBlock)theBlock; {
  [self.SI_internalSessionTask SI_performSelector:_cmd withObject:theBlock];
}



#pragma mark - taskDidBecomeDownloadTask

-(SIURLSessionTaskDidBecomeDownloadTaskBlock)SI_taskBecomeDownloadTaskBlock; {
  return [self.SI_internalSessionTask SI_performSelector:_cmd];
}

-(void)SI_setTaskBecomeDownloadTaskBlock:(SIURLSessionTaskDidBecomeDownloadTaskBlock)theBlock; {
  [self.SI_internalSessionTask SI_performSelector:_cmd withObject:theBlock];
}


#pragma mark - taskDidReceiveData

-(SIURLSessionTaskDidReceiveDataBlock)SI_taskDidReceiveDataBlock; {
  return [self.SI_internalSessionTask SI_performSelector:_cmd];
}

-(void)SI_setTaskDidReceiveDataBlock:(SIURLSessionTaskDidReceiveDataBlock)theBlock; {
  [self.SI_internalSessionTask SI_performSelector:_cmd withObject:theBlock];
}



#pragma mark - taskWillCacheResponse

-(SIURLSessionTaskWillCacheResponseBlock)SI_taskWillCacheResponseBlock; {
  return [self.SI_internalSessionTask SI_performSelector:_cmd];
}

-(void)SI_setTaskWillCacheResponseBlock:(SIURLSessionTaskWillCacheResponseBlock)theBlock; {
  [self.SI_internalSessionTask SI_performSelector:_cmd withObject:theBlock];
}

#pragma mark - <NSURLSessionDownloadDelegate>


#pragma mark - taskDidFinishDownloadingToURL

-(SIURLSessionTaskDidFinishDownloadingToURLBlock)SI_taskDidFinishDownloadingToURLBlock; {
  return [self.SI_internalSessionTask SI_performSelector:_cmd];
}

-(void)SI_setTaskDidFinishDownloadingToURLBlock:(SIURLSessionTaskDidFinishDownloadingToURLBlock)theBlock; {
  [self.SI_internalSessionTask SI_performSelector:_cmd withObject:theBlock];
}


#pragma mark - taskDidResumeAtOffset

-(SIURLSessionTaskDidResumeAtOffsetBlock)SI_taskDidResumeAtOffsetBlock; {
  return [self.SI_internalSessionTask SI_performSelector:_cmd];
}

-(void)SI_setTaskDidResumeAtOffsetBlock:(SIURLSessionTaskDidResumeAtOffsetBlock)theBlock; {
  [self.SI_internalSessionTask SI_performSelector:_cmd withObject:theBlock];
}





@end
