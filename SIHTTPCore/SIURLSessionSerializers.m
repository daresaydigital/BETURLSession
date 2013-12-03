
#import "SIURLSessionSerializers.h"

#import "NSURLSession+SIHTTPCore.h"
#import "NSURLSessionTask+SIHTTPCore.h"


#import "__SIInternalManager.h"
#include "SIInternalShared.private"



@interface SIURLSessionRequestSerializerJSON ()
@property(nonatomic,assign) NSJSONWritingOptions JSONWritingOptions;
@end

@interface SIURLSessionResponseSerializerJSON ()
@property(nonatomic,assign) NSJSONReadingOptions JSONReadingOptions;
@end

static NSString * const SIURLSessionSerializerAbstractUnescapedInQueryStringPairKeyCharacters = @"[].";
static NSString * const SIURLSessionSerializerAbstractEscapedInQueryStringCharacters          = @":/?&=;+!@#$()',*";

@interface SIURLSessionSerializer (Private)
@property(nonatomic,readonly) NSSet         * acceptableMIMETypes;

@end

@implementation SIURLSessionSerializer
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
    NSString * charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(
                                                                                       CFStringConvertNSStringEncodingToEncoding(self.stringEncoding)
                                                                                       );
    
    NSParameterAssert(charset);
    _charset = [charset uppercaseString];

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

  else if([theValue conformsToProtocol:@protocol(NSFastEnumeration)]){
    for (id nestedValue in theValue) {
      NSString * newKey   = [NSString stringWithFormat:@"%@[]", theKey];
      NSArray  * newPairs = [self queryPairsFromKey:newKey andValue:nestedValue];
      [parameterComponents addObjectsFromArray:newPairs];
    }
  }
  
//  else if ([theValue isKindOfClass:[NSArray class]]) {
//    
//    NSArray * array = (NSArray *)theValue;
//    [array enumerateObjectsUsingBlock:^(id nestedValue, __unused NSUInteger idx, __unused BOOL *stop) {
//      NSString * newKey   = [NSString stringWithFormat:@"%@[]", theKey];
//      NSArray  * newPairs = [self queryPairsFromKey:newKey andValue:nestedValue];
//      [parameterComponents addObjectsFromArray:newPairs];
//    }];
//    
//  }
//  else if ([theValue isKindOfClass:[NSSet class]]) {
//    NSSet * set = (NSSet *)theValue;
//    [set enumerateObjectsUsingBlock:^(id nestedValue, __unused BOOL *stop) {
//      NSString * newKey   = [NSString stringWithFormat:@"%@", theKey];
//      NSArray  * newPairs = [self queryPairsFromKey:newKey andValue:nestedValue];
//      [parameterComponents addObjectsFromArray:newPairs];
//    }];
//    
//  }
//  else if ([theValue isKindOfClass:[NSOrderedSet class]]) {
//    NSOrderedSet * orderedSet = (NSOrderedSet *)theValue;
//    [orderedSet enumerateObjectsUsingBlock:^(id nestedValue, NSUInteger idx, BOOL *stop) {
//      NSString * newKey   = [NSString stringWithFormat:@"%@", theKey];
//      NSArray  * newPairs = [self queryPairsFromKey:newKey andValue:nestedValue];
//      [parameterComponents addObjectsFromArray:newPairs];
//    }];
//    
//  }
  
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


@implementation SIURLSessionRequestSerializer





