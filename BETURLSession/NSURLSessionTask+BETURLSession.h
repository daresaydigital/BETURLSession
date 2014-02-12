

#import "BETURLSessionTaskSharedBlocks.h"

@interface NSURLSessionTask (BETURLSession)


@property(readonly) NSError * bet_parseRequestError;
@property(readonly) NSError * bet_parseResponseError;
@property(readonly) NSError * bet_error;
@property(readonly) NSData  * bet_data;
@property(readonly) NSURL   * bet_downloadLocation;

@property(readonly) id bet_parsedObject;


typedef void (^BETURLSessionTaskProgressHandlerBlock)(NSURLSessionTask * task,
                                              NSInteger  bytes,
                                              NSInteger  totalBytes,
                                              NSInteger  totalBytesExpected
                                              );

@property(readonly) BETURLSessionTaskRequestDataCompletionBlock bet_requestDataCompletion;
-(void)bet_setRequestDataCompletion:(BETURLSessionTaskRequestDataCompletionBlock)theCompletion;

@property(readonly) BETURLSessionTaskRequestCompletionBlock bet_requestCompletion;
-(void)bet_setRequestCompletion:(BETURLSessionTaskRequestCompletionBlock)theCompletion;


@property(readonly) BETURLSessionTaskProgressHandlerBlock bet_uploadProgressHandler;
-(void)bet_setUploadProgressHandler:(BETURLSessionTaskProgressHandlerBlock)theHandler;

@property(readonly) BETURLSessionTaskProgressHandlerBlock bet_downloadProgressHandler;
-(void)bet_setDownloadProgressHandler:(BETURLSessionTaskProgressHandlerBlock)theHandler;

#pragma mark - <NSURLSessionTaskDelegate>

#pragma mark - taskWillPerformHTTPRedirection
typedef void (^BETURLSessionTaskRedirectCompletionHandlerBlock)(NSURLRequest  * request);

typedef void (^BETURLSessionTaskRedirectHandlerBlock)(NSURLSessionTask * task,
                                              NSHTTPURLResponse * response,
                                              NSURLRequest      * request,
                                              BETURLSessionTaskRedirectCompletionHandlerBlock  completionHandler
                                              );

@property(readonly) BETURLSessionTaskRedirectHandlerBlock bet_taskWillPerformHTTPRedirectionHandler;
-(void)bet_setTaskWillPerformHTTPRedirectionHandler:(BETURLSessionTaskRedirectHandlerBlock)theHandler;


#pragma mark - taskDidReceiveChallenge
typedef void (^BETURLSessionTaskDidRecieveChallengeCompletionHandlerBlock)(NSURLSessionAuthChallengeDisposition disposition,
                                                                   NSURLCredential *credential
                                                                   );

typedef void (^BETURLSessionTaskDidRecieveChallengeHandlerBlock)(NSURLSessionTask * task,
                                                         NSURLAuthenticationChallenge * challenge,
                                                         BETURLSessionTaskDidRecieveChallengeCompletionHandlerBlock  completionHandler
                                                         );

@property(readonly) BETURLSessionTaskDidRecieveChallengeHandlerBlock bet_taskDidReceiveChallengeHandler;
-(void)bet_setTaskDidReceiveChallengeHandler:(BETURLSessionTaskDidRecieveChallengeHandlerBlock)theHandler;


#pragma mark - taskNeedNewBodyStream
typedef void (^BETURLSessionTaskNeedNewBodyStreamCompletionHandlerBlock)(NSInputStream *bodyStream);

typedef void (^BETURLSessionTaskNeedNewBodyStreamHandlerBlock)(NSURLSessionTask * task,
                                                       BETURLSessionTaskNeedNewBodyStreamCompletionHandlerBlock  completionHandler
                                                       );

@property(readonly) BETURLSessionTaskNeedNewBodyStreamHandlerBlock bet_taskNeedNewBodyStreamHandler;
-(void)bet_setTaskNeedNewBodyStreamHandler:(BETURLSessionTaskNeedNewBodyStreamHandlerBlock)theHandler;


#pragma mark - taskDidCompleteWithError


