

#warning Clean up serializes with protocols and etc
#warning Make image serializers.


@class SIURLSessionResponseSerializer;
@class SIURLSessionRequestSerializer;

@protocol SIURLSessionRequestSerializing;
@protocol SIURLSessionResponseSerializing;

@interface NSURLSession (SIURLSessionBlocksSerializers)

@property(readonly)  SIURLSessionRequestSerializer<SIURLSessionRequestSerializing>    * SI_serializerForRequest;
@property(readonly)  SIURLSessionResponseSerializer<SIURLSessionResponseSerializing>  * SI_serializerForResponse;

@end


typedef void (^SIURLSessionSerializerErrorBlock)(id obj, NSError * error);

@protocol SIURLSessionSerializing <NSObject>
@required
@property(nonatomic,readonly) NSDictionary * headers;
+(instancetype)serializerWithOptions:(NSDictionary *)theOptions;

@end

@protocol SIURLSessionRequestSerializing <SIURLSessionSerializing>
@required
-(void)buildRequest:(NSURLRequest *)theRequest
               withParameters:(NSDictionary *)theParameters
                        onCompletion:(SIURLSessionSerializerErrorBlock)theBlock;
@end

@protocol SIURLSessionResponseSerializing <SIURLSessionSerializing>
@required
@property(nonatomic,readonly) NSSet         * acceptableMIMETypes;
-(void)buildObjectForResponse:(NSURLResponse *)theResponse
               responseData:(NSData *)theResponseData
                      onCompletion:(SIURLSessionSerializerErrorBlock)theBlock;

@end


@interface SIURLSessionSerializer : NSObject
@property(nonatomic,readonly) NSStringEncoding stringEncoding;

-(NSString *)queryStringFromParameters:(NSObject<NSFastEnumeration> *)theParameters;

-(NSArray *)queryPairsFromKey:(NSString *)theKey andValue:(NSObject<NSFastEnumeration> *)theValue;
-(NSDictionary *)queryPairFromKey:(NSString *)theKey andValue:(NSObject<NSFastEnumeration> *)theValue;
-(NSString *)URLEncodedPair:(NSDictionary *)thePair;


@end

@interface SIURLSessionRequestSerializer : SIURLSessionSerializer
@property(nonatomic,readonly) NSSet         * acceptableHTTPMethodsForURIEncoding;
-(void)buildURIEncodedParametersRequest:(NSURLRequest *)theRequest
                                   withParam:(NSObject<NSFastEnumeration> *)theParameters
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