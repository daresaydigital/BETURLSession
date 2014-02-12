

#import "BETURLSessionTaskSharedBlocks.h"

@interface NSURLSessionTask (BETURLSession)


@property(readonly) NSError * bet_parseRequestError;
@property(readonly) NSError * bet_parseResponseError;
@property(readonly) NSError * bet_error;
@property(readonly) NSData  * bet_data;
@property(readonly) NSURL   * bet_downloadLocation;

@property(readonly) id bet_parsedObject;


typedef void (^BETURLSessionTaskProgressBlock)(NSURLSessionTask * task,
                                              NSInteger  bytes,
                                              NSInteger  totalBytes,
                                              NSInteger  totalBytesExpected
                                              );

@property(readonly) BETURLSessionTaskRequestDataCompletionBlock bet_requestDataCompleteBlock;
-(void)bet_setRequestDataCompleteBlock:(BETURLSessionTaskRequestDataCompletionBlock)theBlock;

@property(readonly) BETURLSessionTaskRequestCompletionBlock bet_requestCompleteBlock;
-(void)bet_setRequestCompleteBlock:(BETURLSessionTaskRequestCompletionBlock)theBlock;


@property(readonly) BETURLSessionTaskProgressBlock bet_uploadProgressBlock;
-(void)bet_setUploadProgressBlock:(BETURLSessionTaskProgressBlock)theBlock;

@property(readonly) BETURLSessionTaskProgressBlock bet_downloadProgressBlock;
-(void)bet_setDownloadProgressBlock:(BETURLSessionTaskProgressBlock)theBlock;


#pragma mark - <NSURLSessionTaskDelegate>

#pragma mark - taskWillPerformHTTPRedirection
typedef void (^BETURLSessionTaskRedirectCompletionBlock)(NSURLRequest  * request);

typedef void (^BETURLSessionTaskRedirectBlock)(NSURLSessionTask * task,
                                              NSHTTPURLResponse * response,
                                              NSURLRequest      * request,
                                              BETURLSessionTaskRedirectCompletionBlock  completionBlock
                                              );

@property(readonly) BETURLSessionTaskRedirectBlock bet_taskWillPerformHTTPRedirectionBlock;
-(void)bet_setTaskWillPerfWormHTTPRedirectionBlock:(BETURLSessionTaskRedirectBlock)theBlock;


#pragma mark - taskDidReceiveChallenge
typedef void (^BETURLSessionTaskDidRecieveChallengeCompletionBlock)(NSURLSessionAuthChallengeDisposition disposition,
                                                                   NSURLCredential *credential
                                                                   );

typedef void (^BETURLSessionTaskDidRecieveChallengeBlock)(NSURLSessionTask * task,
                                                         NSURLAuthenticationChallenge * challenge,
                                                         BETURLSessionTaskDidRecieveChallengeCompletionBlock  completionBlock
                                                         );

@property(readonly) BETURLSessionTaskDidRecieveChallengeBlock bet_taskDidReceiveChallenge;
-(void)bet_setTaskDidReceiveChallenge:(BETURLSessionTaskDidRecieveChallengeBlock)theBlock;


#pragma mark - taskNeedNewBodyStream
typedef void (^BETURLSessionTaskNeedNewBodyStreamCompletionBlock)(NSInputStream *bodyStream);

typedef void (^BETURLSessionTaskNeedNewBodyStreamBlock)(NSURLSessionTask * task,
                                                       BETURLSessionTaskNeedNewBodyStreamCompletionBlock  completionBlock
                                                       );

@property(readonly) BETURLSessionTaskNeedNewBodyStreamBlock bet_taskNeedNewBodyStreamBlock;
-(void)bet_setTaskNeedNewBodyStreamBlock:(BETURLSessionTaskNeedNewBodyStreamBlock)theBlock;


#pragma mark - taskDidCompleteWithError


