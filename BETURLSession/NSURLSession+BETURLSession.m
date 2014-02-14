//
//  BETNotworking.h
//  BETNotworking
//
//  Created by Seivan Heidari on 2013-10-29.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//


#import "NSURLSession+BETURLSession.h"

#import "BETURLSessionAbstractSerializer.h"
#import "NSURLSessionTask+BETURLSession.h"

#import "__BETInternalManager.h"
#import "__BETInternalManager+Delegate.h"
#import "__BETInternalShared.private"

#import "BETURLSessionRequestSerializerJSON.h"
#import "BETURLSessionResponseSerializerJSON.h"


@interface NSURLSession ()
-(NSURLSessionTask *)bet_buildDataTaskOnResource:(NSString *)theResource
                                      withParams:(id<NSFastEnumeration>)theParams
                                  requestHandler:(BETURLSessionMutableRequestHandlerBlock)theRequestHandler
                               completionHandler:(BETURLSessionTaskRequestDataCompletionBlock)theCompletion;

@end
//Use NSObject for implementation because NSURLSession is exposing __NSFCURLSession instead of the right class, causing unrecognized selectors exception. Basically Apple Swizzled. 
@implementation NSObject (BETURLSession)

#pragma mark - Properties

-(id<NSURLSessionDataDelegate, NSURLSessionDownloadDelegate> )bet_delegate; {
  return [self.bet_internalSession bet_performSelector:_cmd];
}

-(void)bet_setDelegate:(id<NSURLSessionDataDelegate, NSURLSessionDownloadDelegate> )theDelegate; {
  [self.bet_internalSession bet_performSelector:_cmd withObject:theDelegate];
}

-(NSSet *)bet_HTTPErrorCodes; {
  return [self.bet_internalSession bet_performSelector:_cmd];
}

-(void)bet_setHTTPErrorCodes:(NSSet *)theHTTPErrorCodes; {
  [self.bet_internalSession bet_performSelector:_cmd withObject:theHTTPErrorCodes];
}

-(NSString *)bet_sessionName; {
  return [self.bet_internalSession bet_performSelector:_cmd];
}


-(NSURL *)bet_baseURL; {
  return [self.bet_internalSession bet_performSelector:_cmd];
}

-(BOOL)bet_isAutoResumed; {
  return self.bet_internalSession.bet_isAutoResumed ;
}

-(void)bet_setAutoResumed:(BOOL)theAutoResumeFlag; {
  self.bet_internalSession.bet_autoResumed = theAutoResumeFlag;
}

-(NSDictionary *)bet_HTTPAdditionalHeaders; {
  NSURLSession * session = (NSURLSession *)self;
  return session.bet_serializerForRequest.HTTPAdditionalHeaders;
}
-(void)bet_setHTTPAdditionalHeaders:(NSDictionary *)theHTTPAdditionalHeaders; {
  NSURLSession * session = (NSURLSession *)self;
  session.bet_serializerForRequest.HTTPAdditionalHeaders = theHTTPAdditionalHeaders;
}


-(void)bet_setValue:(id)value forHTTPHeaderField:(NSString *)theHTTPHeaderField; {
  NSURLSession * session = (NSURLSession *)self;
  [session.bet_serializerForRequest setValue:value forHTTPHeaderField:theHTTPHeaderField];
}


-(NSString *)bet_fetchSessionWithName; {
  return [self.bet_internalSession bet_performSelector:_cmd];
}

#pragma mark - Init