-(instancetype)init; {
  self = [super init];
  if(self) {
    self.HTTPAdditionalHeaders = @{};
    _acceptableHTTPMethodsForURIEncoding = [NSSet setWithArray:@[@"GET", @"HEAD", @"DELETE"]];
    // Thanks to Matt Thomspon of AFNetworking.
    // Accept-Language HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4
    
    NSMutableArray *acceptLanguagesComponents = @[].mutableCopy;
    [[NSLocale preferredLanguages] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      CGFloat q = 1.0f - (idx * 0.1f);
      [acceptLanguagesComponents addObject:[NSString stringWithFormat:@"%@;q=%0.1g", obj, q]];
      if(q <= 0.5f) *stop = YES;
    }];
    
    NSString * acceptLanguage = [acceptLanguagesComponents componentsJoinedByString:@", "];
    NSParameterAssert(acceptLanguage);
    _acceptLanguageHeader = acceptLanguage;
    
    
    // Thanks to Matt Thomspon of AFNetworking.
    // User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
    
    NSDictionary * bundleDictionary = [[NSBundle mainBundle] infoDictionary];
    UIDevice     * currentDevice    = [UIDevice currentDevice];
    NSString * userAgent = nil;
    
    
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
    _userAgentHeader = userAgent;
    
  }
  return self;
}

+(instancetype)serializerWithOptions:(NSDictionary *)theOptions; {
  SIURLSessionRequestSerializer * serializer = [[self alloc] init];
  NSParameterAssert(serializer);
  return serializer;
}

-(void)setValue:(id)value forHTTPHeaderField:(NSString *)theHTTPHeaderField; {
  NSParameterAssert(theHTTPHeaderField);
  NSMutableDictionary * HTTPHeaders = self.HTTPAdditionalHeaders.mutableCopy;
  if(value) HTTPHeaders[theHTTPHeaderField] = value;
  else [HTTPHeaders removeObjectForKey:theHTTPHeaderField];
  self.HTTPAdditionalHeaders = HTTPHeaders;
}

-(void)buildRequest:(NSURLRequest *)theRequest
     withParameters:(NSDictionary *)theParameters
       onCompletion:(SIURLSessionSerializerErrorBlock)theBlock; {
  
  NSParameterAssert(theRequest);
  NSParameterAssert(theBlock);
  

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



@implementation SIURLSessionResponseSerializer


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
                                  NSLocalizedDescriptionKey:NSLocalizedString(@"SIHTTPCore Request Failed",
                                                                              @"SIHTTPCore Error"),
                                  
                                  NSLocalizedFailureReasonErrorKey:
                                    [NSString stringWithFormat:NSLocalizedString(@"Request failed: %@ (%d)",
                                                                                 @"SIHTTPCore"),
                                     [NSHTTPURLResponse localizedStringForStatusCode:theResponse.statusCode], theResponse.statusCode],
                                  
                                  NSURLErrorFailingURLErrorKey: theResponse.URL
                                  };
      
      error = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:userInfo];
      isValidResponse = NO;
    }
    else if ([self.acceptableMIMETypes containsObject:theResponse.MIMEType] == NO) {
      
      if(theData.length > 0 ){
        NSDictionary * userInfo = @{
                                  NSLocalizedDescriptionKey:NSLocalizedString(@"SIHTTPCore Response Serialization Failed",
                                                                              @"SIHTTPCore Error"),
                                  
                                  NSLocalizedFailureReasonErrorKey:
                                    [NSString stringWithFormat:NSLocalizedStringFromTable(@"Unacceptable mime-type: %@", @"SIHTTPCore", nil), theResponse.MIMEType],
                                  NSURLErrorFailingURLErrorKey:theResponse.URL
                                  };
      
        error = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:userInfo];
        isValidResponse = NO;
      }
      
    }
  }
  
  theBlock(@(isValidResponse), error);
  
}
@end


@implementation SIURLSessionRequestSerializerJSON
@synthesize contentTypeHeader = _contentTypeHeader;

-(instancetype)init; {
  self = [super init];
  if(self) {
    
    _contentTypeHeader =  [NSString stringWithFormat:@"application/json; charset=%@", self.charset] ;
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
  if ([self.acceptableHTTPMethodsForURIEncoding containsObject:theRequest.HTTPMethod.uppercaseString]) {
    [super buildRequest:theRequest withParameters:theParameters onCompletion:theBlock];
  }

  else {
    NSMutableURLRequest * newRequest = theRequest.mutableCopy;;
    NSError * error = nil;
    [newRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:theParameters options:self.JSONWritingOptions error:&error]];
    theBlock(newRequest,error);
  }
  


}


