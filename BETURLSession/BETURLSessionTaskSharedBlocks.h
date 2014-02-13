
@class BETResponse;
#pragma mark - Request
typedef void (^BETURLSessionTaskRequestCompletionBlock)(BETResponse * response);

typedef void (^BETURLSessionTaskRequestDataCompletionBlock)(NSURL           * location,
                                                         NSData             * responseObjectData,
                                                         NSHTTPURLResponse  * HTTPURLResponse,
                                                         NSURLSessionTask   * task,
                                                          NSError           * error
                                                         );


