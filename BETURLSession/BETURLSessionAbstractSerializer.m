
#import "BETURLSessionAbstractSerializer.h"

#import "NSURLSession+BETURLSession.h"
#import "NSURLSessionTask+BETURLSession.h"


#import "__BETInternalManager.h"
#include "__BETInternalShared.private"


@implementation NSObject (BETURLSessionSerializers)

-(BETURLSessionRequestSerializer<BETURLSessionRequestSerializing> *)bet_serializerForRequest; {
  NSURLSession * session = (NSURLSession *)self;
  return [session.bet_internalSession bet_performSelector:_cmd];
}

-(void)bet_setRequestSerializer:(BETURLSessionRequestSerializer<BETURLSessionRequestSerializing> *)theSerializer; {
  NSURLSession * session = (NSURLSession *)self;
  [session.bet_internalSession bet_performSelector:_cmd withObject:theSerializer];
}

-(BETURLSessionResponseSerializer<BETURLSessionResponseSerializing> *)bet_serializerForResponse; {
  NSURLSession * session = (NSURLSession *)self;
  return [session.bet_internalSession bet_performSelector:_cmd];
  
}

-(void)bet_setResponseSerializer:(BETURLSessionResponseSerializer<BETURLSessionResponseSerializing> *)theSerializer; {
  NSURLSession * session = (NSURLSession *)self;
  [session.bet_internalSession bet_performSelector:_cmd withObject:theSerializer];
}
@end




static NSString * const BETURLSessionSerializerAbstractUnescapedInQueryStringPairKeyCharacters = @"[].";
static NSString * const BETURLSessionSerializerAbstractEscapedInQueryStringCharacters          = @":/?&=;+!@#$()',*";

@interface BETURLSessionSerializer (Private)
@property(nonatomic,readonly) NSSet         * acceptableMIMETypes;

@end

