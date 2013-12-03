



@class SIURLSessionResponseSerializer;
@class SIURLSessionRequestSerializer;

@protocol SIURLSessionRequestSerializing;
@protocol SIURLSessionResponseSerializing;

@interface NSURLSession (SIHTTPCoreSerializers)

@property(readonly)
SIURLSessionRequestSerializer<SIURLSessionRequestSerializing>    * SI_serializerForRequest;

@property(readonly)
SIURLSessionResponseSerializer<SIURLSessionResponseSerializing>  * SI_serializerForResponse;

@end


typedef void (^SIURLSessionSerializerErrorBlock)(id obj, NSError * error);

@protocol SIURLSessionSerializing <NSObject>
@required
+(instancetype)serializerWithOptions:(NSDictionary *)theOptions;

@end

@protocol SIURLSessionRequestSerializing <SIURLSessionSerializing>
@required
@property(nonatomic,readonly) NSString * contentTypeHeader;
@end

@protocol SIURLSessionResponseSerializing <SIURLSessionSerializing>
@required
@property(nonatomic,readonly) NSSet         * acceptableMIMETypes;
@property(nonatomic,readonly) NSString      * acceptHeader;
-(void)buildObjectForResponse:(NSURLResponse *)theResponse
                 responseData:(NSData *)theResponseData
                 onCompletion:(SIURLSessionSerializerErrorBlock)theBlock;

@end


@interface SIURLSessionSerializer : NSObject
@property(nonatomic,readonly) NSStringEncoding stringEncoding;
@property(nonatomic,readonly) NSString * charset;
-(NSString *)queryStringFromParameters:(NSObject<NSFastEnumeration> *)theParameters;
-(NSArray *)queryPairsFromKey:(NSString *)theKey andValue:(NSObject<NSFastEnumeration> *)theValue;
-(NSDictionary *)queryPairFromKey:(NSString *)theKey andValue:(NSObject<NSFastEnumeration> *)theValue;
-(NSString *)URLEncodedPair:(NSDictionary *)thePair;
-(NSString *)escapedQueryKeyFromString:(NSString *)theKey;
-(NSString *)escapedQueryValueFromString:(NSString *)theValue;



@end

@interface SIURLSessionRequestSerializer : SIURLSessionSerializer
@property(nonatomic,readonly) NSString * acceptLanguageHeader;
@property(nonatomic,readonly) NSString * userAgentHeader;
@property(nonatomic,readonly) NSSet    * acceptableHTTPMethodsForURIEncoding;
@property(nonatomic,copy) NSDictionary * HTTPAdditionalHeaders;
-(void)setValue:(id)value forHTTPHeaderField:(NSString *)theHTTPHeaderField;

-(void)buildRequest:(NSURLRequest *)theRequest
     withParameters:(NSDictionary *)theParameters
       onCompletion:(SIURLSessionSerializerErrorBlock)theBlock;

@end



@interface SIURLSessionResponseSerializer : SIURLSessionSerializer

@property(nonatomic,readonly) NSIndexSet    * acceptableHTTPStatusCodes;
-(void)validateResponse:(NSHTTPURLResponse *)theResponse
                   data:(NSData *)theData
                  onCompletion:(SIURLSessionSerializerErrorBlock)theBlock;
@end






@interface SIURLSessionRequestSerializerJSON : SIURLSessionRequestSerializer
<SIURLSessionRequestSerializing>
@end

@interface SIURLSessionResponseSerializerJSON : SIURLSessionResponseSerializer
<SIURLSessionResponseSerializing>
@end

@interface SIURLSessionRequestSerializerFormURLEncoding : SIURLSessionRequestSerializer
<SIURLSessionRequestSerializing>
@end
