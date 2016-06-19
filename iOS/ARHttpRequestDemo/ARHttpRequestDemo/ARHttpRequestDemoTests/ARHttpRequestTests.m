//
//  ARHttpRequestTests.m
//  ARHttpRequestDemo
//
//  Created by jun on 16/6/16.
//  Copyright © 2016年 Arwer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <ARHttpRequest/IARHttpRequest.h>
#import <ARHttpRequest/ARHttpRequestASIAdapter.h>
#import <ARHttpRequest/ARHttpRequestSessionAdapter.h>
#import <ARHttpRequest/ARFormDataFile.h>

@interface ARHttpRequestTests : XCTestCase

@property (nonatomic, strong) id<IARHttpRequest> httpRequest;

@end

@implementation ARHttpRequestTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

#pragma mark - 基于IARHttpRequest的测试

// 工厂方法，创建IARHttpRequest实例
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

// 测试Get请求
- (void)testGet {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    XCTestExpectation *exception = [self expectationWithDescription:@""];
    
    //    NSString *url = @"http://localhost:3000/dev/mock/api/48e82320-efff-11e5-b524-8fc3522b1799/checkVersion";
    //    NSString *url = @"http://www.baidu.com";
//    NSString *url = @"http://localhost:3000/dev/mock/api/48e82320-efff-11e5-b524-8fc3522b1799/checkVersionFail";
    NSString *url = @"http://www.baidu.com/s?wd=学习 笔记";
    
    [self.httpRequest get:url
                      tag:0
                 userInfo:nil
            finishedBlock:^(NSData *data, NSDictionary *userInfo) {
                //
                NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@">>> data: %@", dataStr);
                XCTAssert(YES, @"Pass");
                [exception fulfill];
            } failedBlock:^(NSError *error, NSDictionary *userInfo) {
                //
                NSLog(@">>> error: %@", error);
                XCTAssert(NO, @"Not pass");
                [exception fulfill];
            }
     ];
    
    //测试挂起等待上面Block执行完成或超时
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@">>> Timeout Error: %@", error);
        }
    }];
}

// 测试POST请求
- (void)testPost {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    XCTestExpectation *exception = [self expectationWithDescription:@""];
    
    //    NSString *url = @"http://localhost:3000/dev/mock/api/48e82320-efff-11e5-b524-8fc3522b1799/checkVersion";
    NSString *url = @"http://localhost:3000/dev/mock/saveApi";
    
    [self.httpRequest postJson:url
                           tag:0
                    jsonString:@"{\"aaa\":111, \"bbb\":\"text222\"}"
     //                                  jsonString:@"{projectId:'1111'}"
                 finishedBlock:^(NSData *data, NSDictionary *userInfo) {
                     //
                     NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                     NSLog(@">>> testPost finished, data: %@", dataStr);
                     XCTAssert(YES, @"Pass");
                     [exception fulfill];
                 }
                   failedBlock:^(NSError *error, NSDictionary *userInfo) {
                       //
                       NSLog(@">>> testPost error: %@", error);
                       XCTAssert(NO, @"Not pass");
                       [exception fulfill];
                   }
     ];
    
    //测试挂起等待上面Block执行完成或超时
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@">>> Timeout Error: %@", error);
        }
    }];
}

// 测试POST请求
- (void)testPost2 {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    XCTestExpectation *exception = [self expectationWithDescription:@""];
    
    //    NSString *url = @"http://localhost:3000/dev/mock/api/48e82320-efff-11e5-b524-8fc3522b1799/checkVersion";
    NSString *url = @"http://localhost:3000/dev/mock/saveApi";
    
    [self.httpRequest postJson:url
                           tag:0
                      userInfo:nil
                      jsonDict:@{@"aaa":@111, @"bbb":@"222"}
                attachHeadInfo:nil
                timeoutSeconds:30
                 finishedBlock:^(NSData * _Nullable data, NSDictionary * _Nullable userInfo) {
                     //
                     NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                     NSLog(@">>> testPost2 finished, data: %@", dataStr);
                     XCTAssert(YES, @"Pass");
                     [exception fulfill];
                 } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable userInfo) {
                     //
                     NSLog(@">>> error: %@", error);
                     XCTAssert(NO, @"Not pass");
                     [exception fulfill];
                 }
     ];
    
    
    //测试挂起等待上面Block执行完成或超时
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@">>> Timeout Error: %@", error);
        }
    }];
}

// 测试文件下载
- (void)testDownload {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    XCTestExpectation *exception = [self expectationWithDescription:@""];
    NSInteger timeout = 120;
    
    //    NSString *url = @"https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/bd_logo1_31bdc765.png";
    //    NSString *url = @"http://images.csdn.net/20160601/20160601091210224.png";
    //    NSString *url = @"http://localhost:3000/download/凯文·凯利：Out of Control.pdf"; //4M
    NSString *url = @"http://localhost:3000/download/Tanenbaum：Modern Operating Systems (第2版 扫描版).pdf"; //23.6M
    //    NSString *url = @"http://localhost:3000/download/eeee.java"; //2K
    //    NSString *url = @"http://localhost:3000/download/Steven Levy：黑客——计算机革命的英雄 (25周年纪念版).mobi";//1.1M
    
    NSInteger tag = 10;
    [self.httpRequest downloadFile:url
                               tag:tag
                   destinationPath:@"/Users/long/temp/down"
                          tempPath:@"/Users/long/temp/xxxx.tmp"
                    timeoutSeconds:timeout
                     progressBlock:^(unsigned long long progressingSize, unsigned long long totalSize) {
                         //
                         NSLog(@">>> download file, Received: %lld bytes (Downloaded: %lld bytes).\n", progressingSize, totalSize);
                     } finishedBlock:^(NSData * _Nullable data, NSDictionary * _Nullable userInfo) {
                         //
                         NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                         NSLog(@">>> testDownload finished, data: %@", dataStr);
                         XCTAssert(YES, @"Pass");
                         [exception fulfill];
                     } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable userInfo) {
                         //
                         NSLog(@">>> testDownload error: %@", error);
                         XCTAssert(NO, @"Not pass");
                         [exception fulfill];
                     }
     ];
    
    //测试挂起等待上面Block执行完成或超时
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@">>> Timeout Error: %@", error);
        }
    }];
}

