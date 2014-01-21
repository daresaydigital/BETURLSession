
#pragma mark - Request
typedef void (^SIURLSessionTaskRequestCompleteBlock)(NSError * error,
                                                     NSObject<NSFastEnumeration> * responseObject,
                                                     NSHTTPURLResponse * HTTPURLResponse,
                                                     NSURLSessionTask * task
                                                     );

typedef void (^SIURLSessionTaskRequestDataCompleteBlock)(NSError * error,
                                                         NSURL * location,
                                                         NSData * responseObjectData,
                                                         NSHTTPURLResponse * HTTPURLResponse,
                                                         NSURLSessionTask * task
                                                         );


