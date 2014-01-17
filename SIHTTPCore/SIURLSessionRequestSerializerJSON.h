
#import "SIURLSessionSerializers.h"

@interface SIURLSessionRequestSerializerJSON : SIURLSessionRequestSerializer
<SIURLSessionRequestSerializing>
+(instancetype)serializerWithJSONWritingOptions:(NSJSONWritingOptions)theJSONWritingOptions;
@end