// 测试Form Data请求
- (void)testFormData {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    XCTestExpectation *exception = [self expectationWithDescription:@""];
    NSInteger timeout = 120;
    
    NSString *url = @"http://localhost:3000/dev/entity/file-upload";
    NSMutableArray *files = [NSMutableArray array];
    
    //    ARFormDataFile *file = [[ARFormDataFile alloc] initWithParams:@"file1" fileName:@"SXXX.sqlite" filePath:@"/Users/jun/Desktop/SXXX.sqlite" contentType:@"application/octet-streamn"];
    //    [files addObject:file];
    ARFormDataFile *file2 = [[ARFormDataFile alloc] initWithParams:@"file2" fileName:@"test_up.txt" filePath:@"/Users/jun/temp/test_up.txt" contentType:@"text/plain"];
    [files addObject:file2];
    
    //
    [self.httpRequest postFormData:url
                               tag:12
                          userInfo:nil
                        postValues: [NSMutableDictionary dictionaryWithObjectsAndKeys:@11, @"Key1", @"222", @"Key2", nil] //@{@"Key1":@11, @"Key2":@"22text"}
                       attachFiles:files
                    attachHeadInfo:nil
                    timeoutSeconds:60
                     finishedBlock:^(NSData *data, NSDictionary *userInfo) {
                         //
                         NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                         NSLog(@">>> testFormData finished, data: %@", dataStr);
                         XCTAssert(YES, @"Pass");
                         [exception fulfill];
                     }
                       failedBlock:^(NSError *error, NSDictionary *userInfo) {
                           //
                           NSLog(@">>> testFormData error: %@", error);
                           XCTAssert(NO, @"Not pass");
                           [exception fulfill];
                       }
     ];
    
    //测试挂起等待上面Block执行完成或超时
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@">>> Timeout Error: %@", error);
        }
    }];
}

// 测试有队列的操作
- (void)testQueue {
    XCTestExpectation *exception = [self expectationWithDescription:@""];
    
    [self.httpRequest setQueueIsOn:YES]; //开启队列
    [self.httpRequest setQueueMaxConcurrentOperationCount:1]; //并发任务数，如果为1则顺序执行任务
    [self.httpRequest setQueueFinishedBlock:^{ //队列完成后的回调Block
        NSLog(@">>> testQueue finished");
        [exception fulfill];
    }];
    
    // Task1
    NSString *url = @"http://localhost:3000/dev/mock/api/48e82320-efff-11e5-b524-8fc3522b1799/checkVersion";
    [self.httpRequest get:url
                      tag:1
                 userInfo:nil
            finishedBlock:^(NSData *data, NSDictionary *userInfo) {
                //
                NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@">>> Task1 finished, data: %@", dataStr);
            } failedBlock:^(NSError *error, NSDictionary *userInfo) {
                //
                NSLog(@">>> Task1 error: %@", error);
            }
     ];
    // Task2
    NSString *url2 = @"http://localhost:3000/dev/mock/saveApi";
    [self.httpRequest postJson:url2
                           tag:2
                      userInfo:nil
                      jsonDict:@{@"aaa":@111, @"bbb":@"222"}
                attachHeadInfo:nil
                timeoutSeconds:30
                 finishedBlock:^(NSData * _Nullable data, NSDictionary * _Nullable userInfo) {
                     //
                     NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                     NSLog(@">>> Task2 finished, data: %@", dataStr);
                 } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable userInfo) {
                     //
                     NSLog(@">>> Task2 error: %@", error);
                 }
     ];
    // Task3
//    NSString *url3 = @"http://localhost:3000/download/Tanenbaum：Modern Operating Systems (第2版 扫描版).pdf"; //23.6M
    NSString *url3 = @"http://localhost:3000/download/凯文·凯利：Out of Control.pdf"; //4M
    [self.httpRequest downloadFile:url3
                               tag:3
                   destinationPath:@"/Users/long/temp/down"
                          tempPath:@"/Users/long/temp/xxxx.tmp"
                    timeoutSeconds:60
                     progressBlock:^(unsigned long long progressingSize, unsigned long long totalSize) {
                         //
                         NSLog(@">>> Task3 download file, Received: %lld bytes (Downloaded: %lld bytes).\n", progressingSize, totalSize);
                     } finishedBlock:^(NSData * _Nullable data, NSDictionary * _Nullable userInfo) {
                         //
                         NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                         NSLog(@">>> Task3 finished, data: %@", dataStr);
                     } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable userInfo) {
                         //
                         NSLog(@">>> Task3 error: %@", error);
                     }
     ];

    
    //
    [self.httpRequest queueStart]; //队列开始执行
    //    [self.httpRequest queueStop]; //队列停止
    
    
    //测试挂起等待上面队列完成Block执行完成或超时
    [self waitForExpectationsWithTimeout:120 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@">>> Timeout Error: %@", error);
        }
    }];
}

@end
