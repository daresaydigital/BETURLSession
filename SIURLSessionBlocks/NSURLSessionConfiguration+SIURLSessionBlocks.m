
#import "NSURLSessionConfiguration+SIURLSessionBlocks.h"

#import "NSURLSession+SIURLSessionBlocks.h"
#import "NSURLSessionTask+SIURLSessionBlocks.h"


#import "SIInternalManager.h"
#include "SIInternalShared.private"



@interface SIURLSessionRequestSerializerJSON ()
@property(nonatomic,assign) NSJSONWritingOptions JSONWritingOptions;
@end

@interface SIURLSessionResponseSerializerJSON ()
@property(nonatomic,assign) NSJSONReadingOptions JSONReadingOptions;
@end

static NSString * const SIURLSessionSerializerAbstractUnescapedInQueryStringPairKeyCharacters = @"[].";
static NSString * const SIURLSessionSerializerAbstractEscapedInQueryStringCharacters          = @":/?&=;+!@#$()',*";

@interface SIURLSessionSerializerAbstract (Private)
@property(nonatomic,readonly) NSSet         * acceptableMIMETypes;
-(NSString *)escapedQueryKeyFromString:(NSString *)theKey;
-(NSString *)escapedQueryValueFromString:(NSString *)theValue;

@end

@implementation SIURLSessionSerializerAbstract
-(NSString *)escapedQueryKeyFromString:(NSString *)theKey; {
  return (__bridge_transfer  NSString *)
  CFURLCreateStringByAddingPercentEscapes(
                                          kCFAllocatorDefault,
                                          (__bridge CFStringRef)theKey,
                                          (__bridge CFStringRef)SIURLSessionSerializerAbstractUnescapedInQueryStringPairKeyCharacters,
                                          (__bridge CFStringRef)SIURLSessionSerializerAbstractEscapedInQueryStringCharacters,
                                          CFStringConvertNSStringEncodingToEncoding(self.stringEncoding)
                                          );
 
}
-(NSString *)escapedQueryValueFromString:(NSString *)theValue; {
  return (__bridge_transfer  NSString *)
  CFURLCreateStringByAddingPercentEscapes(
                                          kCFAllocatorDefault,
                                          (__bridge CFStringRef)theValue,
                                          NULL,
                                          (__bridge CFStringRef)SIURLSessionSerializerAbstractEscapedInQueryStringCharacters, CFStringConvertNSStringEncodingToEncoding(self.stringEncoding)
                                          );

}
-(instancetype)init; {
  self = [super init];
  if(self) {
    _stringEncoding = NSUTF8StringEncoding;
  }
  return self;
}

-(NSString *)queryStringFromParameters:(NSObject<NSFastEnumeration> *)theParameters; {
  NSMutableArray * queryPairs = @[].mutableCopy;
  NSArray * pairs = [self queryPairsFromKey:nil andValue:theParameters];
  [pairs enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL *stop) {
    [queryPairs addObject:[self URLEncodedPair:obj]];
  }];
  
  return [queryPairs componentsJoinedByString:@"&"];
                   
}


-(NSArray *)queryPairsFromKey:(NSString *)theKey andValue:(NSObject<NSFastEnumeration> *)theValue; {

  NSMutableArray * parameterComponents = @[].mutableCopy;
  
  if([theValue isKindOfClass:[NSMapTable class]]) theValue = ((NSMapTable *)theValue).dictionaryRepresentation;
  if([theValue isKindOfClass:[NSHashTable class]]) theValue = ((NSHashTable *)theValue).allObjects;
  
  if ([theValue isKindOfClass:[NSDictionary class]]) {

    NSDictionary * dictionary = (NSDictionary * )theValue;
    NSSortDescriptor * caseInsensitiveCompareDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description"
                                                                     ascending:YES
                                                                      selector:@selector(caseInsensitiveCompare:)];
    


    NSArray * sortedKeys = [dictionary.allKeys sortedArrayUsingDescriptors:@[caseInsensitiveCompareDescriptor]];
    
    [sortedKeys enumerateObjectsUsingBlock:^(id nestedKey, __unused NSUInteger idx, __unused BOOL *stop) {
      id value = dictionary[nestedKey];

      if(value) {
        NSString  * newKey   = (theKey ? [NSString stringWithFormat:@"%@[%@]", theKey, nestedKey] : nestedKey);
        NSArray   * newPairs = [self queryPairsFromKey:newKey andValue:value];
        [parameterComponents addObjectsFromArray:newPairs];
      }
    }];
    
  }

