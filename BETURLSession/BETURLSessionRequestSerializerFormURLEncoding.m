
#import "BETURLSessionRequestSerializerFormURLEncoding.h"

@implementation BETURLSessionRequestSerializerFormURLEncoding
@synthesize contentTypeHeader = _contentTypeHeader;

-(instancetype)init; {
  self = [super init];
  if(self) {
    _contentTypeHeader =[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", self.charset];
  }
  return self;
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