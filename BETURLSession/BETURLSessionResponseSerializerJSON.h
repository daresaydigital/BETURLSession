
#import "BETURLSessionAbstractSerializer.h"

@interface BETURLSessionResponseSerializerJSON : BETURLSessionResponseSerializer
<BETURLSessionResponseSerializing>
+(instancetype)serializerWithJSONReadingOptions:(NSJSONReadingOptions)theJSONReadingOptions withoutNull:(BOOL)theNoNullFlag;
@end
