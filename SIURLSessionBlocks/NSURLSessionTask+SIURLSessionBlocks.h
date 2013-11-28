

#import "SIURLSessionTaskSharedBlocks.h"

@interface NSURLSessionTask (SIURLSessionBlocks)


@property(readonly) NSError * SI_parseRequestError;
@property(readonly) NSError * SI_parseResponseError;
@property(readonly) NSError * SI_error;
@property(readonly) NSData  * SI_data;
@property(readonly) NSURL   * SI_downloadLocation;

@property(readonly) id SI_parsedObject;


typedef void (^SIURLSessionTaskProgressBlock)(NSURLSessionTask * task,
                                              NSInteger  bytes,
                                              NSInteger  totalBytes,
                                              NSInteger  totalBytesExpected
                                              );

@property(readonly) SIURLSessionTaskRequestDataCompleteBlock SI_requestDataCompleteBlock;
-(void)SI_setRequestDataCompleteBlock:(SIURLSessionTaskRequestDataCompleteBlock)theBlock;

@property(readonly) SIURLSessionTaskRequestCompleteBlock SI_requestCompleteBlock;
-(void)SI_setRequestCompleteBlock:(SIURLSessionTaskRequestCompleteBlock)theBlock;


@property(readonly) SIURLSessionTaskProgressBlock SI_uploadProgressBlock;
-(void)SI_setUploadProgressBlock:(SIURLSessionTaskProgressBlock)theBlock;

@property(readonly) SIURLSessionTaskProgressBlock SI_downloadProgressBlock;
-(void)SI_setDownloadProgressBlock:(SIURLSessionTaskProgressBlock)theBlock;


#pragma mark - <NSURLSessionTaskDelegate>

#pragma mark - taskWillPerformHTTPRedirection
typedef void (^SIURLSessionTaskRedirectCompletionBlock)(NSURLRequest  * request);

typedef void (^SIURLSessionTaskRedirectBlock)(NSURLSessionTask * task,
                                              NSHTTPURLResponse * response,
                                              NSURLRequest      * request,
                                              SIURLSessionTaskRedirectCompletionBlock  completionBlock
                                              );

@property(readonly) SIURLSessionTaskRedirectBlock SI_taskWillPerformHTTPRedirectionBlock;
-(void)SI_setTaskWillPerfWormHTTPRedirectionBlock:(SIURLSessionTaskRedirectBlock)theBlock;


#pragma mark - taskDidReceiveChallenge
typedef void (^SIURLSessionTaskDidRecieveChallengeCompletionBlock)(NSURLSessionAuthChallengeDisposition disposition,
                                                                   NSURLCredential *credential
                                                                   );

typedef void (^SIURLSessionTaskDidRecieveChallengeBlock)(NSURLSessionTask * task,
                                                         NSURLAuthenticationChallenge * challenge,
                                                         SIURLSessionTaskDidRecieveChallengeCompletionBlock  completionBlock
                                                         );

@property(readonly) SIURLSessionTaskDidRecieveChallengeBlock SI_taskDidReceiveChallenge;
-(void)SI_setTaskDidReceiveChallenge:(SIURLSessionTaskDidRecieveChallengeBlock)theBlock;


#pragma mark - taskNeedNewBodyStream
typedef void (^SIURLSessionTaskNeedNewBodyStreamCompletionBlock)(NSInputStream *bodyStream);

typedef void (^SIURLSessionTaskNeedNewBodyStreamBlock)(NSURLSessionTask * task,
                                                       SIURLSessionTaskNeedNewBodyStreamCompletionBlock  completionBlock
                                                       );

@property(readonly) SIURLSessionTaskNeedNewBodyStreamBlock SI_taskNeedNewBodyStreamBlock;
-(void)SI_setTaskNeedNewBodyStreamBlock:(SIURLSessionTaskNeedNewBodyStreamBlock)theBlock;


#pragma mark - taskDidCompleteWithError


