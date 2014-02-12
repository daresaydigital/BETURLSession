



@class BETURLSessionResponseSerializer;
@class BETURLSessionRequestSerializer;

@protocol BETURLSessionRequestSerializing;
@protocol BETURLSessionResponseSerializing;

@interface NSURLSession (BETURLSessionSerializers)

@property(readonly)
BETURLSessionRequestSerializer<BETURLSessionRequestSerializing>    * bet_serializerForRequest;

@property(readonly)
BETURLSessionResponseSerializer<BETURLSessionResponseSerializing>  * bet_serializerForResponse;
@end


typedef void (^BETURLSessionSerializerErrorBlock)(id obj, NSError * error);


@protocol BETURLSessionRequestSerializing <NSObject>
@required
@property(nonatomic,readonly) NSString * contentTypeHeader;
@end

@protocol BETURLSessionResponseSerializing <NSObject>
@required
@property(nonatomic,readonly) NSSet         * acceptableMIMETypes;
@property(nonatomic,readonly) NSString      * acceptHeader;
-(void)buildObjectForResponse:(NSURLResponse *)theResponse
                 responseData:(NSData *)theResponseData
                 onCompletion:(BETURLSessionSerializerErrorBlock)theBlock;

@end


@interface BETURLSessionSerializer : NSObject
@property(nonatomic,readonly) NSStringEncoding stringEncoding;
@property(nonatomic,readonly) NSString * charset;
-(NSString *)queryStringFromParameters:(NSObject<NSFastEnumeration> *)theParameters;
-(NSArray *)queryPairsFromKey:(NSString *)theKey andValue:(NSObject<NSFastEnumeration> *)theValue;
-(NSDictionary *)queryPairFromKey:(NSString *)theKey andValue:(NSObject<NSFastEnumeration> *)theValue;
-(NSString *)URLEncodedPair:(NSDictionary *)thePair;
-(NSString *)escapedQueryKeyFromString:(NSString *)theKey;
-(NSString *)escapedQueryValueFromString:(NSString *)theValue;
-(NSDictionary *)queryDictionaryFromString:(NSString *)theQueryString;
@end

@interface BETURLSessionRequestSerializer : BETURLSessionSerializer
@property(nonatomic,readonly) NSString * acceptLanguageHeader;
@property(nonatomic,readonly) NSString * userAgentHeader;
@property(nonatomic,readonly) NSSet    * acceptableHTTPMethodsForURIEncoding;
@property(nonatomic,copy) NSDictionary * HTTPAdditionalHeaders;
-(void)setValue:(id)value forHTTPHeaderField:(NSString *)theHTTPHeaderField;
-(void)buildRequest:(NSURLRequest *)theRequest
     withParameters:(NSDictionary *)theParameters
       onCompletion:(BETURLSessionSerializerErrorBlock)theBlock;

@end



@interface BETURLSessionResponseSerializer : BETURLSessionSerializer

@property(nonatomic,readonly) NSIndexSet    * acceptableHTTPStatusCodes;
-(void)validateResponse:(NSHTTPURLResponse *)theResponse
                   data:(NSData *)theData
                  onCompletion:(BETURLSessionSerializerErrorBlock)theBlock;
@end








