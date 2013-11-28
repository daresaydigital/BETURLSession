

//#define SIStaticConstString(X) static NSString * const X = @#X

//SHStaticConstString(SH_blockShouldBeginEditing);


@class SIURLSessionResponseSerializerAbstract;
@class SIURLSessionRequestSerializerAbstract;

@protocol SIURLSessionRequestSerializing;
@protocol SIURLSessionResponseSerializing;

@interface NSURLSession (SIURLSessionBlocksSerializers)

@property(readonly)  SIURLSessionRequestSerializerAbstract<SIURLSessionRequestSerializing>    * SI_serializerForRequest;
@property(readonly)  SIURLSessionResponseSerializerAbstract<SIURLSessionResponseSerializing>  * SI_serializerForResponse;

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


@interface SIURLSessionSerializerAbstract : NSObject
@property(nonatomic,readonly) NSStringEncoding stringEncoding;

-(NSString *)queryStringFromParameters:(NSObject<NSFastEnumeration> *)theParameters;

-(NSArray *)queryPairsFromKey:(NSString *)theKey andValue:(NSObject<NSFastEnumeration> *)theValue;
-(NSDictionary *)queryPairFromKey:(NSString *)theKey andValue:(NSObject<NSFastEnumeration> *)theValue;
-(NSString *)URLEncodedPair:(NSDictionary *)thePair;


@end

@interface SIURLSessionRequestSerializerAbstract : SIURLSessionSerializerAbstract
@property(nonatomic,readonly) NSSet         * acceptableHTTPMethodsForURIEncoding;
-(void)buildURIEncodedParametersRequest:(NSURLRequest *)theRequest
                                   withParam:(NSObject<NSFastEnumeration> *)theParameters
                                            onCompletion:(SIURLSessionSerializerErrorBlock)theBlock;
@end



@interface SIURLSessionResponseSerializerAbstract : SIURLSessionSerializerAbstract

@property(nonatomic,readonly) NSIndexSet    * acceptableHTTPStatusCodes;


-(void)validateResponse:(NSHTTPURLResponse *)theResponse
                   data:(NSData *)theData
                  onCompletion:(SIURLSessionSerializerErrorBlock)theBlock;
@end


@interface SIURLSessionRequestSerializerJSON : SIURLSessionRequestSerializerAbstract
<SIURLSessionRequestSerializing>
@end

@interface SIURLSessionResponseSerializerJSON : SIURLSessionResponseSerializerAbstract
<SIURLSessionResponseSerializing>
@end