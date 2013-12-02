
#import "SIURLSessionSerializers.h"

#import "NSURLSession+SIURLSessionBlocks.h"
#import "NSURLSessionTask+SIURLSessionBlocks.h"


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


@implementation SIURLSessionRequestSerializer

@synthesize acceptableHTTPMethodsForURIEncoding = _acceptableHTTPMethodsForURIEncoding;



-(instancetype)init; {
  self = [super init];
  if(self) {
    _acceptableHTTPMethodsForURIEncoding = [NSSet setWithArray:@[@"GET", @"HEAD", @"DELETE"]];
  }
  return self;
}

+(instancetype)serializerWithOptions:(NSDictionary *)theOptions; {
  SIURLSessionRequestSerializer * serializer = [[self alloc] init];
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
  
#warning Errror handling should be with parent class, at least a portion of it in regards with creating the NSError objects
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
    else if ([self.acceptableMIMETypes containsObject:theResponse.MIMEType] == NO) {
      
      if(theData.length > 0 ){
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
  }
  
  theBlock(@(isValidResponse), error);
  
}
@end


@implementation SIURLSessionRequestSerializerJSON
@synthesize headers = _headers;

-(instancetype)init; {
  self = [super init];
  if(self) {
    
    _headers =  @{@"Content-Type" : [NSString stringWithFormat:@"application/json; charset=%@", self.charset] };
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

#warning Add validators
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
    _headers = @{@"Accept" : [_acceptableMIMETypes.allObjects componentsJoinedByString:@","]};
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
@synthesize headers = _headers;
-(instancetype)init; {
  self = [super init];
  if(self) {
    

    _headers = @{@"Content-Type" : [NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", self.charset] };
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
  
  
  if ([self.acceptableHTTPMethodsForURIEncoding containsObject:theRequest.HTTPMethod.uppercaseString])
    [self buildURIEncodedParametersRequest:theRequest withParam:theParameters onCompletion:theBlock];
  
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


@implementation NSObject (SIURLSessionBlocksSerializers)

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