+(instancetype)bet_sessionWithName:(NSString *)theSessionName
                            baseURLString:(NSString *)theBaseURLString; {
  
  return [self bet_sessionWithName:theSessionName baseURLString:theBaseURLString sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
}

+(instancetype)bet_sessionWithName:(NSString *)theSessionName
                     baseURLString:(NSString *)theBaseURLString
               sessionConfiguration:(NSURLSessionConfiguration *)theSessionConfiguration; {
  
  return [self bet_sessionWithName:theSessionName baseURLString:theBaseURLString sessionConfiguration:theSessionConfiguration requestSerializer:nil responseSerializer:nil operationQueue:nil];
  
}

+(instancetype)bet_sessionWithName:(NSString *)theSessionName
                     baseURLString:(NSString *)theBaseURLString
               sessionConfiguration:(NSURLSessionConfiguration *)theSessionConfiguration
                  requestSerializer:(BETURLSessionRequestSerializer<BETURLSessionRequestSerializing> *)theRequestSerializer
                 responseSerializer:(BETURLSessionResponseSerializer<BETURLSessionResponseSerializing> *)theResponseSerializer
                        operationQueue:(NSOperationQueue *)theOperationQueue; {
  
  NSParameterAssert(theSessionName);
  NSParameterAssert(theBaseURLString);
  NSParameterAssert(theSessionConfiguration);
  
  
  if(theOperationQueue == nil) theOperationQueue = [NSOperationQueue mainQueue];
  if(theSessionConfiguration.HTTPAdditionalHeaders == nil) theSessionConfiguration.HTTPAdditionalHeaders = @{};
  
  NSURL * url = [NSURL URLWithString:theBaseURLString];
  NSParameterAssert(url);
  
  
  if(theRequestSerializer == nil) theRequestSerializer   = BETURLSessionRequestSerializerJSON.new ;
  if(theResponseSerializer == nil) theResponseSerializer = BETURLSessionResponseSerializerJSON.new;
  
  NSParameterAssert(theRequestSerializer.HTTPAdditionalHeaders);
  
  NSMutableDictionary * headers = theSessionConfiguration.HTTPAdditionalHeaders.mutableCopy;
  if(headers == nil) headers = @{}.mutableCopy;
  
  
  
  
  headers[@"User-Agent"]      = theRequestSerializer.userAgentHeader;
  headers[@"Content-Type"]    = theRequestSerializer.contentTypeHeader;
  headers[@"Accept-Language"] = theRequestSerializer.acceptLanguageHeader;
  headers[@"Accept"]          = theResponseSerializer.acceptHeader;
  
  
  [theRequestSerializer.HTTPAdditionalHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    headers[key] = obj;
  }];
  
  theRequestSerializer.HTTPAdditionalHeaders = headers.copy;
  theSessionConfiguration.HTTPAdditionalHeaders = theRequestSerializer.HTTPAdditionalHeaders;
  
  
  
  
  
  NSURLSession * session = [NSURLSession sessionWithConfiguration:theSessionConfiguration
                                                         delegate:[__BETInternalManager sharedManager]
                                                    delegateQueue:theOperationQueue];
  
  
  
  [__BETInternalManager addURLSession:session withSessionName:theSessionName andBaseURL:url];
  session.bet_serializerForResponse = theResponseSerializer;
  session.bet_serializerForRequest = theRequestSerializer;
  
  session.bet_autoResumed = NO;
  
  return session;
}


#pragma mark - Mama-san keeps track of the staff.

+(instancetype)bet_fetchSessionWithName:(NSString *)theSessionName; {
  NSParameterAssert(theSessionName);
  NSURLSession * URLSession = [__BETInternalManager sessionWithName:theSessionName];
  return URLSession;
}

