

@interface BETResponse : NSObject
@property(nonatomic,strong,readonly) id<NSFastEnumeration,NSObject>    content;
@property(nonatomic,strong,readonly) NSHTTPURLResponse              *  HTTPURLResponse;
@property(nonatomic,strong,readonly) NSError                        *  error;
@property(nonatomic,strong,readonly) NSURLSessionTask               *  task;
@end