//  else if([theValue conformsToProtocol:@protocol(NSFastEnumeration)]){
//    for (id nestedValue in theValue) {
//      NSString * newKey   = [NSString stringWithFormat:@"%@[]", theKey];
//      NSArray  * newPairs = [self queryPairsFromKey:newKey andValue:nestedValue];
//      [parameterComponents addObjectsFromArray:newPairs];
//    }
//  }
  
  else if ([theValue isKindOfClass:[NSArray class]]) {
    
    NSArray * array = (NSArray *)theValue;
    [array enumerateObjectsUsingBlock:^(id nestedValue, __unused NSUInteger idx, __unused BOOL *stop) {
      NSString * newKey   = [NSString stringWithFormat:@"%@[]", theKey];
      NSArray  * newPairs = [self queryPairsFromKey:newKey andValue:nestedValue];
      [parameterComponents addObjectsFromArray:newPairs];
    }];
    
  }
  else if ([theValue isKindOfClass:[NSSet class]]) {
    NSSet * set = (NSSet *)theValue;
    [set enumerateObjectsUsingBlock:^(id nestedValue, __unused BOOL *stop) {
      NSString * newKey   = [NSString stringWithFormat:@"%@", theKey];
      NSArray  * newPairs = [self queryPairsFromKey:newKey andValue:nestedValue];
      [parameterComponents addObjectsFromArray:newPairs];
    }];
    
  }
  else if ([theValue isKindOfClass:[NSOrderedSet class]]) {
    NSOrderedSet * orderedSet = (NSOrderedSet *)theValue;
    [orderedSet enumerateObjectsUsingBlock:^(id nestedValue, NSUInteger idx, BOOL *stop) {
      NSString * newKey   = [NSString stringWithFormat:@"%@", theKey];
      NSArray  * newPairs = [self queryPairsFromKey:newKey andValue:nestedValue];
      [parameterComponents addObjectsFromArray:newPairs];
    }];
    
  }
  
  else [parameterComponents addObject:[self queryPairFromKey:theKey andValue:theValue]];
  
  

  
  return parameterComponents;

}

-(NSDictionary *)queryPairFromKey:(NSString *)theKey andValue:(NSObject<NSFastEnumeration> *)theValue; {
  NSParameterAssert(theKey);
  NSParameterAssert(theValue);
  return @{theKey : theValue};
}

-(NSString *)URLEncodedPair:(NSDictionary *)thePair; {
  id value = thePair.allValues.firstObject;
  id key   = thePair.allKeys.firstObject;
  
  if (value == nil || [value isEqual:[NSNull null]])
    return [self escapedQueryKeyFromString:[key description]];
 
  else
    return [NSString stringWithFormat:@"%@=%@",
            [self escapedQueryKeyFromString:[key description]],
            [self escapedQueryValueFromString:[value description]]
            ];
  

}


@end


@implementation SIURLSessionRequestSerializerAbstract

@synthesize acceptableHTTPMethodsForURIEncoding = _acceptableHTTPMethodsForURIEncoding;



-(instancetype)init; {
  self = [super init];
  if(self) {
    _acceptableHTTPMethodsForURIEncoding = [NSSet setWithArray:@[@"GET", @"HEAD", @"DELETE"]];
  }
  return self;
}

+(instancetype)serializerWithOptions:(NSDictionary *)theOptions; {
  SIURLSessionRequestSerializerAbstract * serializer = [[self alloc] init];
  NSParameterAssert(serializer);
  return serializer;
}

-(void)buildURIEncodedParametersRequest:(NSURLRequest *)theRequest
                                        withParam:(NSObject<NSFastEnumeration> *)theParameters
                                            onCompletion:(SIURLSessionSerializerErrorBlock)theBlock; {
  

  NSParameterAssert(theRequest);
  NSParameterAssert(theBlock);
  NSString * queryParameters = nil;
  NSMutableURLRequest * newRequest = theRequest.mutableCopy;
  
  NSEnumerator * emumeratingParams = (NSEnumerator*)theParameters;
  if (theParameters && emumeratingParams.allObjects.count > 0 &&
           [self.acceptableHTTPMethodsForURIEncoding containsObject:theRequest.HTTPMethod.uppercaseString]) {
    queryParameters = [self queryStringFromParameters:theParameters];
    newRequest.URL = [NSURL URLWithString:[newRequest.URL.absoluteString
                                               stringByAppendingFormat:newRequest.URL.query ? @"&%@" : @"?%@", queryParameters]];
  }
  
  theBlock(newRequest, nil);
  
  
}