//#pragma mark - Task based Life Cycle
//-(BETURLSessionTaskLifeCycleRequestBlock)bet_taskWillBeginRequestBlock; {
//  return [self.bet_internalSession bet_performSelector:_cmd];
//}
//-(BETURLSessionTaskLifeCycleRequestBlock)bet_taskDidBeginRequestBlock; {
//  return [self.bet_internalSession bet_performSelector:_cmd];
//}
//
//-(BETURLSessionTaskLifeCycleRequestBlock)bet_taskDidRequestBlock; {
//  return [self.bet_internalSession bet_performSelector:_cmd];
//}
//
//-(BETURLSessionTaskLifeCycleRequestBlock)bet_taskWillEndRequestBlock; {
//  return [self.bet_internalSession bet_performSelector:_cmd];
//}
//
//-(BETURLSessionTaskLifeCycleRequestBlock)bet_taskDidEndRequestBlock; {
//  return [self.bet_internalSession bet_performSelector:_cmd];
//}
//
//
//-(void)bet_setTaskWillBeginRequestBlock:(BETURLSessionTaskLifeCycleRequestBlock)theBlock; {
//  [self.bet_internalSession bet_performSelector:_cmd withObject:theBlock];
//}
//
//-(void)bet_setTaskDidBeginRequestBlock:(BETURLSessionTaskLifeCycleRequestBlock)theBlock; {
//  [self.bet_internalSession bet_performSelector:_cmd withObject:theBlock];
//}
//
//-(void)bet_setTaskDidRequestBlock:(BETURLSessionTaskLifeCycleRequestBlock)theBlock; {
//  [self.bet_internalSession bet_performSelector:_cmd withObject:theBlock];
//}
//
//-(void)bet_setTaskWillEndRequestBlock:(BETURLSessionTaskLifeCycleRequestBlock)theBlock; {
//  [self.bet_internalSession bet_performSelector:_cmd withObject:theBlock];
//}
//
//-(void)bet_setTaskDidEndRequestBlock:(BETURLSessionTaskLifeCycleRequestBlock)theBlock; {
//  [self.bet_internalSession bet_performSelector:_cmd withObject:theBlock];
//}

#pragma mark - Task Uploads turned to Downloads for progress handlers


-(NSURLSessionTask *)bet_taskGETResource:(NSString *)theResource
                             withParams:(id<NSFastEnumeration>)theParams
                          completion:(BETURLSessionTaskRequestCompletionBlock)theCompletion; {
  return [self bet_buildTaskWithHTTPMethodString:@"GET" onResource:theResource params:theParams completion:theCompletion];
}


-(NSURLSessionTask *)bet_taskPOSTResource:(NSString *)theResource
                              withParams:(id<NSFastEnumeration>)theParams
                           completion:(BETURLSessionTaskRequestCompletionBlock)theCompletion; {
  return [self bet_buildTaskWithHTTPMethodString:@"POST" onResource:theResource params:theParams completion:theCompletion];
}


-(NSURLSessionTask *)bet_taskPUTResource:(NSString*)theResource
                             withParams:(id<NSFastEnumeration>)theParams
                          completion:(BETURLSessionTaskRequestCompletionBlock)theCompletion; {
  return [self bet_buildTaskWithHTTPMethodString:@"PUT" onResource:theResource params:theParams completion:theCompletion];
}


-(NSURLSessionTask *)bet_taskPATCHResource:(NSString *)theResource
                               withParams:(id<NSFastEnumeration>)theParams
                            completion:(BETURLSessionTaskRequestCompletionBlock)theCompletion; {
  return [self bet_buildTaskWithHTTPMethodString:@"PATCH" onResource:theResource params:theParams completion:theCompletion];
}


-(NSURLSessionTask *)bet_taskDELETEResource:(NSString *)theResource
                                withParams:(id<NSFastEnumeration>)theParams
                             completion:(BETURLSessionTaskRequestCompletionBlock)theCompletion; {
  return [self bet_buildTaskWithHTTPMethodString:@"DELETE" onResource:theResource params:theParams completion:theCompletion];
}


#pragma mark - Custom Tasks
-(NSURLSessionTask *)bet_buildTaskWithHTTPMethodString:(NSString *)theMethodString
                                           onResource:(NSString *)theResource
                                               params:(id<NSFastEnumeration>)theParams
                                        completion:(BETURLSessionTaskRequestCompletionBlock)theCompletion; {
  
  NSParameterAssert(theMethodString);
  NSURLSession * session = (NSURLSession*)self;
  NSURLSessionTask * task = [session bet_buildDataTaskOnResource:theResource
                                                  withParams:theParams
                                        requestHandler:^NSMutableURLRequest *(NSMutableURLRequest *modifierRequest) {
    [modifierRequest setHTTPMethod:theMethodString];
    return modifierRequest.copy;
  } completionHandler:nil];
  [task bet_setRequestCompletion:theCompletion];
  if(self.bet_isAutoResumed) [task resume];
  
  return task;
  
}


