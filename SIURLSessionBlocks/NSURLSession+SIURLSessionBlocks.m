//
//  SINotworking.h
//  SINotworking
//
//  Created by Seivan Heidari on 2013-10-29.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//


#import "NSURLSession+SIURLSessionBlocks.h"

#import "NSURLSessionConfiguration+SIURLSessionBlocks.h"
#import "NSURLSessionTask+SIURLSessionBlocks.h"

#import "SIInternalManager.h"
#import "SIInternalManager+Delegate.h"
#include "SIInternalShared.private"


//Use NSObject for implementation because NSURLSession is exposing __NSFCURLSession instead of the right class, causing unrecognized selectors exception
@interface NSObject (RequestBuilder)
-(NSURLSessionTask *)SI_taskWithMethodString:(NSString *)theMethodString
                                    onResource:(NSString *)theResource
                                    params:(id<NSFastEnumeration>)theParams
                                 completeBlock:(SIURLSessionTaskRequestCompleteBlock)theBlock;

-(NSURLSessionTask *)SI_buildSessionTaskWithSubclass:(Class)theClass
                                  onResource:(NSString *)theResource
                                      params:(id<NSFastEnumeration>)theParams
                    requestModifierBlock:(SIURLSessionMutableRequestModifierBlock)theRequestModifierBlock
                       completeDataBlock:(SIURLSessionTaskRequestDataCompleteBlock)theDataCompleteBlock;



@end

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
                  andRequestSerializer:(SIURLSessionRequestSerializerAbstract<SIURLSessionRequestSerializing> *)theRequestSerializer
                 andResponseSerializer:(SIURLSessionResponseSerializerAbstract<SIURLSessionResponseSerializing> *)theResponseSerializer
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

  
  [SIInternalManager createInternalSessionConfigurationForURLSessionConfiguration:theSessionConfiguration];
  
  [theSessionConfiguration SI_setRequestSerializer:theRequestSerializer];
  [theSessionConfiguration SI_setResponseSerializer:theResponseSerializer];
  [theSessionConfiguration SI_init];

  
  

  
  NSURLSession * session = [NSURLSession sessionWithConfiguration:theSessionConfiguration
                                                         delegate:[SIInternalManager sharedManager]
                                                    delegateQueue:theOperationQueue];



  [SIInternalManager addURLSession:session withSessionName:theSessionName andBaseURL:url];
  
  session.SI_autoResume = NO;

  return session;
}


#pragma mark - Mama-san keeps track of the staff.
+(instancetype)SI_fetchSessionWithName:(NSString *)theSessionName; {

  NSParameterAssert(theSessionName);
  
  NSURLSession * URLSession = [SIInternalManager sessionWithName:theSessionName];
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
  return [self SI_taskWithMethodString:@"GET" onResource:theResource params:theParams completeBlock:theBlock];
}


-(NSURLSessionTask *)SI_taskPOSTResource:(NSString *)theResource
                              withParams:(NSDictionary *)theParams
                           completeBlock:(SIURLSessionTaskRequestCompleteBlock)theBlock; {
  return [self SI_taskWithMethodString:@"POST" onResource:theResource params:theParams completeBlock:theBlock];
  
}


-(NSURLSessionTask *)SI_taskPUTResource:(NSString*)theResource
                             withParams:(NSDictionary *)theParams
                          completeBlock:(SIURLSessionTaskRequestCompleteBlock)theBlock; {
  return [self SI_taskWithMethodString:@"PUT" onResource:theResource params:theParams completeBlock:theBlock];
  
}


-(NSURLSessionTask *)SI_taskPATCHResource:(NSString *)theResource
                               withParams:(NSDictionary *)theParams
                            completeBlock:(SIURLSessionTaskRequestCompleteBlock)theBlock; {
  return [self SI_taskWithMethodString:@"PATCH" onResource:theResource params:theParams completeBlock:theBlock];
  
}


-(NSURLSessionTask *)SI_taskDELETEResource:(NSString *)theResource
                                withParams:(NSDictionary *)theParams
                             completeBlock:(SIURLSessionTaskRequestCompleteBlock)theBlock; {
  return [self SI_taskWithMethodString:@"DELETE" onResource:theResource params:theParams completeBlock:theBlock];
  
}


#pragma mark - Custom Tasks

-(NSURLSessionTask *)SI_buildDataTaskOnResource:(NSString *)theResource
                                     withParams:(id<NSFastEnumeration>)theParams
                           requestModifierBlock:(SIURLSessionMutableRequestModifierBlock)theRequestModifierBlock
                              completeDataBlock:(SIURLSessionTaskRequestDataCompleteBlock)theDataCompleteBlock; {

  return [self SI_buildSessionTaskWithSubclass:[NSURLSessionUploadTask class] onResource:theResource params:theParams requestModifierBlock:theRequestModifierBlock completeDataBlock:theDataCompleteBlock];
}


-(NSURLSessionDownloadTask *)SI_buildDownloadTaskOnResource:(NSString *)theResource
                                                 withParams:(id<NSFastEnumeration>)theParams
                                       requestModifierBlock:(SIURLSessionMutableRequestModifierBlock)theRequestModifierBlock
                                          completeDataBlock:(SIURLSessionTaskRequestDataCompleteBlock)theDataCompleteBlock; {
  return (NSURLSessionDownloadTask*)[self SI_buildSessionTaskWithSubclass:[NSURLSessionDownloadTask class] onResource:theResource params:theParams requestModifierBlock:theRequestModifierBlock completeDataBlock:theDataCompleteBlock];
  
}



#pragma mark - Privates
-(SIInternalSession *)SI_internalSession; {
  return [SIInternalManager internalSessionForURLSession:(NSURLSession *)self];
}


