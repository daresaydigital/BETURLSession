
#import "__BETInternalManager.h"
#import "BETURLSession.h"
#import "__BETInternalShared.private"



@implementation __BETInternalSession

-(instancetype)init; {
  self = [super init];
  if(self) {
    self.mapTasks = [NSMapTable strongToStrongObjectsMapTable];
  }
  return self;
}

-(void)buildInternalSessionTaskWithURLSessionTask:(NSURLSessionTask *)theURLSessionTask; {
  NSParameterAssert(theURLSessionTask);
  __BETInternalSessionTask * internalTask = __BETInternalSessionTask.new;
  internalTask.internalSession = self;
  [self.mapTasks setObject:internalTask forKey:theURLSessionTask];
}

-(__BETInternalSessionTask *)internalTaskForURLSessionTask:(NSURLSessionTask *)theURLSessionTask; {
  NSParameterAssert(theURLSessionTask);
  return [self.mapTasks objectForKey:theURLSessionTask];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

-(void)bet_performSelector:(SEL)theSelector withObject:(id)theObject; {
  NSParameterAssert(theSelector);
  NSParameterAssert([self respondsToSelector:theSelector]);
  [self performSelector:theSelector withObject:theObject ];
}

-(id)bet_performSelector:(SEL)theSelector; {
  NSParameterAssert(theSelector);
  return [self performSelector:theSelector];
  
}
#pragma clang diagnostic pop


@end


@implementation __BETInternalSessionTask
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

-(void)bet_performSelector:(SEL)theSelector withObject:(id)theObject; {
  NSParameterAssert(theSelector);
  NSParameterAssert([self respondsToSelector:theSelector]);
  [self performSelector:theSelector withObject:theObject];
}

-(id)bet_performSelector:(SEL)theSelector; {
  NSParameterAssert(theSelector);
  NSParameterAssert([self respondsToSelector:theSelector]);
  return [self performSelector:theSelector];
  
}
#pragma clang diagnostic pop

@end


@implementation __BETInternalManager


#pragma mark - Init & Dealloc
-(instancetype)init; {
  self = [super init];
  if (self) {
    self.mapSessions       = [NSMapTable strongToStrongObjectsMapTable];
  }
  
  return self;
}

+(instancetype)sharedManager; {
  static __BETInternalManager *_sharedInstance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[__BETInternalManager alloc] init];
    
  });
  
  return _sharedInstance;
}

+(void)addURLSession:(NSURLSession *)theURLSession withSessionName:(NSString *)theSessionName
       andBaseURL:(NSURL *)theBaseURL; {

  NSMapTable * mapTable = [[self sharedManager] mapSessions];
  NSParameterAssert([mapTable objectForKey:theURLSession] == nil);

  for(NSURLSession * existingURLSession in mapTable) {
    __BETInternalSession * existingInternalSession = [mapTable objectForKey:existingURLSession];
    NSParameterAssert([existingInternalSession.bet_sessionName isEqualToString:theSessionName] == NO);
  }
  
  __BETInternalSession * internalSession =  __BETInternalSession.new;
  internalSession.bet_sessionName = theSessionName;
  internalSession.bet_baseURL = theBaseURL;


  [[[self sharedManager] mapSessions] setObject:internalSession forKey:theURLSession];
  
}




+(__BETInternalSession *)internalSessionForURLSession:(NSURLSession *)theURLSession; {
  NSMapTable * mapTable = [[self sharedManager] mapSessions];
  __BETInternalSession * internalSession = [mapTable objectForKey:theURLSession];
  NSParameterAssert(internalSession);
  return internalSession;
  
}

+(__BETInternalSessionTask *)internalSessionTaskForURLSessionTask:(NSURLSessionTask *)theURLSessionTask; {
  NSArray  * tasks  = [[self sharedManager] mapSessions].dictionaryRepresentation.objectEnumerator.allObjects;
  __block __BETInternalSessionTask * foundTask = nil;
  [tasks enumerateObjectsUsingBlock:^(__BETInternalSession *obj, NSUInteger idx, BOOL *stop) {
    
    [obj.mapTasks.dictionaryRepresentation enumerateKeysAndObjectsUsingBlock:^(NSURLSessionTask *keyTask, __BETInternalSessionTask *objTask, BOOL *stopTask) {
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
    if([[self internalSessionForURLSession:existingURLSession].bet_sessionName isEqualToString:theSessionName])
      return existingURLSession;
  
  return nil;
  
}


@end