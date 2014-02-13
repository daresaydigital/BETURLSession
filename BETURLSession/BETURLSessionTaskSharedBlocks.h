
#pragma mark - Request
typedef void (^BETURLSessionTaskRequestCompletionBlock)(NSObject<NSFastEnumeration> * responseObject,
                                                        NSHTTPURLResponse           * HTTPURLResponse,
                                                        NSURLSessionTask            * task,
                                                        NSError                     * error
                                                     );

typedef void (^BETURLSessionTaskRequestDataCompletionBlock)(NSURL           * location,
                                                         NSData             * responseObjectData,
                                                         NSHTTPURLResponse  * HTTPURLResponse,
                                                         NSURLSessionTask   * task,
                                                          NSError           * error
                                                         );


