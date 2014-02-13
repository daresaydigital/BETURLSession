//
//  BETNotworking.h
//  BETNotworking
//
//  Created by Seivan Heidari on 2013-10-29.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//



#import "BETURLSessionTaskSharedBlocks.h"

@class BETURLSessionRequestSerializer;
@class BETURLSessionResponseSerializer;

@interface NSURLSession (BETURLSession)


#pragma mark - Properties
//Yes, strong until the session is invalidated, then it's set to nil.

@property(readonly) NSString    * bet_sessionName;
@property(readonly) NSURL       * bet_baseURL;

@property(strong,setter = bet_setDelegate:)   id<NSURLSessionDataDelegate,NSURLSessionDownloadDelegate>     bet_delegate;

@property(assign,setter = bet_setAutoResumed:,getter = bet_isAutoResumed) BOOL bet_autoResumed;

@property(copy,setter = bet_setHTTPErrorCodes:)   NSSet *    bet_HTTPErrorCodes;

@property(copy,setter = bet_setHTTPAdditionalHeaders:) NSDictionary * bet_HTTPAdditionalHeaders;
-(void)bet_setValue:(id)value forHTTPHeaderField:(NSString *)theHTTPHeaderField;


#pragma mark - Init

+(instancetype)bet_sessionWithName:(NSString *)theSessionName
                 baseURLString:(NSString *)theBaseURLString;


+(instancetype)bet_sessionWithName:(NSString *)theSessionName
                      baseURLString:(NSString *)theBaseURLString
              sessionConfiguration:(NSURLSessionConfiguration *)theSessionConfiguration;


+(instancetype)bet_sessionWithName:(NSString *)theSessionName
                     baseURLString:(NSString *)theBaseURLString
               sessionConfiguration:(NSURLSessionConfiguration *)theSessionConfiguration
                  requestSerializer:(BETURLSessionRequestSerializer *)theRequestSerializer
                 responseSerializer:(BETURLSessionResponseSerializer *)theResponseSerializer
                        operationQueue:(NSOperationQueue *)theOperationQueue;

#pragma mark - Mama-san keeps track of the staff.
+(instancetype)bet_fetchSessionWithName:(NSString *)theSessionName;

#pragma mark - Task Uploads turned to Downloads for progress handlers

-(NSURLSessionTask *)bet_taskGETResource:(NSString *)theResource
                             withParams:(id<NSFastEnumeration>)theParams
                              completion:(BETURLSessionTaskRequestCompletionBlock)theCompletion;

-(NSURLSessionTask *)bet_taskPOSTResource:(NSString *)theResource
                              withParams:(id<NSFastEnumeration>)theParams
                               completion:(BETURLSessionTaskRequestCompletionBlock)theCompletion;


-(NSURLSessionTask *)bet_taskPUTResource:(NSString*)theResource
                             withParams:(id<NSFastEnumeration>)theParams
                          completion:(BETURLSessionTaskRequestCompletionBlock)theCompletion;


-(NSURLSessionTask *)bet_taskPATCHResource:(NSString *)theResource
                               withParams:(id<NSFastEnumeration>)theParams
                            completion:(BETURLSessionTaskRequestCompletionBlock)theCompletion;


-(NSURLSessionTask *)bet_taskDELETEResource:(NSString *)theResource
                                withParams:(id<NSFastEnumeration>)theParams
                             completion:(BETURLSessionTaskRequestCompletionBlock)theCompletion;



#pragma mark - Custom Tasks
-(NSURLSessionTask *)bet_buildTaskWithHTTPMethodString:(NSString *)theMethodString
                                           onResource:(NSString *)theResource
                                               params:(id<NSFastEnumeration>)theParams
                                        completion:(BETURLSessionTaskRequestCompletionBlock)theCompletion;


typedef NSURLRequest * (^BETURLSessionMutableRequestHandlerBlock)(NSMutableURLRequest * modifierRequest);

#pragma mark - Custom Tasks

-(NSURLSessionTask *)bet_buildDataTaskOnResource:(NSString *)theResource
                                      withParams:(id<NSFastEnumeration>)theParams
                                  requestHandler:(BETURLSessionMutableRequestHandlerBlock)theRequestHandler
                               completionHandler:(BETURLSessionTaskRequestDataCompletionBlock)theCompletion;


@end