@end



@implementation SIURLSessionResponseSerializerAbstract


-(instancetype)init; {
  self = [super init];
  if(self) {
    _acceptableHTTPStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
  }
  return self;
}

-(void)validateResponse:(NSHTTPURLResponse *)theResponse data:(NSData *)theData onCompletion:(SIURLSessionSerializerErrorBlock)theBlock; {
  NSParameterAssert(self.acceptableHTTPStatusCodes);
  NSParameterAssert(self.acceptableMIMETypes);
  BOOL isValidResponse = YES;
  NSError * error = nil;
  if (theResponse && [theResponse isKindOfClass:[NSHTTPURLResponse class]]) {
    if ([self.acceptableHTTPStatusCodes containsIndex:(NSUInteger)theResponse.statusCode] == NO) {
      NSDictionary * userInfo = @{
                                  NSLocalizedDescriptionKey:NSLocalizedString(@"SIURLSessionBlocks Request Failed",
                                                                              @"SIURLSessionBlocks Error"),
                                  
                                  NSLocalizedFailureReasonErrorKey:
                                    [NSString stringWithFormat:NSLocalizedString(@"Request failed: %@ (%d)",
                                                                                 @"SIURLSessionBlocks"),
                                     [NSHTTPURLResponse localizedStringForStatusCode:theResponse.statusCode], theResponse.statusCode],
                                  
                                  NSURLErrorFailingURLErrorKey: theResponse.URL
                                  };
      
      error = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:userInfo];
      isValidResponse = NO;
    }
    else if (theData.length > 0 && [self.acceptableMIMETypes containsObject:theResponse.MIMEType] == NO) {
      
      
      NSDictionary * userInfo = @{
                                  NSLocalizedDescriptionKey:NSLocalizedString(@"SIURLSessionBlocks Response Serialization Failed",
                                                                              @"SIURLSessionBlocks Error"),
                                  
                                  NSLocalizedFailureReasonErrorKey:
                                    [NSString stringWithFormat:NSLocalizedStringFromTable(@"Unacceptable mime-type: %@", @"SIURLSessionBlocks", nil), theResponse.MIMEType],
                                  NSURLErrorFailingURLErrorKey:theResponse.URL
                                  };
      
      error = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:userInfo];
      isValidResponse = NO;
      
    }
  }
  
  theBlock(@(isValidResponse), error);
  
}
@end


@implementation SIURLSessionRequestSerializerJSON
@synthesize headers = _headers;

-(instancetype)init; {
  self = [super init];
  if(self) {
    _headers = @{@"Accept" : @"application/json"};
  }
  return self;
}
+(instancetype)serializerWithOptions:(NSDictionary *)theOptions; {
  SIURLSessionRequestSerializerJSON * serializer = [[self alloc] init];
  NSParameterAssert(serializer);
  if(theOptions && theOptions.count > 0) {
    NSNumber * option = theOptions.allValues.firstObject;
    serializer.JSONWritingOptions = option.unsignedIntegerValue;
  }
  return serializer;
}


-(void)buildRequest:(NSURLRequest *)theRequest
               withParameters:(NSDictionary *)theParameters
       onCompletion:(SIURLSessionSerializerErrorBlock)theBlock; {

  NSParameterAssert(theRequest);
  NSParameterAssert(theBlock);

  
  if ([self.acceptableHTTPMethodsForURIEncoding containsObject:theRequest.HTTPMethod.uppercaseString])
    [self buildURIEncodedParametersRequest:theRequest withParam:theParameters onCompletion:theBlock];

  else {
    NSMutableURLRequest * newRequest = theRequest.mutableCopy;;
    NSError * error = nil;
    [newRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:theParameters options:self.JSONWritingOptions error:&error]];
    theBlock(newRequest,error);
  }
  


}


@end

@implementation SIURLSessionResponseSerializerJSON
@synthesize headers = _headers;
@synthesize acceptableMIMETypes = _acceptableMIMETypes;

