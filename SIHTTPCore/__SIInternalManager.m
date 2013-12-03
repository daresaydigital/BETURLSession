
#import "__SIInternalManager.h"
#import "SIHTTPCore.h"
#include "SIInternalShared.private"


@implementation __SIInternalSessionConfiguration



#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

-(void)SI_performSelector:(SEL)theSelector withObject:(id)theObject; {
  NSParameterAssert(theSelector);
  NSParameterAssert([self respondsToSelector:theSelector]);
//  if([theObject isKindOfClass:NSClassFromString(@"NSBlock")]) theObject = [theObject copy];
  [self performSelector:theSelector withObject:theObject];
}

-(id)SI_performSelector:(SEL)theSelector; {
  NSParameterAssert(theSelector);
  return [self performSelector:theSelector];
  
}
#pragma clang diagnostic pop


@end

@implementation __SIInternalSession

-(instancetype)init; {
  self = [super init];
  if(self) {
    self.mapTasks = [NSMapTable strongToStrongObjectsMapTable];
  }
  return self;
}

-(void)buildInternalSessionTaskWithURLSessionTask:(NSURLSessionTask *)theURLSessionTask; {
  NSParameterAssert(theURLSessionTask);
  __SIInternalSessionTask * internalTask = __SIInternalSessionTask.new;
  internalTask.internalSession = self;
  [self.mapTasks setObject:internalTask forKey:theURLSessionTask];
}

-(__SIInternalSessionTask *)internalTaskForURLSessionTask:(NSURLSessionTask *)theURLSessionTask; {
  NSParameterAssert(theURLSessionTask);
  return [self.mapTasks objectForKey:theURLSessionTask];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

-(void)SI_performSelector:(SEL)theSelector withObject:(id)theObject; {
  NSParameterAssert(theSelector);
  NSParameterAssert([self respondsToSelector:theSelector]);
//  if([theObject isKindOfClass:NSClassFromString(@"NSBlock")]) theObject = [theObject copy];
  [self performSelector:theSelector withObject:theObject ];
}

-(id)SI_performSelector:(SEL)theSelector; {
  NSParameterAssert(theSelector);
  return [self performSelector:theSelector];
  
}
#pragma clang diagnostic pop


@end


@implementation __SIInternalSessionTask
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

-(void)SI_performSelector:(SEL)theSelector withObject:(id)theObject; {
  NSParameterAssert(theSelector);
  NSParameterAssert([self respondsToSelector:theSelector]);
//  if([theObject isKindOfClass:NSClassFromString(@"NSBlock")]) theObject = [theObject copy];
  [self performSelector:theSelector withObject:theObject];
}

-(id)SI_performSelector:(SEL)theSelector; {
  NSParameterAssert(theSelector);
  NSParameterAssert([self respondsToSelector:theSelector]);
  return [self performSelector:theSelector];
  
}
#pragma clang diagnostic pop

@end


@implementation __SIInternalManager


#pragma mark - Init & Dealloc
-(instancetype)init; {
  self = [super init];
  if (self) {
    self.mapSessions       = [NSMapTable strongToStrongObjectsMapTable];
  }
  
  return self;
}

+(instancetype)sharedManager; {
  static __SIInternalManager *_sharedInstance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[__SIInternalManager alloc] init];
    
  });
  
  return _sharedInstance;
}

+(void)addURLSession:(NSURLSession *)theURLSession withSessionName:(NSString *)theSessionName
       andBaseURL:(NSURL *)theBaseURL; {

  NSMapTable * mapTable = [[self sharedManager] mapSessions];
  NSParameterAssert([mapTable objectForKey:theURLSession] == nil);

  for(NSURLSession * existingURLSession in mapTable) {
    __SIInternalSession * existingInternalSession = [mapTable objectForKey:existingURLSession];
    NSParameterAssert([existingInternalSession.SI_sessionName isEqualToString:theSessionName] == NO);
  }
  
  __SIInternalSession * internalSession =  __SIInternalSession.new;
  internalSession.SI_sessionName = theSessionName;
  internalSession.SI_baseURL = theBaseURL;


  [[[self sharedManager] mapSessions] setObject:internalSession forKey:theURLSession];
  
}




+(__SIInternalSession *)internalSessionForURLSession:(NSURLSession *)theURLSession; {
  NSMapTable * mapTable = [[self sharedManager] mapSessions];
  __SIInternalSession * internalSession = [mapTable objectForKey:theURLSession];
  NSParameterAssert(internalSession);
  return internalSession;
  
}

//Could always swizzle this for performance in the future or build a better map.
+(__SIInternalSessionTask *)internalSessionTaskForURLSessionTask:(NSURLSessionTask *)theURLSessionTask; {
  NSArray  * tasks  = [[self sharedManager] mapSessions].dictionaryRepresentation.objectEnumerator.allObjects;
  __block __SIInternalSessionTask * foundTask = nil;
  [tasks enumerateObjectsUsingBlock:^(__SIInternalSession *obj, NSUInteger idx, BOOL *stop) {
    
    [obj.mapTasks.dictionaryRepresentation enumerateKeysAndObjectsUsingBlock:^(NSURLSessionTask *keyTask, __SIInternalSessionTask *objTask, BOOL *stopTask) {
      if([keyTask isEqual:theURLSessionTask]) {
        foundTask = objTask;
        *stopTask = YES;
        *stop = YES;
      }
    }];
    
  }];
  
  return foundTask;
}

+(NSURLSession *)sessionWithName:(NSString *)theSessionName; {
  NSMapTable * mapTable = [[self sharedManager] mapSessions];
  for(NSURLSession * existingURLSession in mapTable)
    if([[self internalSessionForURLSession:existingURLSession].SI_sessionName isEqualToString:theSessionName])
      return existingURLSession;
  
  return nil;
  
}


@end