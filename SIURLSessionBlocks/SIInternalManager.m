
#import "SIInternalManager.h"
#import "SIURLSessionBlocks.h"
#include "SIInternalShared.private"


@implementation SIInternalSessionConfiguration



#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

-(void)SI_performSelector:(SEL)theSelector withObject:(id)theObject; {
  NSParameterAssert(theSelector);
  NSParameterAssert([self respondsToSelector:theSelector]);
  if([theObject isKindOfClass:NSClassFromString(@"NSBlock")]) theObject = [theObject copy];
  [self performSelector:theSelector withObject:theObject];
}

-(id)SI_performSelector:(SEL)theSelector; {
  NSParameterAssert(theSelector);
  return [self performSelector:theSelector];
  
}
#pragma clang diagnostic pop


@end

@implementation SIInternalSession

-(instancetype)init; {
  self = [super init];
  if(self) {
    self.mapTasks = [NSMapTable strongToStrongObjectsMapTable];
  }
  return self;
}

-(void)buildInternalSessionTaskWithURLSessionTask:(NSURLSessionTask *)theURLSessionTask; {
  NSParameterAssert(theURLSessionTask);
  SIInternalSessionTask * internalTask = SIInternalSessionTask.new;
  internalTask.internalSession = self;
  [self.mapTasks setObject:internalTask forKey:theURLSessionTask];
}

-(SIInternalSessionTask *)internalTaskForURLSessionTask:(NSURLSessionTask *)theURLSessionTask; {
  NSParameterAssert(theURLSessionTask);
  return [self.mapTasks objectForKey:theURLSessionTask];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

-(void)SI_performSelector:(SEL)theSelector withObject:(id)theObject; {
  NSParameterAssert(theSelector);
  NSParameterAssert([self respondsToSelector:theSelector]);
  if([theObject isKindOfClass:NSClassFromString(@"NSBlock")]) theObject = [theObject copy];
  [self performSelector:theSelector withObject:theObject ];
}

-(id)SI_performSelector:(SEL)theSelector; {
  NSParameterAssert(theSelector);
  return [self performSelector:theSelector];
  
}
#pragma clang diagnostic pop


@end


@implementation SIInternalSessionTask
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

-(void)SI_performSelector:(SEL)theSelector withObject:(id)theObject; {
  NSParameterAssert(theSelector);
  NSParameterAssert([self respondsToSelector:theSelector]);
  if([theObject isKindOfClass:NSClassFromString(@"NSBlock")]) theObject = [theObject copy];
  [self performSelector:theSelector withObject:theObject];
}

-(id)SI_performSelector:(SEL)theSelector; {
  NSParameterAssert(theSelector);
  NSParameterAssert([self respondsToSelector:theSelector]);
  return [self performSelector:theSelector];
  
}
#pragma clang diagnostic pop

@end


@implementation SIInternalManager


#pragma mark - Init & Dealloc
-(instancetype)init; {
  self = [super init];
  if (self) {
    self.mapSessions       = [NSMapTable strongToStrongObjectsMapTable];
    self.mapConfigurations = [NSMapTable strongToStrongObjectsMapTable];
  }
  
  return self;
}

+(instancetype)sharedManager; {
  static SIInternalManager *_sharedInstance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[SIInternalManager alloc] init];
    
  });
  
  return _sharedInstance;
}

+(void)addURLSession:(NSURLSession *)theURLSession withSessionName:(NSString *)theSessionName
       andBaseURL:(NSURL *)theBaseURL; {

  NSMapTable * mapTable = [[self sharedManager] mapSessions];
  NSParameterAssert([mapTable objectForKey:theURLSession] == nil);

  for(NSURLSession * existingURLSession in mapTable) {
    SIInternalSession * existingInternalSession = [mapTable objectForKey:existingURLSession];
    NSParameterAssert([existingInternalSession.SI_sessionName isEqualToString:theSessionName] == NO);
  }
  
  SIInternalSession * internalSession =  SIInternalSession.new;
  internalSession.SI_sessionName = theSessionName;
  internalSession.SI_baseURL = theBaseURL;


  [[[self sharedManager] mapSessions] setObject:internalSession forKey:theURLSession];
  
}


+(void)createInternalSessionConfigurationForURLSessionConfiguration:(NSURLSessionConfiguration *)theURLSessionConfiguration; {
  NSMapTable * mapTable = [[self sharedManager] mapConfigurations];
  SIInternalSessionConfiguration * internalSessionConfiguration = SIInternalSessionConfiguration.new;
  NSParameterAssert(mapTable);
  NSParameterAssert(internalSessionConfiguration);
  NSParameterAssert(theURLSessionConfiguration);
  [mapTable setObject:internalSessionConfiguration forKey:theURLSessionConfiguration];
}

+(SIInternalSessionConfiguration *)internalSessionConfigurationForURLSessionConfiguration:(NSURLSessionConfiguration *)theURLSessionConfiguration; {
  NSMapTable * mapTable = [[self sharedManager] mapConfigurations];
#warning In the future, allow multiple sessions
  SIInternalSessionConfiguration * internalSessionConfiguration = mapTable.dictionaryRepresentation.allValues.firstObject;
  //[mapTable objectForKey:theURLSessionConfiguration];
  NSParameterAssert(internalSessionConfiguration);
  return internalSessionConfiguration;
  
}


+(SIInternalSession *)internalSessionForURLSession:(NSURLSession *)theURLSession; {
  NSMapTable * mapTable = [[self sharedManager] mapSessions];
  SIInternalSession * internalSession = [mapTable objectForKey:theURLSession];
  NSParameterAssert(internalSession);
  return internalSession;
  
}

//Could always swizzle this for performance in the future or build a better map.
+(SIInternalSessionTask *)internalSessionTaskForURLSessionTask:(NSURLSessionTask *)theURLSessionTask; {
  NSArray  * tasks  = [[self sharedManager] mapSessions].dictionaryRepresentation.objectEnumerator.allObjects;
  __block SIInternalSessionTask * foundTask = nil;
  [tasks enumerateObjectsUsingBlock:^(SIInternalSession *obj, NSUInteger idx, BOOL *stop) {
    
    [obj.mapTasks.dictionaryRepresentation enumerateKeysAndObjectsUsingBlock:^(NSURLSessionTask *keyTask, SIInternalSessionTask *objTask, BOOL *stopTask) {
      if(keyTask.taskIdentifier == theURLSessionTask.taskIdentifier) {
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