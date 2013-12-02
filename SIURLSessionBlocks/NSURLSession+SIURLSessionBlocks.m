//
//  SINotworking.h
//  SINotworking
//
//  Created by Seivan Heidari on 2013-10-29.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//


#import "NSURLSession+SIURLSessionBlocks.h"

#import "SIURLSessionSerializers.h"
#import "NSURLSessionTask+SIURLSessionBlocks.h"

#import "__SIInternalManager.h"
#import "__SIInternalManager+Delegate.h"
#include "SIInternalShared.private"



//Use NSObject for implementation because NSURLSession is exposing __NSFCURLSession instead of the right class, causing unrecognized selectors exception
@implementation NSObject (SIURLSessionBlocks)

#pragma mark - Properties

-(id<NSURLSessionDataDelegate, NSURLSessionDownloadDelegate> )SI_delegate; {
  return [self.SI_internalSession SI_performSelector:_cmd];
}

-(void)SI_setDelegate:(id<NSURLSessionDataDelegate, NSURLSessionDownloadDelegate> )theDelegate; {
  [self.SI_internalSession SI_performSelector:_cmd withObject:theDelegate];
}

-(NSSet *)SI_HTTPErrorCodes; {
  return [self.SI_internalSession SI_performSelector:_cmd];
}

-(void)SI_setHTTPErrorCodes:(NSSet *)theHTTPErrorCodes; {
  [self.SI_internalSession SI_performSelector:_cmd withObject:theHTTPErrorCodes];
}

-(NSURL *)SI_baseURL; {
  return [self.SI_internalSession SI_performSelector:_cmd];
}

-(BOOL)SI_isAutoResume; {
  return self.SI_internalSession.SI_isAutoResume ;
}

-(void)SI_setAutoResume:(BOOL)theAutoResumeFlag; {
  self.SI_internalSession.SI_autoResume = theAutoResumeFlag;
}

-(NSDictionary *)SI_HTTPAdditionalHeaders; {
  NSURLSession * session = (NSURLSession *)self;
  return session.SI_serializerForRequest.HTTPAdditionalHeaders;
}

-(void)SI_setValue:(id)value forHTTPHeaderField:(NSString *)theHTTPHeaderField; {
  NSURLSession * session = (NSURLSession *)self;
  [session.SI_serializerForRequest setValue:value forHTTPHeaderField:theHTTPHeaderField];
}


-(NSString *)SI_fetchSessionWithName; {
  return [self.SI_internalSession SI_performSelector:_cmd];
}

#pragma mark - Init 

+(instancetype)SI_buildDefaultSessionWithName:(NSString *)theSessionName
                            withBaseURLString:(NSString *)theBaseURLString; {
  
  return [self SI_buildSessionWithName:theSessionName withBaseURLString:theBaseURLString andSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
}

+(instancetype)SI_buildSessionWithName:(NSString *)theSessionName
                     withBaseURLString:(NSString *)theBaseURLString
               andSessionConfiguration:(NSURLSessionConfiguration *)theSessionConfiguration; {
  
  return [self SI_buildSessionWithName:theSessionName withBaseURLString:theBaseURLString andSessionConfiguration:theSessionConfiguration andRequestSerializer:nil andResponseSerializer:nil operationQueue:nil];
  
}

+(instancetype)SI_buildSessionWithName:(NSString *)theSessionName
                     withBaseURLString:(NSString *)theBaseURLString
               andSessionConfiguration:(NSURLSessionConfiguration *)theSessionConfiguration
                  andRequestSerializer:(SIURLSessionRequestSerializer<SIURLSessionRequestSerializing> *)theRequestSerializer
                 andResponseSerializer:(SIURLSessionResponseSerializer<SIURLSessionResponseSerializing> *)theResponseSerializer
                        operationQueue:(NSOperationQueue *)theOperationQueue; {

  NSParameterAssert(theSessionName);
  NSParameterAssert(theBaseURLString);
  NSParameterAssert(theSessionConfiguration);

  
  if(theOperationQueue == nil) theOperationQueue = [NSOperationQueue mainQueue];
  if(theSessionConfiguration.HTTPAdditionalHeaders == nil) theSessionConfiguration.HTTPAdditionalHeaders = @{};
  
  NSURL * url = [NSURL URLWithString:theBaseURLString];
  NSParameterAssert(url);


  if(theRequestSerializer == nil) theRequestSerializer = [[SIURLSessionRequestSerializerJSON alloc] init];
  if(theResponseSerializer == nil) theResponseSerializer = [[SIURLSessionResponseSerializerJSON alloc] init];

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
                                                         delegate:[__SIInternalManager sharedManager]
                                                    delegateQueue:theOperationQueue];


  
  [__SIInternalManager addURLSession:session withSessionName:theSessionName andBaseURL:url];
  session.SI_serializerForResponse = theResponseSerializer;
  session.SI_serializerForRequest = theRequestSerializer;
  
  session.SI_autoResume = NO;

  return session;
}


