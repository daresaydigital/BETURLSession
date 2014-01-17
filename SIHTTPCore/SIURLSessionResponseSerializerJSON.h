
#import "SIURLSessionSerializers.h"

@interface SIURLSessionResponseSerializerJSON : SIURLSessionResponseSerializer
<SIURLSessionResponseSerializing>
+(instancetype)serializerWithJSONReadingOptions:(NSJSONReadingOptions)theJSONReadingOptions;
@end
