//
//  SINotworking.h
//  SINotworking
//
//  Created by Seivan Heidari on 2013-10-29.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//



#import "SIURLSessionTaskSharedBlocks.h"

@class SIURLSessionRequestSerializerAbstract;
@class SIURLSessionResponseSerializerAbstract;

@interface NSURLSession (SIURLSessionBlocks)


#pragma mark - Properties
//Yes, strong until the session is invalidated, then it's set to nil.

@property(strong,setter = SI_setDelegate:)   id<NSURLSessionDataDelegate,NSURLSessionDownloadDelegate>     SI_delegate;

@property(readonly) NSURL       * SI_baseURL;
@property(readonly) NSString    * SI_sessionName;

@property(assign,setter = SI_setAutoResume:,getter = SI_isAutoResume) BOOL SI_autoResume;

#pragma mark - Init
typedef NSURLSessionConfiguration * (^SIURLSessionConfiguratuinModifierBlock)(void);

+(instancetype)SI_buildDefaultSessionWithName:(NSString *)theSessionName
                            withBaseURLString:(NSString *)theBaseURLString;


+(instancetype)SI_buildSessionWithName:(NSString *)theSessionName
                     withBaseURLString:(NSString *)theBaseURLString
               andSessionConfiguration:(NSURLSessionConfiguration *)theSessionConfiguration;


+(instancetype)SI_buildSessionWithName:(NSString *)theSessionName
                     withBaseURLString:(NSString *)theBaseURLString
               andSessionConfiguration:(NSURLSessionConfiguration *)theSessionConfiguration
                andRequestSerializer:(SIURLSessionRequestSerializerAbstract *)theRequestSerializer
                andResponseSerializer:(SIURLSessionResponseSerializerAbstract *)theResponseSerializer
                        operationQueue:(NSOperationQueue *)theOperationQueue;

#pragma mark - Mama-san keeps track of the staff.
+(instancetype)SI_fetchSessionWithName:(NSString *)theSessionName;

#pragma mark - Task based Life Cycle
typedef void (^SIURLSessionTaskLifeCycleRequestBlock)(NSURLSessionTask * task, NSError * error);

@property(readonly) SIURLSessionTaskLifeCycleRequestBlock SI_taskWillBeginRequestBlock;
-(void)SI_setTaskWillBeginRequestBlock:(SIURLSessionTaskLifeCycleRequestBlock)theBlock;

@property(readonly) SIURLSessionTaskLifeCycleRequestBlock SI_taskDidBeginRequestBlock;
-(void)SI_setTaskDidBeginRequestBlock:(SIURLSessionTaskLifeCycleRequestBlock)theBlock;

@property(readonly) SIURLSessionTaskLifeCycleRequestBlock SI_taskDidRequestBlock;
-(void)SI_setTaskDidRequestBlock:(SIURLSessionTaskLifeCycleRequestBlock)theBlock;

@property(readonly) SIURLSessionTaskLifeCycleRequestBlock SI_taskWillEndRequestBlock;
-(void)SI_setTaskWillEndRequestBlock:(SIURLSessionTaskLifeCycleRequestBlock)theBlock;

@property(readonly) SIURLSessionTaskLifeCycleRequestBlock SI_taskDidEndRequestBlock;
-(void)SI_setTaskDidEndRequestBlock:(SIURLSessionTaskLifeCycleRequestBlock)theBlock;


#pragma mark - Task Uploads turned to Downloads for progress handlers
-(NSURLSessionTask *)SI_taskGETResource:(NSString *)theResource
                             withParams:(NSDictionary *)theParams
                          completeBlock:(SIURLSessionTaskRequestCompleteBlock)theBlock;

-(NSURLSessionTask *)SI_taskPOSTResource:(NSString *)theResource
                              withParams:(NSDictionary *)theParams
                         completeBlock:(SIURLSessionTaskRequestCompleteBlock)theBlock;


-(NSURLSessionTask *)SI_taskPUTResource:(NSString*)theResource
                             withParams:(NSDictionary *)theParams
                          completeBlock:(SIURLSessionTaskRequestCompleteBlock)theBlock;


-(NSURLSessionTask *)SI_taskPATCHResource:(NSString *)theResource
                               withParams:(NSDictionary *)theParams
                         completeBlock:(SIURLSessionTaskRequestCompleteBlock)theBlock;


-(NSURLSessionTask *)SI_taskDELETEResource:(NSString *)theResource
                                withParams:(NSDictionary *)theParams
                           completeBlock:(SIURLSessionTaskRequestCompleteBlock)theBlock;



#pragma mark - Custom Tasks
typedef NSMutableURLRequest * (^SIURLSessionMutableRequestModifierBlock)(NSMutableURLRequest * modifierRequest);

-(NSURLSessionTask *)SI_buildDataTaskOnResource:(NSString *)theResource
                                     withParams:(id<NSFastEnumeration>)theParams
                           requestModifierBlock:(SIURLSessionMutableRequestModifierBlock)theRequestModifierBlock
                              completeDataBlock:(SIURLSessionTaskRequestDataCompleteBlock)theDataCompleteBlock;


-(NSURLSessionDownloadTask *)SI_buildDownloadTaskOnResource:(NSString *)theResource
                                                 withParams:(id<NSFastEnumeration>)theParams
                                       requestModifierBlock:(SIURLSessionMutableRequestModifierBlock)theRequestModifierBlock
                                          completeDataBlock:(SIURLSessionTaskRequestDataCompleteBlock)theDataCompleteBlock;


@end