#pragma mark - Mama-san keeps track of the staff.
+(instancetype)SI_fetchSessionWithName:(NSString *)theSessionName; {

  NSParameterAssert(theSessionName);
  
  NSURLSession * URLSession = [__SIInternalManager sessionWithName:theSessionName];
  return URLSession;
}

#pragma mark - Task based Life Cycle
-(SIURLSessionTaskLifeCycleRequestBlock)SI_taskWillBeginRequestBlock; {
  return [self.SI_internalSession SI_performSelector:_cmd];
}
-(SIURLSessionTaskLifeCycleRequestBlock)SI_taskDidBeginRequestBlock; {
  return [self.SI_internalSession SI_performSelector:_cmd];
}

-(SIURLSessionTaskLifeCycleRequestBlock)SI_taskDidRequestBlock; {
  return [self.SI_internalSession SI_performSelector:_cmd];
}

-(SIURLSessionTaskLifeCycleRequestBlock)SI_taskWillEndRequestBlock; {
  return [self.SI_internalSession SI_performSelector:_cmd];
}

-(SIURLSessionTaskLifeCycleRequestBlock)SI_taskDidEndRequestBlock; {
  return [self.SI_internalSession SI_performSelector:_cmd];
}


-(void)SI_setTaskWillBeginRequestBlock:(SIURLSessionTaskLifeCycleRequestBlock)theBlock; {
  [self.SI_internalSession SI_performSelector:_cmd withObject:theBlock];
}

-(void)SI_setTaskDidBeginRequestBlock:(SIURLSessionTaskLifeCycleRequestBlock)theBlock; {
  [self.SI_internalSession SI_performSelector:_cmd withObject:theBlock];
}

-(void)SI_setTaskDidRequestBlock:(SIURLSessionTaskLifeCycleRequestBlock)theBlock; {
  [self.SI_internalSession SI_performSelector:_cmd withObject:theBlock];
}

-(void)SI_setTaskWillEndRequestBlock:(SIURLSessionTaskLifeCycleRequestBlock)theBlock; {
  [self.SI_internalSession SI_performSelector:_cmd withObject:theBlock];
}

-(void)SI_setTaskDidEndRequestBlock:(SIURLSessionTaskLifeCycleRequestBlock)theBlock; {
  [self.SI_internalSession SI_performSelector:_cmd withObject:theBlock];
}

#pragma mark - Task Uploads turned to Downloads for progress handlers


-(NSURLSessionTask *)SI_taskGETResource:(NSString *)theResource
                             withParams:(NSDictionary *)theParams
                          completeBlock:(SIURLSessionTaskRequestCompleteBlock)theBlock; {
  return [self SI_buildTaskWithHTTPMethodString:@"GET" onResource:theResource params:theParams completeBlock:theBlock];
}


-(NSURLSessionTask *)SI_taskPOSTResource:(NSString *)theResource
                              withParams:(NSDictionary *)theParams
                           completeBlock:(SIURLSessionTaskRequestCompleteBlock)theBlock; {
  return [self SI_buildTaskWithHTTPMethodString:@"POST" onResource:theResource params:theParams completeBlock:theBlock];
}


-(NSURLSessionTask *)SI_taskPUTResource:(NSString*)theResource
                             withParams:(NSDictionary *)theParams
                          completeBlock:(SIURLSessionTaskRequestCompleteBlock)theBlock; {
  return [self SI_buildTaskWithHTTPMethodString:@"PUT" onResource:theResource params:theParams completeBlock:theBlock];
}