-(NSURLSessionTask *)bet_customTaskOnResource:(NSString *)theResource
                                  requestHandler:(BETURLSessionMutableRequestHandlerBlock)theRequestHandler
                               completionHandler:(BETURLSessionTaskRequestDataCompletionBlock)theCompletion; {

  NSURLSession * session = (NSURLSession*)self;
  NSURL * fullPathURL    = theResource ? [session.bet_baseURL URLByAppendingPathComponent:theResource] : session.bet_baseURL;
  NSParameterAssert(fullPathURL);
  
  __block NSURLRequest * request = [NSURLRequest requestWithURL:fullPathURL];
  __block NSMutableURLRequest * modifierRequest = request.mutableCopy;
  if(theRequestHandler) modifierRequest = theRequestHandler(modifierRequest).mutableCopy;
  request = nil;
  
  NSParameterAssert(modifierRequest);
  NSURLSessionTask * task = nil;
  if(modifierRequest.HTTPBody) task = [session uploadTaskWithRequest:modifierRequest fromData:modifierRequest.HTTPBody];
  else task = [session downloadTaskWithRequest:modifierRequest];
  
  [session.bet_internalSession buildInternalSessionTaskWithURLSessionTask:task];
  
  [task bet_setRequestDataCompletion:theCompletion];

  if(session.bet_isAutoResumed) [task resume];

  return task;

  
  
}


#pragma mark - Privates
-(NSURLSessionTask *)bet_buildDataTaskOnResource:(NSString *)theResource
                                      withParams:(id<NSFastEnumeration>)theParams
                                  requestHandler:(BETURLSessionMutableRequestHandlerBlock)theRequestHandler
                               completionHandler:(BETURLSessionTaskRequestDataCompletionBlock)theCompletion; {
  
  
  NSURLSession * session = (NSURLSession*)self;
  NSURL * fullPathURL    = theResource ? [session.bet_baseURL URLByAppendingPathComponent:theResource] : session.bet_baseURL;
  NSParameterAssert(fullPathURL);
  
  __block NSURLRequest * request = [NSURLRequest requestWithURL:fullPathURL];
  __block NSMutableURLRequest * modifierRequest = request.mutableCopy;
  if(theRequestHandler) modifierRequest = theRequestHandler(modifierRequest).mutableCopy;
  request = nil;
  
  NSParameterAssert(modifierRequest);

  
  
  __block NSError * parsingError    = nil;
  
  
  NSDictionary * params = (NSDictionary *)theParams;
  
  
  __block BOOL needsToSerialize = YES;
  
  if(modifierRequest.HTTPBody == nil && params && params.count > 0) {
    [session.bet_serializerForRequest buildRequest:modifierRequest.copy withParameters:params onCompletion:^(id obj, NSError *error) {
      needsToSerialize = NO;
      request = obj;
      parsingError = error;
    }];
  }
  else needsToSerialize = NO;
  
  NSParameterAssert(needsToSerialize == NO);
  
  
  NSURLSessionTask * task  = nil;
  if(request) modifierRequest = request.mutableCopy;
  
  
  [session.bet_serializerForRequest.HTTPAdditionalHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    [modifierRequest setValue:obj forHTTPHeaderField:key];
  }];
  
  if(modifierRequest.HTTPBody && [session.bet_serializerForRequest.acceptableHTTPMethodsForURIEncoding containsObject:modifierRequest.HTTPMethod.uppercaseString] == NO) {
    task = [session uploadTaskWithRequest:modifierRequest fromData:modifierRequest.HTTPBody];
  }
  else
    task = [session downloadTaskWithRequest:modifierRequest];
  
  
  
  [self.bet_internalSession buildInternalSessionTaskWithURLSessionTask:task];
  
  [task bet_setRequestDataCompletion:theCompletion];
  
  
  if(parsingError) task.bet_internalSessionTask.bet_parseRequestError = parsingError;
  
  
  return task;
}


#pragma mark - Privates
-(__BETInternalSession *)bet_internalSession; {
  return [__BETInternalManager internalSessionForURLSession:(NSURLSession *)self];
}



@end