-(instancetype)init; {
  self = [super init];
  if(self) {
    _acceptableMIMETypes = [NSSet setWithArray:@[@"application/json", @"text/json", @"text/javascript"]];
    
    NSString * charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(
                                                                                       CFStringConvertNSStringEncodingToEncoding(self.stringEncoding)
                                                                                       );
    
    NSParameterAssert(charset);
    
    _headers =  @{@"Content-Type" : [NSString stringWithFormat:@"application/json; charset=%@", charset] };

  }
  return self;
}

+(instancetype)serializerWithOptions:(NSDictionary *)theOptions; {
  SIURLSessionResponseSerializerJSON * serializer = [[self alloc] init];
  NSParameterAssert(serializer);
  if(theOptions && theOptions.count > 0) {
    NSNumber * option = theOptions.allValues.firstObject;
    serializer.JSONReadingOptions = option.unsignedIntegerValue;
  }
  return serializer;
}




-(void)buildObjectForResponse:(NSURLResponse *)theResponse
               responseData:(NSData *)theResponseData
                      onCompletion:(SIURLSessionSerializerErrorBlock)theBlock; {
//  NSParameterAssert(theResponseData);
  NSParameterAssert(theBlock);

  __block id theResponseObject = nil;
  
  [self validateResponse:(NSHTTPURLResponse *)theResponse data:theResponseData onCompletion:^(id obj, NSError *error) {
    NSError * JSONParseError = nil;
    
    if(theResponseData) theResponseObject =[NSJSONSerialization JSONObjectWithData:theResponseData options:self.JSONReadingOptions error:&JSONParseError];
    if(error == nil) error = JSONParseError;
    
    theBlock(theResponseObject, error);
    
  }];
  
}


@end


@implementation NSObject (SIURLSessionBlocks)

-(SIInternalSessionConfiguration *)SI_internalSessionConfiguration; {
  return [SIInternalManager internalSessionConfigurationForURLSessionConfiguration:(NSURLSessionConfiguration *)self];
}

-(void)SI_init; {
  NSParameterAssert(self.SI_internalSessionConfiguration);
  NSURLSessionConfiguration * sessionConfiguration = (NSURLSessionConfiguration *)self;
  sessionConfiguration.SI_userAgent = nil; //use default on getter
  sessionConfiguration.SI_acceptLanguage = nil; //use default getter

}


-(SIURLSessionRequestSerializerAbstract<SIURLSessionRequestSerializing> *)SI_serializerForRequest; {
  return [self.SI_internalSessionConfiguration SI_performSelector:_cmd];
}

-(void)SI_setRequestSerializer:(SIURLSessionRequestSerializerAbstract<SIURLSessionRequestSerializing> *)theSerializer; {
  [self.SI_internalSessionConfiguration SI_performSelector:_cmd withObject:theSerializer];
  NSURLSessionConfiguration * sessionConfiguration = (NSURLSessionConfiguration *)self;
  NSMutableDictionary * headers = sessionConfiguration.HTTPAdditionalHeaders.mutableCopy;
  NSParameterAssert(headers);
  [headers addEntriesFromDictionary:theSerializer.headers];
  sessionConfiguration.HTTPAdditionalHeaders = headers.copy;
}

-(SIURLSessionResponseSerializerAbstract<SIURLSessionResponseSerializing> *)SI_serializerForResponse; {
  return [self.SI_internalSessionConfiguration SI_performSelector:_cmd];
}

-(void)SI_setResponseSerializer:(SIURLSessionResponseSerializerAbstract<SIURLSessionResponseSerializing> *)theSerializer; {
  [self.SI_internalSessionConfiguration SI_performSelector:_cmd withObject:theSerializer];
  NSURLSessionConfiguration * sessionConfiguration = (NSURLSessionConfiguration *)self;
  NSMutableDictionary * headers = sessionConfiguration.HTTPAdditionalHeaders.mutableCopy;
  NSParameterAssert(headers);
  [headers addEntriesFromDictionary:theSerializer.headers];
  sessionConfiguration.HTTPAdditionalHeaders = headers.copy;
}