typedef void (^BETURLSessionTaskDidCompleteWithErrorHandlerBlock)(NSURLSessionTask * task,
                                                          NSError *  error
                                                          );

@property(readonly) BETURLSessionTaskDidCompleteWithErrorHandlerBlock bet_taskDidCompleteWithErrorHandler;
-(void)bet_setTaskDidCompleteWithErrorHandler:(BETURLSessionTaskDidCompleteWithErrorHandlerBlock)theHandler;



#pragma mark - <NSURLSessionDataDelegate>

#pragma mark - taskDidReceiveResponse
typedef void (^BETURLSessionTaskDidReceiveResponseCompletionHandlerBlock)(NSURLSessionResponseDisposition disposition);

typedef void (^BETURLSessionTaskDidReceiveResponseHandlerBlock)(NSURLSessionTask * task,
                                                        NSURLResponse * response,
                                                        BETURLSessionTaskDidReceiveResponseCompletionHandlerBlock  completionHandler
                                                        );

@property(readonly) BETURLSessionTaskDidReceiveResponseHandlerBlock bet_taskDidReceiveResponseHandler;
-(void)bet_setTaskDidReceiveResponseHandler:(BETURLSessionTaskDidReceiveResponseHandlerBlock)theHandler;



#pragma mark - taskDidBecomeDownloadTask
typedef void (^BETURLSessionTaskDidBecomeDownloadTaskCompletionBlock)(NSURLSessionTask * task,
                                                            NSURLSessionDownloadTask * downloadTask
                                                           );

@property(readonly) BETURLSessionTaskDidBecomeDownloadTaskCompletionBlock bet_taskBecomeDownloadTaskCompletion;
-(void)bet_setTaskBecomeDownloadTaskCompletion:(BETURLSessionTaskDidBecomeDownloadTaskCompletionBlock)theCompletion;


#pragma mark - taskDidReceiveData
typedef void (^BETURLSessionTaskDidReceiveDataCompletionBlock)(NSURLSessionTask * task,
                                                           NSData * data
                                                           );

@property(readonly) BETURLSessionTaskDidReceiveDataCompletionBlock bet_taskDidReceiveDataCompletion;
-(void)bet_setTaskDidReceiveDataCompletion:(BETURLSessionTaskDidReceiveDataCompletionBlock)theCompletion;



#pragma mark - taskWillCacheResponse
typedef void (^BETURLSessionTaskWillCacheResponseCompletionHandlerBlock)(NSCachedURLResponse * cachedResponse);

typedef void (^BETURLSessionTaskWillCacheResponseHandlerBlock)(NSURLSessionTask * task,
                                                       NSCachedURLResponse * proposedResponse,
                                                       BETURLSessionTaskWillCacheResponseCompletionHandlerBlock  completionHandler
                                                        );

@property(readonly) BETURLSessionTaskWillCacheResponseHandlerBlock bet_taskWillCacheResponseHandler;
-(void)bet_setTaskWillCacheResponseHandler:(BETURLSessionTaskWillCacheResponseHandlerBlock)theHandler;

#pragma mark - <NSURLSessionDownloadDelegate>

#pragma mark - taskDidFinishDownloadingToURL
typedef void (^BETURLSessionTaskDidFinishDownloadingToURLCompletion)(NSURLSessionTask * task,
                                                                     NSURL * location
                                                                     );

@property(readonly) BETURLSessionTaskDidFinishDownloadingToURLCompletion bet_taskDidFinishDownloadingToURLCompletion;
-(void)bet_setTaskDidFinishDownloadingToURLCompletion:(BETURLSessionTaskDidFinishDownloadingToURLCompletion)theCompletion;


#pragma mark - taskDidResumeAtOffset
typedef void (^BETURLSessionTaskDidResumeAtOffsetHandler)(NSURLSessionTask * task,
                                                          NSInteger  fileOffset,
                                                          NSInteger  expectedTotalBytes
                                                       );

@property(readonly) BETURLSessionTaskDidResumeAtOffsetHandler bet_taskDidResumeAtOffsetHandler;
-(void)bet_setTaskDidResumeAtOffsetHandler:(BETURLSessionTaskDidResumeAtOffsetHandler)theHandler;


@end
