ARHttpRequest
===========

ARHttpRequest是一个网络通信的适配层，对上层业务调用提供简明接口，对下层具体网络库轻度包装，并以适配器模式进行扩展和无缝替换。
  
ARHttpRequest产生背景和特点：

1、旧业务系统的维护和升级：适配器模式的设计，保持上层业务代码的不变或少变，而下层具体网络库可以与时俱进和无缝更换。

2、实际项目开发的迭代：日常开发需要简单、简洁的网络操作API，IHttpRequest接口正是由多年实际项目需要抽象进化而来。

3、多平台规范的考虑：Android和iOS设计相对统一的适配接口规范，便于管理和维护。

4、ARHttpRequest目的是为解决日常80%的繁琐使用场景；另外20%复杂或特殊的场景请直接使用具体网络库的特定方式来操作。
  
ARHttpRequest现有的功能：

1、提供简明的网络操作API，包括get/post/postJson/postXml/postSoapXml/postFormData/downloadFile/uploadFile等。

2、DownloadFile支持断点续传。

3、默认网络操作都为异步方式，提供完成/失败的回调Block，下载有进度状态Block。

4、提供简洁的队列操作方式，以及队列完成的回调Block。

5、ARHttpRequest实例类析构时自动释放和清理相关对象的引用，上层代码无需关注具体网络库的内存释放问题。

6、iOS现提供NSURLSession和ASIHTTPRequest的适配器；Android现提供HttpURLConnection的适配器。


如何使用？
========
iOS
---
1、将编译后的“ARHttpRequest.framework”加入您的项目工程；或将“ARHttpRequest”源码文件夹内所有文件加入到您的项目工程中。

2、在需要的地方引入头文件：
framework形式引入：
```
#import <ARHttpRequest/IARHttpRequest.h>
#import <ARHttpRequest/ARHttpRequestASIAdapter.h>
#import <ARHttpRequest/ARHttpRequestSessionAdapter.h>
#import <ARHttpRequest/ARFormDataFile.h>
```
或者源码形式引入：
```
#import "IARHttpRequest.h"
#import "ARHttpRequestASIAdapter.h"
#import "ARHttpRequestSessionAdapter.h"
#import "ARHttpRequest/ARFormDataFile.h"
```

3、代码例子：
```
// 1 定义模块级属性变量
@property (nonatomic, strong) id<IARHttpRequest> httpRequest;

// 2 属性get方法，以工厂方法模式创建IARHttpRequest实例
- (id<IARHttpRequest>)httpRequest
{
    if (!_httpRequest) {
        // 测试基于NSURLSession的操作
        _httpRequest = [[ARHttpRequestSessionAdapter alloc] init];
        
//        // 测试基于ASIHTTPRequest的操作
//        _httpRequest = [[ARHttpRequestASIAdapter alloc] init];
    }
    return _httpRequest;
}

// 3 执行get操作
    [self.httpRequest get:@"http://www.baidu.com"    //请求url
                      tag:0                          //本次请求的唯一标识符，如果有多个请求，请使用不同的tag
                 userInfo:nil                        //自己放的一些值，便于请求的回调函数中使用
            finishedBlock:^(NSData *data, NSDictionary *userInfo) { //请求和响应结束的Block回调
                //
                NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@">>> data: %@", dataStr);
            } failedBlock:^(NSError *error, NSDictionary *userInfo) { //请求失败后的Block回调
                //
                NSLog(@">>> error: %@", error);
            }
     ];
```

注：更多例子请参考源码“iOS/ARHttpRequestDemo”工程下的单元测试例子“ARHttpRequestTests.m”。

Android
-------
敬请期待...


联系方式
=======
ArwerSoftware@gmail.com




License
=======
The MIT License (MIT)

Copyright © 2016 LongJun

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
