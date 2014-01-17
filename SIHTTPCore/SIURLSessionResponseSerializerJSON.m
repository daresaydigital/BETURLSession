#import "SIURLSessionResponseSerializerJSON.h"





@interface SIURLSessionResponseSerializerJSON ()
@property(nonatomic,assign) NSJSONReadingOptions JSONReadingOptions;
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

+(instancetype)serializerWithJSONReadingOptions:(NSJSONReadingOptions)theJSONReadingOptions; {
  SIURLSessionResponseSerializerJSON * serializer = [[self alloc] init];
  serializer.JSONReadingOptions  = theJSONReadingOptions;
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