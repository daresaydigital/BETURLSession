#SIURLSessionBlocks

[![Build Status](https://travis-ci.org/etalio/SIURLSessionBlocks.png?branch=master)](https://travis-ci.org/screeninteraction/SIURLSessionBlocks)
[![Version](http://cocoapod-badges.herokuapp.com/v/SIURLSessionBlocks/badge.png)](http://cocoadocs.org/docsets/SIURLSessionBlocks)
[![Platform](http://cocoapod-badges.herokuapp.com/p/SIURLSessionBlocks/badge.png)](http://cocoadocs.org/docsets/SIURLSessionBlocks)

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
pod 'SIURLSessionBlocks'
```


##Setup

```objective-c
#import <SIURLSessionBlocks.h>
```


## API

This is currently a very early alpha version, 
look at ```NSURLSessionTask+SIURLSessionBlocks.h``` & ```NSURLSession+SIURLSessionBlocks.h``` to figure out how to use it. 
API changes are expected.

FAQ

>Q: Why are you making a category on NSObject.

A: Because the way NSURLSession and NSURLSessionDataTasks are made. NSURLSession and NSURLSessionDataTask has a method_missing dispatching all selectors to private classes - the _NSCF composite class.



>Q: Won't this pollute the public interace of basically everything?

A: Not really, only the implementation is on top of NSObject, the public interface is on the proper classes themselves


>Q: Why make Yet Another HTTP Client?

A: We needed a lightweight dependency for a different project. 
This is nothing but plugginable custom serializers for request & response with categories on top Apple's own classes. 
It gives you the option to use blocks and/or delegates and stays out of your way. 
It doesn't do too much. 
It has a very light and readable source code since it relies on NSURLSession. 



>Q: Where are the tests?

A: They'be comin'. Seriously though, I've been waiting on Travis to get fixed first. 




Contact
-------

If you end up using SIURLSessionBlocks in a project, we'd love to hear about it.

email: [info@screeninteraction.com](mailto:info@screeninteraction.com)  
twitter: [@ScreenTwitt](https://twitter.com/ScreenTwitt)

## License

SIURLSessionBlocks is © 2013 [Screen Interaction](http://www.github.com/screeninteraction) and may be freely
distributed under the [MIT license](http://opensource.org/licenses/MIT).
See the [`LICENSE.md`](https://github.com/screeninteraction/SIURLSessionBlocks/blob/master/LICENSE.md) file.
