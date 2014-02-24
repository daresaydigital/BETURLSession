
#import "BETURLSessionRequestSerializerJSON.h"


@interface BETURLSessionRequestSerializerJSON ()
@property(nonatomic,assign) NSJSONWritingOptions JSONWritingOptions;
@end

@implementation BETURLSessionRequestSerializerJSON
@synthesize contentTypeHeader = _contentTypeHeader;

-(instancetype)init; {
  self = [super init];
  if(self) {
    _contentTypeHeader =  [NSString stringWithFormat:@"application/json; charset=%@", self.charset] ;
  }
  return self;
}

+(instancetype)serializerWithJSONWritingOptions:(NSJSONWritingOptions)theJSONWritingOptions; {
  BETURLSessionRequestSerializerJSON * serializer = [[self alloc] init];
  serializer.JSONWritingOptions = theJSONWritingOptions;
  return serializer;
}


-(void)buildRequest:(NSURLRequest *)theRequest
     withParameters:(NSDictionary *)theParameters
       onCompletion:(BETURLSessionSerializerErrorBlock)theBlock; {
  
  NSParameterAssert(theRequest);
  NSParameterAssert(theBlock);
  if ([self.acceptableHTTPMethodsForURIEncoding containsObject:theRequest.HTTPMethod.uppercaseString]) {
    [super buildRequest:theRequest withParameters:theParameters onCompletion:theBlock];
  }
  
  else {
    NSMutableURLRequest * newRequest = theRequest.mutableCopy;
    NSError * error = nil;
    newRequest.HTTPBody =[NSJSONSerialization dataWithJSONObject:theParameters options:self.JSONWritingOptions error:&error];
    [newRequest setValue:@(newRequest.HTTPBody.length).stringValue forHTTPHeaderField:@"Content-Length"];


    theBlock(newRequest,error);
  }
  
  
  
}


@end