
#pragma mark - Request
typedef void (^SIURLSessionTaskRequestCompleteBlock)(NSError * error,
                                                     NSDictionary * responseObject,
                                                     NSHTTPURLResponse * urlResponse,
                                                     NSURLSessionTask * task
                                                     );

typedef void (^SIURLSessionTaskRequestDataCompleteBlock)(NSError * error,
                                                         NSURL * location,
                                                         NSData * responseObjectData,
                                                         NSHTTPURLResponse * urlResponse,
                                                         NSURLSessionTask * task
                                                         );


