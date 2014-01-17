#SIHTTPCore

### Will be working on the README and docs for a while... this is temporary. 

[![Build Status](https://travis-ci.org/etalio/SIHTTPCore.png?branch=master)](https://travis-ci.org/screeninteraction/SIHTTPCore)
[![Version](http://cocoapod-badges.herokuapp.com/v/SIHTTPCore/badge.png)](http://cocoadocs.org/docsets/SIHTTPCore)
[![Platform](http://cocoapod-badges.herokuapp.com/p/SIHTTPCore/badge.png)](http://cocoadocs.org/docsets/SIHTTPCore)

> Using NSURLSession and the rest of the new iOS 7 foundation network classes, wrapped with syntactic sugar and convenience. No need to inherit and make a singleton. The category will keep track of your session with a user defined key. 

##Overview

A incredibly light weight and source-readable HTTP client. 
Plugginable Serializers on top of builting foundation classes NSURLSession and NSURLSessionTask.
Life-cycle callbacks (think before_filter or after_filter) 
Upload & Download progress blocks. 
Choose delegates and/or blocks
Convenience serializers (JSON out of the box by default) to get started fast. 



##Installation

```ruby
pod 'SIHTTPCore'
```


##Setup

```objective-c
#import <SIHTTPCore.h>
```


## API
[Documentation for now](https://github.com/screeninteraction/SIHTTPCore/blob/develop/SIHTTPCore/NSURLSession%2BSIHTTPCore.h#L35-L36)





Contact
-------

If you end up using SIHTTPCore in a project, we'd love to hear about it.

email: [info@screeninteraction.com](mailto:contact@screeninteraction.com)  
twitter: [@ScreenTwitt](https://twitter.com/ScreenTwitt)

## License

SIHTTPCore is © 2013 [Screen Interaction](http://www.github.com/screeninteraction) and may be freely
distributed under the [MIT license](http://opensource.org/licenses/MIT).
See the [`LICENSE.md`](https://github.com/screeninteraction/SIHTTPCore/blob/master/LICENSE.md) file.