-(NSString *)SI_userAgent; {
  
  
  NSString * userAgent = [self.SI_internalSessionConfiguration SI_performSelector:_cmd];
  
  if(userAgent) return userAgent;
  
  // Thanks to Matt Thomspon of AFNetworking.
  // User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43

  NSDictionary * bundleDictionary = [[NSBundle mainBundle] infoDictionary];
  UIDevice     * currentDevice    = [UIDevice currentDevice];
  

  
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
  
  userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)",
               
               [bundleDictionary objectForKey:(__bridge NSString *)kCFBundleExecutableKey]
               ?: [bundleDictionary objectForKey:(__bridge NSString *)kCFBundleIdentifierKey],
               
               (__bridge id)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey)
               ?: [bundleDictionary objectForKey:(__bridge NSString *)kCFBundleVersionKey],
               
               [currentDevice model],
               [currentDevice systemVersion],
               
               [[UIScreen mainScreen] scale]
               ];
  
#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
  userAgent = [NSString stringWithFormat:@"%@/%@ (Mac OS X %@; Scale/%0.2f)",
               
               [bundleDictionary objectForKey:(__bridge NSString *)kCFBundleExecutableKey]
               ?: [bundleDictionary objectForKey:(__bridge NSString *)kCFBundleIdentifierKey],
               
               [bundleDictionary objectForKey:@"CFBundleShortVersionString"]
               ?: [bundleDictionaryobjectForKey:(__bridge NSString *)kCFBundleVersionKey],
               
               [[NSProcessInfo processInfo] operatingSystemVersionString],
               
               [NSWindow.new.backingScaleFactor]
               ];
#endif
  
  if (userAgent) {
    if ([userAgent canBeConvertedToEncoding:NSASCIIStringEncoding] == NO) {
      NSMutableString *mutableUserAgent = userAgent.mutableCopy;
      CFStringTransform((__bridge CFMutableStringRef)(mutableUserAgent), NULL, (__bridge CFStringRef)@"Any-Latin; Latin-ASCII; [:^ASCII:] Remove", false);
      userAgent = mutableUserAgent;
    }
    
  }
  
  NSParameterAssert(userAgent);
  NSURLSessionConfiguration * sessionConfiguration = (NSURLSessionConfiguration *)self;
  sessionConfiguration.SI_userAgent = userAgent;
  return userAgent;
  
}

-(void)SI_setUserAgent:(NSString *)SI_userAgent; {
  [self.SI_internalSessionConfiguration SI_performSelector:_cmd withObject:SI_userAgent];
  NSURLSessionConfiguration * sessionConfiguration = (NSURLSessionConfiguration *)self;
  NSMutableDictionary * headers = sessionConfiguration.HTTPAdditionalHeaders.mutableCopy;
  NSParameterAssert(headers);
  [headers addEntriesFromDictionary:@{@"User-Agent" : self.SI_userAgent }];
  sessionConfiguration.HTTPAdditionalHeaders = headers.copy;
}


-(NSString *)SI_acceptLanguage; {
  
  
  NSString * acceptLanguage = [self.SI_internalSessionConfiguration SI_performSelector:_cmd];
  
  if(acceptLanguage) return acceptLanguage;
  
  // Thanks to Matt Thomspon of AFNetworking.
  // Accept-Language HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4
  
  NSMutableArray *acceptLanguagesComponents = @[].mutableCopy;
  [[NSLocale preferredLanguages] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    CGFloat q = 1.0f - (idx * 0.1f);
    [acceptLanguagesComponents addObject:[NSString stringWithFormat:@"%@;q=%0.1g", obj, q]];
    if(q <= 0.5f) *stop = YES;
  }];
  
  acceptLanguage = [acceptLanguagesComponents componentsJoinedByString:@", "];
  NSParameterAssert(acceptLanguage);
  NSURLSessionConfiguration * sessionConfiguration = (NSURLSessionConfiguration *)self;
  sessionConfiguration.SI_acceptLanguage = acceptLanguage;
  return acceptLanguage;
  
}

-(void)SI_setAcceptLanguage:(NSString *)SI_acceptLanguage; {
  [self.SI_internalSessionConfiguration SI_performSelector:_cmd withObject:SI_acceptLanguage];
  NSURLSessionConfiguration * sessionConfiguration = (NSURLSessionConfiguration *)self;
  NSMutableDictionary * headers = sessionConfiguration.HTTPAdditionalHeaders.mutableCopy;
  NSParameterAssert(headers);
  [headers addEntriesFromDictionary:@{@"Accept-Language" : self.SI_acceptLanguage }];
  sessionConfiguration.HTTPAdditionalHeaders = headers.copy;
  
}



@end
