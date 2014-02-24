#import "BETResponse.h"

@implementation BETResponse
-(instancetype)initWithResponseWithResponseObject:(id<NSFastEnumeration,NSObject>)theResponseObject
                          HTTPURLResponse:(NSHTTPURLResponse *)theHTTPURLResponse
                          URLSessionTask:(NSURLSessionTask *)theURLSessionTask
                                    error:(NSError *)theError; {
  self = [super init];
  if(self) {
    _content = theResponseObject;
    _HTTPURLResponse = theHTTPURLResponse;
    _error = theError;
    _task = theURLSessionTask;
  }
  return self;
  
}

-(NSString *)description; {
  NSString * superDescription = [super description];
  NSString * description = [NSString stringWithFormat:@"\n %@ \n %@ \n %@ \n %@ \n ",
                            self.content,
                            self.HTTPURLResponse,
                            self.task,
                            self.error
                            ];
  
  return [superDescription stringByAppendingString:description];
}

@end