@end

@implementation SIURLSessionResponseSerializerJSON
@synthesize acceptHeader = _acceptHeader;
@synthesize acceptableMIMETypes = _acceptableMIMETypes;

-(instancetype)init; {
  self = [super init];
  if(self) {
    _acceptableMIMETypes = [NSSet setWithArray:@[@"application/json", @"text/json", @"text/javascript"]];
    _acceptHeader = [_acceptableMIMETypes.allObjects componentsJoinedByString:@","];
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

  NSParameterAssert(theBlock);

  __block id theResponseObject = nil;
  
  [self validateResponse:(NSHTTPURLResponse *)theResponse data:theResponseData onCompletion:^(id obj, NSError *error) {
    NSError * JSONParseError = nil;
    
    if(theResponseData) theResponseObject =[NSJSONSerialization JSONObjectWithData:theResponseData options:self.JSONReadingOptions error:&JSONParseError];

    
    theBlock(theResponseObject, error);
    
  }];
  
}

@end

@implementation SIURLSessionRequestSerializerFormURLEncoding
@synthesize contentTypeHeader = _contentTypeHeader;

-(instancetype)init; {
  self = [super init];
  if(self) {
    

    _contentTypeHeader =[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", self.charset];
  }
  return self;
}

+(instancetype)serializerWithOptions:(NSDictionary *)theOptions; {
  SIURLSessionRequestSerializerFormURLEncoding * serializer = [[self alloc] init];
  NSParameterAssert(serializer);
  return serializer;
}

-(void)buildRequest:(NSURLRequest *)theRequest
     withParameters:(NSDictionary *)theParameters
       onCompletion:(SIURLSessionSerializerErrorBlock)theBlock; {
  
  NSParameterAssert(theRequest);
  NSParameterAssert(theBlock);
  
  
  if ([self.acceptableHTTPMethodsForURIEncoding containsObject:theRequest.HTTPMethod.uppercaseString]) {
    [super buildRequest:theRequest withParameters:theParameters onCompletion:theBlock];
  }
  else {
    NSMutableURLRequest * newRequest = theRequest.mutableCopy;;
    NSError * error = nil;
    NSString  * bodyParameters = [self queryStringFromParameters:theParameters];
    NSData * bodyParameterData = [bodyParameters dataUsingEncoding:self.stringEncoding allowLossyConversion:YES];
    [newRequest setValue:@(bodyParameterData.length).stringValue forHTTPHeaderField:@"Content-Length"];
    newRequest.HTTPBody = bodyParameterData;
    theBlock(newRequest,error);
  }
  
  
  
}


@end


@implementation NSObject (SIHTTPCoreSerializers)

-(SIURLSessionRequestSerializer<SIURLSessionRequestSerializing> *)SI_serializerForRequest; {
  NSURLSession * session = (NSURLSession *)self;
  return [session.SI_internalSession SI_performSelector:_cmd];
}

-(void)SI_setRequestSerializer:(SIURLSessionRequestSerializer<SIURLSessionRequestSerializing> *)theSerializer; {
  NSURLSession * session = (NSURLSession *)self;
  [session.SI_internalSession SI_performSelector:_cmd withObject:theSerializer];
}

-(SIURLSessionResponseSerializer<SIURLSessionResponseSerializing> *)SI_serializerForResponse; {
  NSURLSession * session = (NSURLSession *)self;
  return [session.SI_internalSession SI_performSelector:_cmd];

}

-(void)SI_setResponseSerializer:(SIURLSessionResponseSerializer<SIURLSessionResponseSerializing> *)theSerializer; {
  NSURLSession * session = (NSURLSession *)self;
  [session.SI_internalSession SI_performSelector:_cmd withObject:theSerializer];
}




@end