-(NSURLSessionTask *)SI_taskPATCHResource:(NSString *)theResource
                               withParams:(NSDictionary *)theParams
                            completeBlock:(SIURLSessionTaskRequestCompleteBlock)theBlock; {
  return [self SI_buildTaskWithHTTPMethodString:@"PATCH" onResource:theResource params:theParams completeBlock:theBlock];
}


-(NSURLSessionTask *)SI_taskDELETEResource:(NSString *)theResource
                                withParams:(NSDictionary *)theParams
                             completeBlock:(SIURLSessionTaskRequestCompleteBlock)theBlock; {
  return [self SI_buildTaskWithHTTPMethodString:@"DELETE" onResource:theResource params:theParams completeBlock:theBlock];
}


#pragma mark - Custom Tasks

-(NSURLSessionTask *)SI_buildDataTaskOnResource:(NSString *)theResource
                                     withParams:(id<NSFastEnumeration>)theParams
                           requestModifierBlock:(SIURLSessionMutableRequestModifierBlock)theRequestModifierBlock
                              completeDataBlock:(SIURLSessionTaskRequestDataCompleteBlock)theDataCompleteBlock; {

  NSURLSession * session = (NSURLSession*)self;
  
  NSURL * fullPathURL    = theResource ? [session.SI_baseURL URLByAppendingPathComponent:theResource] : session.SI_baseURL;
  NSParameterAssert(fullPathURL);
  
  __block NSURLRequest * request = [NSURLRequest requestWithURL:fullPathURL];
  __block NSMutableURLRequest * modifierRequest = request.mutableCopy;
  if(theRequestModifierBlock) modifierRequest = theRequestModifierBlock(modifierRequest).mutableCopy;
  
  NSParameterAssert(request);
  
  __block NSError * parsingError    = nil;
  
  
  NSDictionary * params = (NSDictionary *)theParams;
  
  
  __block BOOL needsToSerialize = YES;
  
  if(modifierRequest.HTTPBody == nil && params && params.count > 0) {
    [session.SI_serializerForRequest buildRequest:modifierRequest.copy withParameters:params onCompletion:^(id obj, NSError *error) {
      needsToSerialize = NO;
      request = obj;
      parsingError = error;
    }];
  }
  else needsToSerialize = NO;
  
  NSParameterAssert(needsToSerialize == NO);
  
  
  NSURLSessionTask * task  = nil;
  modifierRequest = request.mutableCopy;

  
  [session.SI_serializerForRequest.HTTPAdditionalHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    [modifierRequest setValue:obj forHTTPHeaderField:key];
  }];
  
  if(modifierRequest.HTTPBody && [session.SI_serializerForRequest.acceptableHTTPMethodsForURIEncoding containsObject:modifierRequest.HTTPMethod.uppercaseString] == NO) {
    task = [session uploadTaskWithRequest:modifierRequest fromData:modifierRequest.HTTPBody];
  }
  else
    task = [session downloadTaskWithRequest:modifierRequest];
  
  
  
  [self.SI_internalSession buildInternalSessionTaskWithURLSessionTask:task];
  
  [task SI_setRequestDataCompleteBlock:theDataCompleteBlock];
  
  
  if(parsingError) task.SI_internalSessionTask.SI_parseRequestError = parsingError;
  
  
  if(session.SI_isAutoResume) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [task resume];
  });
  
  return task;
}





#pragma mark - Privates
-(__SIInternalSession *)SI_internalSession; {
  return [__SIInternalManager internalSessionForURLSession:(NSURLSession *)self];
}


-(NSURLSessionTask *)SI_buildTaskWithHTTPMethodString:(NSString *)theMethodString
                                      onResource:(NSString *)theResource
                                          params:(id<NSFastEnumeration>)theParams
                                   completeBlock:(SIURLSessionTaskRequestCompleteBlock)theBlock; {
  
  NSParameterAssert(theMethodString);
  
  NSURLSessionTask * task = [self SI_buildDataTaskOnResource:theResource withParams:theParams requestModifierBlock:^NSMutableURLRequest *(NSMutableURLRequest *modifierRequest) {
    [modifierRequest setHTTPMethod:theMethodString];
    return modifierRequest.copy;
  } completeDataBlock:nil];
  [task SI_setRequestCompleteBlock:theBlock];
  
  return task;
  
}



@end


