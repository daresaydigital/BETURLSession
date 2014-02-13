#BETURLSession


[![Build Status](https://travis-ci.org/etalio/BETURLSession.png?branch=master)](https://travis-ci.org/screeninteraction/BETURLSession)
[![Version](https://cocoapod-badges.herokuapp.com/v/BETURLSession/badge.png)](http://cocoadocs.org/docsets/BETURLSession)
[![Platform](https://cocoapod-badges.herokuapp.com/p/BETURLSession/badge.png)](http://cocoadocs.org/docsets/BETURLSession)

> Using NSURLSession and the rest of the new iOS 7 & Mavericks foundation network classes, wrapped with syntactic sugar and convenience. 
No need to inherit and make a singleton. The category will keep track of your session with a session name. 



##Overview

A incredibly light weight and source-readable HTTP client. 
Plugginable Serializers on top of builting foundation classes NSURLSession and NSURLSessionTask.
Life-cycle callbacks (think before_filter or after_filter) 
Upload & Download progress blocks. 
Choose delegates and/or blocks
Convenience serializers (JSON out of the box by default) to get started fast. 



##Installation

```ruby
pod 'BETURLSession'
```


##Setup

```objective-c
#import <BETURLSession.h>
```


## API
[Documentation for now](https://github.com/screeninteraction/BETURLSession/blob/develop/BETURLSession/NSURLSession%2BBETURLSession.h#L35-L36)


## Sample
```objective-c
  NSURLSession * session = [NSURLSession bet_sessionWithName:@"Random" baseURLString:@"http://httpbin.org"];
  
  NSMutableArray * bigData = @[].mutableCopy;
  for (NSInteger i = 0; i!=50000; i++) [bigData addObject:@(i)];
  
  NSURLSessionTask * task = [session bet_taskPOSTResource:@"post" 
                                               withParams:@{@"POST" : bigData} 
                                               completion:^(BETResponse *response) {
    NSLog(@"POST completed with code %@ & error %@", 
                @(response.HTTPURLResponse.statusCode), 
                  response.error
          );
  }];
  
  BETURLSessionTaskProgressHandlerBlock (^progressHandlerWithName)(NSString *) = ^BETURLSessionTaskProgressHandlerBlock(NSString * name) {
    return ^(NSURLSessionTask *task, NSInteger bytes, NSInteger totalBytes, NSInteger totalBytesExpected) {
      NSLog(@"%@ : %@ <-> %@ <-> %@", name, @(bytes), @(totalBytes), @(totalBytesExpected));
    };
  };


  
  [task bet_setUploadProgressHandler:progressHandlerWithName(@"Upload")];
  
  [task bet_setDownloadProgressHandler:progressHandlerWithName(@"Download")];
  
  [task resume];
  
```


## Notes
* Proper naming
* completion: for callbacks that are complete (option)
* completionHandler: callbacks that are complete but need action (required)
* handler: callbacks that need action but are not necessarily completion (required)


Contact
-------

If you end up using BETURLSession in a project, we'd love to hear about it.

email: [info@screeninteraction.com](mailto:contact@screeninteraction.com)  
twitter: [@ScreenTwitt](https://twitter.com/ScreenTwitt)

## License

BETURLSession is © 2013 [Screen Interaction](http://www.github.com/screeninteraction) and may be freely
distributed under the [MIT license](http://opensource.org/licenses/MIT).
See the [`LICENSE.md`](https://github.com/screeninteraction/BETURLSession/blob/master/LICENSE.md) file.