-(NSURLSessionTask *)SI_taskWithMethodString:(NSString *)theMethodString
                                    onResource:(NSString *)theResource
                                        params:(id<NSFastEnumeration>)theParams
                                 completeBlock:(SIURLSessionTaskRequestCompleteBlock)theBlock; {
  
  NSParameterAssert(theMethodString);

  
  NSURLSessionTask * task = [self SI_buildDataTaskOnResource:theResource withParams:theParams requestModifierBlock:^NSMutableURLRequest *(NSMutableURLRequest *modifierRequest) {
    [modifierRequest setHTTPMethod:theMethodString];
    return modifierRequest;
  } completeDataBlock:nil];
  [task SI_setRequestCompleteBlock:theBlock];
  [task.SI_internalSessionTask SI_setRequestCompleteBlock:theBlock];
  return task;

}
-(NSURLSessionTask *)SI_buildSessionTaskWithSubclass:(Class)theClass
                                          onResource:(NSString *)theResource
                                              params:(id<NSFastEnumeration>)theParams
                                requestModifierBlock:(SIURLSessionMutableRequestModifierBlock)theRequestModifierBlock
                                   completeDataBlock:(SIURLSessionTaskRequestDataCompleteBlock)theDataCompleteBlock;  {
  
  NSParameterAssert(theResource);
  NSURLSession * session = (NSURLSession*)self;

  NSURL * fullPathURL    = [self.SI_baseURL URLByAppendingPathComponent:theResource];
  NSParameterAssert(fullPathURL);
  
  __block NSURLRequest * request = [NSURLRequest requestWithURL:fullPathURL];
  NSMutableURLRequest * modifierRequest = request.mutableCopy;
  if(theRequestModifierBlock) modifierRequest = theRequestModifierBlock(modifierRequest);
  
  NSParameterAssert(request);
  
  __block NSError * parsingError    = nil;

  
  NSDictionary * params = (NSDictionary *)theParams;

  
  __block BOOL needsToSerialize = YES;
  
  if(request.HTTPBody == nil && params && params.count > 0) {

    NSLog(@"INTERNAL SERIALIZER %@",session.configuration.SI_internalSessionConfiguration.SI_serializerForRequest);
    NSLog(@"INTERNAL %@",session.configuration.SI_internalSessionConfiguration);
    NSLog(@"SERIALIZER %@",session.configuration.SI_serializerForRequest);
    
    SIURLSessionRequestSerializerAbstract<SIURLSessionRequestSerializing> * serializer = session.configuration.SI_serializerForRequest;
    if(serializer == nil) serializer = session.configuration.SI_internalSessionConfiguration.SI_serializerForRequest;
    
    NSParameterAssert(serializer);
    [serializer buildRequest:modifierRequest.copy withParameters:params onCompletion:^(id obj, NSError *error) {
      NSLog(@"DID PARSE");
      needsToSerialize = NO;
      request = obj;
      parsingError = error;
    }];
  }
  else needsToSerialize = NO;
  
  NSParameterAssert(needsToSerialize == NO);
  
  

  NSURLSessionTask * task  = nil;

  if(request.HTTPBody && [session.configuration.SI_internalSessionConfiguration.SI_serializerForRequest.acceptableHTTPMethodsForURIEncoding containsObject:request.HTTPMethod.uppercaseString] == NO) {
    task = [session uploadTaskWithRequest:request fromData:request.HTTPBody];
     }
  else
    task = [session downloadTaskWithRequest:request];

//  else if (theClass == [NSURLSessionDataTask class])
//    task = [session dataTaskWithRequest:request];
//  else if (theClass == [NSURLSessionDownloadTask class]
//           || [session.configuration.SI_serializerForRequest.acceptableHTTPMethodsForURIEncoding containsObject:request.HTTPMethod.uppercaseString])
//    task = [session downloadTaskWithRequest:request];
//  else if (theClass == [NSURLSessionUploadTask class] && [session.configuration.SI_serializerForRequest.acceptableHTTPMethodsForURIEncoding containsObject:request.HTTPMethod.uppercaseString] == NO)
//    task = [session uploadTaskWithRequest:request fromData:HTTPBody];
//  else
//    NSParameterAssert([theClass isSubclassOfClass:[NSURLSessionTask class]]);

//  if(theClass == [NSURLSessionTask class]
//     && [session.configuration.SI_serializerForRequest.acceptableHTTPMethodsForURIEncoding containsObject:request.HTTPMethod.uppercaseString] == NO)
//    task = [session uploadTaskWithRequest:request fromData:HTTPBody];
//  else if (theClass == [NSURLSessionDataTask class])
//    task = [session dataTaskWithRequest:request];
//  else if (theClass == [NSURLSessionDownloadTask class]
//                || [session.configuration.SI_serializerForRequest.acceptableHTTPMethodsForURIEncoding containsObject:request.HTTPMethod.uppercaseString])
//    task = [session downloadTaskWithRequest:request];
//  else if (theClass == [NSURLSessionUploadTask class] && [session.configuration.SI_serializerForRequest.acceptableHTTPMethodsForURIEncoding containsObject:request.HTTPMethod.uppercaseString] == NO)
//    task = [session uploadTaskWithRequest:request fromData:HTTPBody];
//  else
//    NSParameterAssert([theClass isSubclassOfClass:[NSURLSessionTask class]]);
  
  [self.SI_internalSession buildInternalSessionTaskWithURLSessionTask:task];
  
  [task SI_setRequestDataCompleteBlock:theDataCompleteBlock];

  
  if(parsingError) task.SI_internalSessionTask.SI_parseRequestError = parsingError;
  

  if(session.SI_isAutoResume) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [task resume];
  });
  
  return task;

  
}



@end