typedef void (^BETURLSessionTaskDidCompleteWithErrorBlock)(NSURLSessionTask * task,
                                                          NSError *  error
                                                          );

@property(readonly) BETURLSessionTaskDidCompleteWithErrorBlock bet_taskDidCompleteWithErrorBlock;
-(void)bet_setTaskDidCompleteWithErrorBlock:(BETURLSessionTaskDidCompleteWithErrorBlock)theBlock;



#pragma mark - <NSURLSessionDataDelegate>

#pragma mark - taskDidReceiveResponse
typedef void (^BETURLSessionTaskDidReceiveResponseCompletionBlock)(NSURLSessionResponseDisposition disposition);

typedef void (^BETURLSessionTaskDidReceiveResponseBlock)(NSURLSessionTask * task,
                                                        NSURLResponse * response,
                                                        BETURLSessionTaskDidReceiveResponseCompletionBlock  completionBlock
                                                        );

@property(readonly) BETURLSessionTaskDidReceiveResponseBlock bet_taskDidReceiveResponseBlock;
-(void)bet_setTaskDidReceiveResponseBlock:(BETURLSessionTaskDidReceiveResponseBlock)theBlock;



#pragma mark - taskDidBecomeDownloadTask
typedef void (^BETURLSessionTaskDidBecomeDownloadTaskBlock)(NSURLSessionTask * task,
                                                           NSURLSessionDownloadTask * downloadTask
                                                           );

@property(readonly) BETURLSessionTaskDidBecomeDownloadTaskBlock bet_taskBecomeDownloadTaskBlock;
-(void)bet_setTaskBecomeDownloadTaskBlock:(BETURLSessionTaskDidBecomeDownloadTaskBlock)theBlock;


#pragma mark - taskDidReceiveData
typedef void (^BETURLSessionTaskDidReceiveDataBlock)(NSURLSessionTask * task,
                                                           NSData * data
                                                           );

@property(readonly) BETURLSessionTaskDidReceiveDataBlock bet_taskDidReceiveDataBlock;
-(void)bet_setTaskDidReceiveDataBlock:(BETURLSessionTaskDidReceiveDataBlock)theBlock;



#pragma mark - taskWillCacheResponse
typedef void (^BETURLSessionTaskWillCacheResponseCompletionBlock)(NSCachedURLResponse * cachedResponse);

typedef void (^BETURLSessionTaskWillCacheResponseBlock)(NSURLSessionTask * task,
                                                       NSCachedURLResponse * proposedResponse,
                                                       BETURLSessionTaskWillCacheResponseCompletionBlock  completionBlock
                                                        );

@property(readonly) BETURLSessionTaskWillCacheResponseBlock bet_taskWillCacheResponseBlock;
-(void)bet_setTaskWillCacheResponseBlock:(BETURLSessionTaskWillCacheResponseBlock)theBlock;

#pragma mark - <NSURLSessionDownloadDelegate>


#pragma mark - taskDidFinishDownloadingToURL
typedef void (^BETURLSessionTaskDidFinishDownloadingToURLBlock)(NSURLSessionTask * task,
                                                               NSURL * location
                                                               );

@property(readonly) BETURLSessionTaskDidFinishDownloadingToURLBlock bet_taskDidFinishDownloadingToURLBlock;
-(void)bet_setTaskDidFinishDownloadingToURLBlock:(BETURLSessionTaskDidFinishDownloadingToURLBlock)theBlock;


#pragma mark - taskDidResumeAtOffset
typedef void (^BETURLSessionTaskDidResumeAtOffsetBlock)(NSURLSessionTask * task,
                                                       NSInteger  fileOffset,
                                                       NSInteger  expectedTotalBytes
                                                       );

@property(readonly) BETURLSessionTaskDidResumeAtOffsetBlock bet_taskDidResumeAtOffsetBlock;
-(void)bet_setTaskDidResumeAtOffsetBlock:(BETURLSessionTaskDidResumeAtOffsetBlock)theBlock;


@end
