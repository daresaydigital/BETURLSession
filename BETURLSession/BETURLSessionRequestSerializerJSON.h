
#import "BETURLSessionAbstractSerializer.h"

@interface BETURLSessionRequestSerializerJSON : BETURLSessionRequestSerializer
<BETURLSessionRequestSerializing>
+(instancetype)serializerWithJSONWritingOptions:(NSJSONWritingOptions)theJSONWritingOptions;
@end