@implementation BETURLSessionSerializer
-(NSString *)escapedQueryKeyFromString:(NSString *)theKey; {
  return (__bridge_transfer  NSString *)
  CFURLCreateStringByAddingPercentEscapes(
                                          kCFAllocatorDefault,
                                          (__bridge CFStringRef)theKey,
                                          (__bridge CFStringRef)BETURLSessionSerializerAbstractUnescapedInQueryStringPairKeyCharacters,
                                          (__bridge CFStringRef)BETURLSessionSerializerAbstractEscapedInQueryStringCharacters,
                                          CFStringConvertNSStringEncodingToEncoding(self.stringEncoding)
                                          );
 
}
-(NSString *)escapedQueryValueFromString:(NSString *)theValue; {
  return (__bridge_transfer  NSString *)
  CFURLCreateStringByAddingPercentEscapes(
                                          kCFAllocatorDefault,
                                          (__bridge CFStringRef)theValue,
                                          NULL,
                                          (__bridge CFStringRef)BETURLSessionSerializerAbstractEscapedInQueryStringCharacters, CFStringConvertNSStringEncodingToEncoding(self.stringEncoding)
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

-(NSDictionary *)queryDictionaryFromString:(NSString *)theQueryString; {
  //Duplicated code, needs to go to BETURLSession
  NSMutableDictionary * params = @{}.mutableCopy;
  [[theQueryString componentsSeparatedByString:@"&"] enumerateObjectsUsingBlock:^(NSString * param, __unused NSUInteger idx, __unused  BOOL *stop) {
    NSArray * parts = [param componentsSeparatedByString:@"="];
    if(parts.count < 2) return;
    [params setObject:[parts objectAtIndex:1] forKey:[parts objectAtIndex:0]];
  }];
  return params.copy;

}

@end


@implementation BETURLSessionRequestSerializer





-(instancetype)init; {
  self = [super init];
  if(self) {
    self.HTTPAdditionalHeaders = @{};
    _acceptableHTTPMethodsForURIEncoding = [NSSet setWithArray:@[@"GET", @"HEAD", @"DELETE"]];
    // Similar to AFNetworking.
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
    
    
    // similar to AFNetworking.
    // User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
    
    NSDictionary * bundleDictionary = [[NSBundle mainBundle] infoDictionary];

    NSString * userAgent = nil;
    
    
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    UIDevice     * currentDevice    = [UIDevice currentDevice];    
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
                 ?: [bundleDictionary objectForKey:(__bridge NSString *)kCFBundleVersionKey],
                 
                 [[NSProcessInfo processInfo] operatingSystemVersionString],
                 
                 NSWindow.new.backingScaleFactor
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


-(void)setValue:(id)value forHTTPHeaderField:(NSString *)theHTTPHeaderField; {
  NSParameterAssert(theHTTPHeaderField);
  NSMutableDictionary * HTTPHeaders = self.HTTPAdditionalHeaders.mutableCopy;
  if(value) HTTPHeaders[theHTTPHeaderField] = value;
  else [HTTPHeaders removeObjectForKey:theHTTPHeaderField];
  self.HTTPAdditionalHeaders = HTTPHeaders;
}

-(void)buildRequest:(NSURLRequest *)theRequest
     withParameters:(NSDictionary *)theParameters
       onCompletion:(BETURLSessionSerializerErrorBlock)theBlock; {
  
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



@implementation BETURLSessionResponseSerializer


-(instancetype)init; {
  self = [super init];
  if(self) {
    _acceptableHTTPStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
  }
  return self;
}

-(void)validateResponse:(NSHTTPURLResponse *)theResponse data:(NSData *)theData onCompletion:(BETURLSessionSerializerErrorBlock)theBlock; {
  NSParameterAssert(self.acceptableHTTPStatusCodes);
  NSParameterAssert(self.acceptableMIMETypes);
  BOOL isValidResponse = YES;
  NSError * error = nil;
  id theResponseObject = nil;
  NSString *localizedDescriptionString;
    if(theData) {
        theResponseObject =[NSJSONSerialization JSONObjectWithData:theData options:NSJSONWritingPrettyPrinted|| NSJSONReadingMutableContainers error:nil];
        NSLog(@"error message %@",theResponseObject[@"error"]);
    }
    localizedDescriptionString = theResponseObject[@"error"] ?
                                 theResponseObject[@"error"] : NSLocalizedString(@"BETURLSession Request Failed",@"BETURLSession Error");
    

  if (theResponse && [theResponse isKindOfClass:[NSHTTPURLResponse class]]) {
    if ([self.acceptableHTTPStatusCodes containsIndex:(NSUInteger)theResponse.statusCode] == NO) {
      

        
      NSDictionary * userInfo = @{
                                  NSLocalizedDescriptionKey:localizedDescriptionString,
                                  NSLocalizedFailureReasonErrorKey:
                                    [NSString stringWithFormat:NSLocalizedString(@"Request failed: %@ (%d)",
                                                                                 @"BETURLSession"),
                                     [NSHTTPURLResponse localizedStringForStatusCode:theResponse.statusCode], theResponse.statusCode],
                                  
                                  NSURLErrorFailingURLErrorKey: theResponse.URL,
                                  NSStringEncodingErrorKey : @(theResponse.statusCode)
                                  };
      
      error = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:userInfo];
      isValidResponse = NO;
    }
    else if ([self.acceptableMIMETypes containsObject:theResponse.MIMEType] == NO) {
      
      if(theData.length > 0 ){
        NSDictionary * userInfo = @{
                                  NSLocalizedDescriptionKey:NSLocalizedString(@"BETURLSession Response Serialization Failed",
                                                                              @"BETURLSession Error"),
                                  
                                  NSLocalizedFailureReasonErrorKey:
                                    [NSString stringWithFormat:NSLocalizedStringFromTable(@"Unacceptable mime-type: %@", @"BETURLSession", nil), theResponse.MIMEType],
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