typedef void (^SIURLSessionTaskDidCompleteWithErrorBlock)(NSURLSessionTask * task,
                                                          NSError *  error
                                                          );

@property(readonly) SIURLSessionTaskDidCompleteWithErrorBlock SI_taskDidCompleteWithErrorBlock;
-(void)SI_setTaskDidCompleteWithErrorBlock:(SIURLSessionTaskDidCompleteWithErrorBlock)theBlock;



#pragma mark - <NSURLSessionDataDelegate>

#pragma mark - taskDidReceiveResponse
typedef void (^SIURLSessionTaskDidReceiveResponseCompletionBlock)(NSURLSessionResponseDisposition disposition);

typedef void (^SIURLSessionTaskDidReceiveResponseBlock)(NSURLSessionTask * task,
                                                        NSURLResponse * response,
                                                        SIURLSessionTaskDidReceiveResponseCompletionBlock  completionBlock
                                                        );

@property(readonly) SIURLSessionTaskDidReceiveResponseBlock SI_taskDidReceiveResponseBlock;
-(void)SI_setTaskDidReceiveResponseBlock:(SIURLSessionTaskDidReceiveResponseBlock)theBlock;



#pragma mark - taskDidBecomeDownloadTask
typedef void (^SIURLSessionTaskDidBecomeDownloadTaskBlock)(NSURLSessionTask * task,
                                                           NSURLSessionDownloadTask * downloadTask
                                                           );

@property(readonly) SIURLSessionTaskDidBecomeDownloadTaskBlock SI_taskBecomeDownloadTaskBlock;
-(void)SI_setTaskBecomeDownloadTaskBlock:(SIURLSessionTaskDidBecomeDownloadTaskBlock)theBlock;


#pragma mark - taskDidReceiveData
typedef void (^SIURLSessionTaskDidReceiveDataBlock)(NSURLSessionTask * task,
                                                           NSData * data
                                                           );

@property(readonly) SIURLSessionTaskDidReceiveDataBlock SI_taskDidReceiveDataBlock;
-(void)SI_setTaskDidReceiveDataBlock:(SIURLSessionTaskDidReceiveDataBlock)theBlock;



#pragma mark - taskWillCacheResponse
typedef void (^SIURLSessionTaskWillCacheResponseCompletionBlock)(NSCachedURLResponse * cachedResponse);

typedef void (^SIURLSessionTaskWillCacheResponseBlock)(NSURLSessionTask * task,
                                                       NSCachedURLResponse * proposedResponse,
                                                       SIURLSessionTaskWillCacheResponseCompletionBlock  completionBlock
                                                        );

@property(readonly) SIURLSessionTaskWillCacheResponseBlock SI_taskWillCacheResponseBlock;
-(void)SI_setTaskWillCacheResponseBlock:(SIURLSessionTaskWillCacheResponseBlock)theBlock;

#pragma mark - <NSURLSessionDownloadDelegate>


#pragma mark - taskDidFinishDownloadingToURL
typedef void (^SIURLSessionTaskDidFinishDownloadingToURLBlock)(NSURLSessionTask * task,
                                                               NSURL * location
                                                               );

@property(readonly) SIURLSessionTaskDidFinishDownloadingToURLBlock SI_taskDidFinishDownloadingToURLBlock;
-(void)SI_setTaskDidFinishDownloadingToURLBlock:(SIURLSessionTaskDidFinishDownloadingToURLBlock)theBlock;


#pragma mark - taskDidResumeAtOffset
typedef void (^SIURLSessionTaskDidResumeAtOffsetBlock)(NSURLSessionTask * task,
                                                       NSInteger  fileOffset,
                                                       NSInteger  expectedTotalBytes
                                                       );

@property(readonly) SIURLSessionTaskDidResumeAtOffsetBlock SI_taskDidResumeAtOffsetBlock;
-(void)SI_setTaskDidResumeAtOffsetBlock:(SIURLSessionTaskDidResumeAtOffsetBlock)theBlock;


@end
