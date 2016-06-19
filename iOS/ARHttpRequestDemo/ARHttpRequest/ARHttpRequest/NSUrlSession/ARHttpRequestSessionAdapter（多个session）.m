//
//  RLNetworkSession.m
//  RLLibrary
//
//  说明：
//  1、本类是对NSURLSession的轻度包装，提供常用方法。
//  2、下载相关方法，默认使用前台下载模式。
//
//  Created by jun on 16/5/30.
//  Copyright © 2016年 RongLian. All rights reserved.
//

#import "ARHttpRequestSessionAdapter.h"
#import "ARFormDataFile.h"
#import "ARHttpRequestUtils.h"

@interface ARHttpRequestSessionAdapter ()
<NSURLSessionDownloadDelegate>
{
    void(^defaultQueueFinishBlock)(void); //定义默认队列完成时的回调Block变量
}
    
@property (nonatomic, strong) NSOperationQueue *defaultQueue;
@property (nonatomic) BOOL isUseDefaultQueue;

@property (nonatomic, strong) NSMutableDictionary *taskDict; //缓存会话任务的相关参数
@property (nonatomic, strong) NSURLSession *defaultSession;

@end

@implementation ARHttpRequestSessionAdapter

#pragma mark - Class lift cycle
- (void)dealloc
{
    // 清理默认队列
    if (_defaultQueue) [_defaultQueue cancelAllOperations];
    
    // 清理缓存对象taskDict
    if (_taskDict) {
//        //删除所有缓存的文件
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        NSError *err;
//        for (NSString *keyName in _taskDict.allKeys) {
////            NSString *filePath = _downTaskDict[keyName][@"tempPathFullPath"];
//            NSString *filePath = _taskDict[keyName][@"tempPath"];
//            if (!filePath || filePath.length < 1) continue;
//            
//            [fileManager removeItemAtPath:filePath error:&err];
//        }
        
        //删除缓存的对象
        [self.taskDict removeAllObjects];
    }
}

#pragma mark - 默认队列相关

/**
 * 是否启用默认队列
 *
 * @param isOn YES=启用；NO=不启用
 */
- (void)setQueueIsOn:(BOOL)isOn {
    self.isUseDefaultQueue = isOn;
    if (isOn) {
        //
    }
    else {
        if (_defaultQueue) [_defaultQueue cancelAllOperations];
    }
}
/**
 * 定义队列完成时的回调Block
 *
 * @param finishBlock 回调Block
 */
- (void)setQueueFinishedBlock:(void(^ _Nullable)(void))finishBlock
{
    if (!finishBlock) return;
    
    defaultQueueFinishBlock = NULL;
    defaultQueueFinishBlock = [finishBlock copy];
}

/**
 * 设置默认队列最大并发数
 *
 * @return 返回一个NSOperationQueue实例对象
 */
- (void)setQueueMaxConcurrentOperationCount:(NSInteger)count
{
    self.defaultQueue.maxConcurrentOperationCount = count;
}

- (NSOperationQueue*)defaultQueue
{
    if (!_defaultQueue) {
        _defaultQueue = [[NSOperationQueue alloc] init];
        [_defaultQueue setSuspended:YES]; //暂停/挂起执行
        _defaultQueue.maxConcurrentOperationCount = 1;
        
        //通过KVO的形式来观察队列完成情况
        [_defaultQueue addObserver:self forKeyPath:@"operations" options:0 context:nil];
        
//        [_defaultQueue waitUntilAllOperationsAreFinished];
    }
    return _defaultQueue;
}

/**
 * 开始默认队列
 *
 */
- (void)queueStart
{
    if (_defaultQueue) {
        [_defaultQueue setSuspended:NO];
    }
}

/**
 * 停止默认队列
 *
 */
- (void)queueStop
{
    // 取消队列所有任务
    if (_defaultQueue) {
        [_defaultQueue cancelAllOperations];
    }
    // 删除缓存的对象
    if (_taskDict) {
        [_taskDict removeAllObjects];
    }
}

#pragma mark - Default Session
- (NSURLSession*)defaultSession
{
    // 创建NSURLSession
    if (!_defaultSession) {
        // NSURLSession配置（使用defaultSessionConfiguration，可以使用缓存的Cache，Cookie，鉴权。）
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        if (self.isUseDefaultQueue) { //使用自己默认的队列
            _defaultSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:self.defaultQueue];
        }
        else {
            _defaultSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        }
    }
    return _defaultSession;
}

#pragma mark - HTTP Get Methods

/**
 * HTTP Get 请求方法。默认为异步请求。
 *
 * @param urlString 服务端接口URL
 * @param tag 标志，便于请求回调后区分是哪个请求用的
 * @param finishedBlock 请求和响应结束的Block回调
 * @param failedBlock 请求失败后的Block回调
 */
- (void)get:(NSString * _Nonnull)urlString
                     tag:(NSInteger)tag
           finishedBlock:(ARNetFinishedBlock _Nonnull)finishedBlock
             failedBlock:(ARNetFailedBlock _Nonnull)failedBlock
{
    [self get:urlString
                       tag:tag
                  userInfo:nil
             finishedBlock:finishedBlock
               failedBlock:failedBlock];
}

/**
 * HTTP Get 请求方法。默认为异步请求。
 *
 * @param urlString 服务端接口URL
 * @param tag 标志，便于请求回调后区分是哪个请求用的
 * @param userInfo 自己放的一些值，便于请求的回调函数中使用
 * @param finishedBlock 请求和响应结束的Block回调
 * @param failedBlock 请求失败后的Block回调
 */
- (void)get:(NSString * _Nonnull)urlString
                     tag:(NSInteger)tag
                userInfo:(NSDictionary* _Nullable)userInfo
           finishedBlock:(ARNetFinishedBlock _Nonnull)finishedBlock
             failedBlock:(ARNetFailedBlock _Nonnull)failedBlock
{
    [self get:urlString
                       tag:tag
                  userInfo:userInfo
            timeoutSeconds: REQUEST_DEFAULT_TIMEOUT
             finishedBlock:finishedBlock
               failedBlock:failedBlock];
}

/**
 * HTTP Get 请求方法。默认为异步请求。
 *
 * @param urlString 服务端接口URL
 * @param tag 标志，便于请求回调后区分是哪个请求用的
 * @param userInfo 自己放的一些值，便于请求的回调函数中使用
 * @param timeoutSeconds 请求超时时间（秒）
 * @param finishedBlock 请求和响应结束的Block回调
 * @param failedBlock 请求失败后的Block回调
 */
- (void)get:(NSString * _Nonnull)urlString
                     tag:(NSInteger)tag
                userInfo:(NSDictionary* _Nullable)userInfo
          timeoutSeconds:(NSTimeInterval)timeoutSeconds
           finishedBlock:(ARNetFinishedBlock _Nonnull)finishedBlock
             failedBlock:(ARNetFailedBlock _Nonnull)failedBlock
{
    [self get:urlString
                    params:nil
                       tag:tag
                  userInfo:userInfo
            timeoutSeconds:timeoutSeconds
             finishedBlock:finishedBlock
               failedBlock:failedBlock];
}

/**
 * HTTP Get 请求方法。默认为异步请求。
 *
 * @param urlString 服务端接口URL
 * @param params URL参数字典
 * @param tag 标志，便于请求回调后区分是哪个请求用的
 * @param userInfo 自己放的一些值，便于请求的回调函数中使用
 * @param timeoutSeconds 请求超时时间（秒）
 * @param finishedBlock 请求和响应结束的Block回调
 * @param failedBlock 请求失败后的Block回调
 */
- (void)get:(NSString * _Nonnull)urlString
                  params:(NSMutableDictionary* _Nullable)params
                     tag:(NSInteger)tag
                userInfo:(NSDictionary* _Nullable)userInfo
          timeoutSeconds:(NSTimeInterval)timeoutSeconds
           finishedBlock:(ARNetFinishedBlock _Nonnull)finishedBlock
             failedBlock:(ARNetFailedBlock _Nonnull)failedBlock
{
    [self get:urlString
                    params:params
                       tag:tag
                  userInfo:userInfo
            attachHeadInfo:nil
            timeoutSeconds:timeoutSeconds
             finishedBlock:finishedBlock
               failedBlock:failedBlock];
}

/**
 * HTTP post json 请求方法。默认为异步请求。
 *
 * @param urlString 服务端接口URL
 * @param tag 标志，便于请求回调后区分是哪个请求用的
 * @param userInfo 自己放的一些值，便于请求的回调函数中使用
 * @param jsonString json字符串格式的发送内容
 * @param attachHeadInfo 附加的头信息
 * @param timeoutSeconds 请求超时时间（秒）
 * @param finishedBlock 请求和响应结束的Block回调
 * @param failedBlock 请求失败后的Block回调
 */
- (void)get:(NSString * _Nonnull)urlString
                  params:(NSMutableDictionary* _Nullable)params
                     tag:(NSInteger)tag
                userInfo:(NSDictionary* _Nullable)userInfo
          attachHeadInfo:(NSMutableDictionary* _Nullable)attachHeadInfo
          timeoutSeconds:(NSTimeInterval)timeoutSeconds
           finishedBlock:(ARNetFinishedBlock _Nonnull)finishedBlock
             failedBlock:(ARNetFailedBlock _Nonnull)failedBlock
{
    // 将参数拼接到url
    NSMutableString *fullUrl = [ARHttpRequestUtils createGetUrlByDictParam:urlString paramDict:params];
    // 编码url
    NSString *encodedUrl = [fullUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
#if DEBUG
    NSLog(@"get, encoded urlString=%@",encodedUrl);
#endif
    // NSURLSession配置（使用defaultSessionConfiguration，可以使用缓存的Cache，Cookie，鉴权。）
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    // 创建一个请求对象，以及设置请求参数
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:fullUrl]];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = timeoutSeconds; //超时时间，秒

    for (NSString *key in attachHeadInfo.allKeys) { //添加附加的头信息
        [request setValue:attachHeadInfo[key] forHTTPHeaderField:key];
    }
    // 创建NSURLSession
    NSURLSession *session;
    if (self.isUseDefaultQueue) { //使用自己默认的队列
        session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:self.defaultQueue];
    }
    else {
        session = [NSURLSession sessionWithConfiguration:config];
    }
    // 创建一个数据任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                //
                                                if (error) {
                                                    failedBlock(error, userInfo);
                                                }
                                                else {
                                                    finishedBlock(data, userInfo);
                                                }
                                            }];
    // 执行任务
    [task resume];
}

#pragma mark - HTTP Post Methods (JSON/XML)

/**
 * HTTP post json 请求方法。默认为异步请求。
 *
 * @param urlString 服务端接口URL
 * @param tag 标志，便于请求回调后区分是哪个请求用的
 * @param jsonString json字符串格式的发送内容
 * @param timeoutSeconds 请求超时时间（秒）
 * @param finishedBlock 请求和响应结束的Block回调
 * @param failedBlock 请求失败后的Block回调
 */
- (void)postJson:(NSString * _Nonnull)urlString
                          tag:(NSInteger)tag
                   jsonString:(NSString* _Nonnull)jsonString
                finishedBlock:(ARNetFinishedBlock _Nonnull)finishedBlock
                  failedBlock:(ARNetFailedBlock _Nonnull)failedBlock
{
    [self postJson:urlString
                            tag:tag
                       userInfo:nil
                     jsonString:jsonString
                 attachHeadInfo:nil
                 timeoutSeconds:REQUEST_DEFAULT_TIMEOUT
                  finishedBlock:finishedBlock
                    failedBlock:failedBlock];
}

/**
 * HTTP post json 请求方法。默认为异步请求。
 *
 * @param urlString 服务端接口URL
 * @param tag 标志，便于请求回调后区分是哪个请求用的
 * @param userInfo 自己放的一些值，便于请求的回调函数中使用
 * @param jsonString json字符串格式的发送内容
 * @param timeoutSeconds 请求超时时间（秒）
 * @param finishedBlock 请求和响应结束的Block回调
 * @param failedBlock 请求失败后的Block回调
 */
- (void)postJson:(NSString * _Nonnull)urlString
                          tag:(NSInteger)tag
                     userInfo:(NSDictionary* _Nullable)userInfo
                   jsonString:(NSString* _Nonnull)jsonString
                finishedBlock:(ARNetFinishedBlock _Nonnull)finishedBlock
                  failedBlock:(ARNetFailedBlock _Nonnull)failedBlock
{
    [self postJson:urlString
                            tag:tag
                       userInfo:userInfo
                     jsonString:jsonString
                 attachHeadInfo:nil
                 timeoutSeconds:REQUEST_DEFAULT_TIMEOUT
                  finishedBlock:finishedBlock
                    failedBlock:failedBlock];
}

/**
 * HTTP post json 请求方法。默认为异步请求。
 *
 * @param urlString 服务端接口URL
 * @param tag 标志，便于请求回调后区分是哪个请求用的
 * @param userInfo 自己放的一些值，便于请求的回调函数中使用
 * @param jsonString json字符串格式的发送内容
 * @param attachHeadInfo 附加的头信息
 * @param timeoutSeconds 请求超时时间（秒）
 * @param finishedBlock 请求和响应结束的Block回调
 * @param failedBlock 请求失败后的Block回调
 */
- (void)postJson:(NSString * _Nonnull)urlString
                          tag:(NSInteger)tag
                     userInfo:(NSDictionary* _Nullable)userInfo
                   jsonString:(NSString* _Nonnull)jsonString
               attachHeadInfo:(NSMutableDictionary* _Nullable)attachHeadInfo
               timeoutSeconds:(NSTimeInterval)timeoutSeconds
                finishedBlock:(ARNetFinishedBlock _Nonnull)finishedBlock
                  failedBlock:(ARNetFailedBlock _Nonnull)failedBlock
{
    [self post:urlString
                        tag:tag
                   userInfo:userInfo
                   postData:[jsonString  dataUsingEncoding:NSUTF8StringEncoding]
                 contenType:@"application/json; charset=utf-8"
             attachHeadInfo:attachHeadInfo
             timeoutSeconds:timeoutSeconds
              finishedBlock:finishedBlock
                failedBlock:failedBlock];
}

/**
 * HTTP post json 请求方法。默认为异步请求。
 *
 * @param urlString 服务端接口URL
 * @param tag 标志，便于请求回调后区分是哪个请求用的
 * @param userInfo 自己放的一些值，便于请求的回调函数中使用
 * @param jsonDict 存放json键值的字典
 * @param attachHeadInfo 附加的头信息
 * @param timeoutSeconds 请求超时时间（秒）
 * @param finishedBlock 请求和响应结束的Block回调
 * @param failedBlock 请求失败后的Block回调
 */
- (void)postJson:(NSString * _Nonnull)urlString
                          tag:(NSInteger)tag
                     userInfo:(NSDictionary* _Nullable)userInfo
                     jsonDict:(NSDictionary* _Nonnull)jsonDict
               attachHeadInfo:(NSMutableDictionary* _Nullable)attachHeadInfo
               timeoutSeconds:(NSTimeInterval)timeoutSeconds
                finishedBlock:(ARNetFinishedBlock _Nonnull)finishedBlock
                  failedBlock:(ARNetFailedBlock _Nonnull)failedBlock
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error: &error];
    if (error) {
        if (failedBlock) {
            failedBlock(error, userInfo);
        }
        return;
    }
    
    [self post:urlString
                        tag:tag
                   userInfo:userInfo
                   postData:jsonData
                 contenType:@"application/json; charset=utf-8"
     //                 contenType:@"application/json; encoding=utf-8"
             attachHeadInfo:attachHeadInfo
             timeoutSeconds:timeoutSeconds
              finishedBlock:finishedBlock
                failedBlock:failedBlock];
}

/**
 * HTTP Post 常规 XML 请求方法。默认为异步请求。
 *
 * @param urlString 服务端接口URL
 * @param tag 标志，便于请求回调后区分是哪个请求用的
 * @param userInfo 自己放的一些值，便于请求的回调函数中使用
 * @param xmlString 需要post的XML字符串
 * @param finishedBlock 请求和响应结束的Block回调
 * @param failedBlock 请求失败后的Block回调
 */
- (void)postXml:(NSString * _Nonnull)urlString
                         tag:(NSInteger)tag
                    userInfo:(NSDictionary* _Nullable)userInfo
                   xmlString:(NSString* _Nonnull)xmlString
               finishedBlock:(ARNetFinishedBlock _Nonnull)finishedBlock
                 failedBlock:(ARNetFailedBlock _Nonnull)failedBlock
{
    [self post:urlString
                        tag:tag
                   userInfo:userInfo
                   postData:[xmlString  dataUsingEncoding:NSUTF8StringEncoding]
                 contenType:@"application/xml; charset=utf-8"
             attachHeadInfo:nil
             timeoutSeconds:REQUEST_DEFAULT_TIMEOUT
              finishedBlock:finishedBlock
                failedBlock:failedBlock];
}

/**
 * HTTP Post 常规 XML 请求方法。默认为异步请求。
 *
 * @param urlString 服务端接口URL
 * @param tag 标志，便于请求回调后区分是哪个请求用的
 * @param userInfo 自己放的一些值，便于请求的回调函数中使用
 * @param xmlString 需要post的XML字符串
 * @param attachHeadInfo 附加的头信息
 * @param timeoutSeconds 请求超时时间（秒）
 * @param finishedBlock 请求和响应结束的Block回调
 * @param failedBlock 请求失败后的Block回调
 */
- (void)postXml:(NSString * _Nonnull)urlString
                         tag:(NSInteger)tag
                    userInfo:(NSDictionary* _Nullable)userInfo
                   xmlString:(NSString* _Nonnull)xmlString
              attachHeadInfo:(NSMutableDictionary* _Nullable)attachHeadInfo
              timeoutSeconds:(NSTimeInterval)timeoutSeconds
               finishedBlock:(ARNetFinishedBlock _Nonnull)finishedBlock
                 failedBlock:(ARNetFailedBlock _Nonnull)failedBlock
{
    [self post:urlString
                        tag:tag
                   userInfo:userInfo
                   postData:[xmlString  dataUsingEncoding:NSUTF8StringEncoding]
                 contenType:@"application/xml; charset=utf-8"
             attachHeadInfo:attachHeadInfo
             timeoutSeconds:timeoutSeconds
              finishedBlock:finishedBlock
                failedBlock:failedBlock];
}

/**
 * HTTP Post Soap XML (WebService) 请求方法。默认为异步请求。
 *
 * @param urlString 服务端接口URL
 * @param tag 标志，便于请求回调后区分是哪个请求用的
 * @param userInfo 自己放的一些值，便于请求的回调函数中使用
 * @param soapAction SOAP Action
 * @param postData 需要post的数据
 * @param attachHeadInfo 附加的头信息
 * @param timeoutSeconds 请求超时时间（秒）
 * @param finishedBlock 请求和响应结束的Block回调
 * @param failedBlock 请求失败后的Block回调
 */
- (void)postSoapXml:(NSString * _Nonnull)urlString
                      tag:(NSInteger)tag
                 userInfo:(NSDictionary* _Nullable)userInfo
               soapAction:(NSString* _Nonnull)soapAction
                 postData:(NSData* _Nullable)postData
           attachHeadInfo:(NSMutableDictionary* _Nullable)attachHeadInfo
           timeoutSeconds:(NSTimeInterval)timeoutSeconds
            finishedBlock:(ARNetFinishedBlock _Nonnull)finishedBlock
              failedBlock:(ARNetFailedBlock _Nonnull)failedBlock
{
    if (!attachHeadInfo) attachHeadInfo = [NSMutableDictionary dictionary];
    [attachHeadInfo setValue:soapAction forKey:@"SOAPAction"];
    
    [self post:urlString
                        tag:tag
                   userInfo:userInfo
                   postData:postData
                 contenType:@"text/xml; charset=utf-8"
             attachHeadInfo:attachHeadInfo
             timeoutSeconds:timeoutSeconds
              finishedBlock:finishedBlock
                failedBlock:failedBlock];
}

/**
 * HTTP Post请求方法。默认为异步请求。
 *
 * @param urlString 服务端接口URL
 * @param tag 标志，便于请求回调后区分是哪个请求用的
 * @param userInfo 自己放的一些值，便于请求的回调函数中使用
 * @param postData 需要post的数据
 * @param contenType Content-Type
 * @param attachHeadInfo 附加的头信息
 * @param timeoutSeconds 请求超时时间（秒）
 * @param finishedBlock 请求和响应结束的Block回调
 * @param failedBlock 请求失败后的Block回调
 */
- (void)post:(NSString * _Nonnull)urlString
                      tag:(NSInteger)tag
                 userInfo:(NSDictionary* _Nullable)userInfo
                 postData:(NSData* _Nullable)postData
               contenType:(NSString* _Nullable)contenType
           attachHeadInfo:(NSMutableDictionary* _Nullable)attachHeadInfo
           timeoutSeconds:(NSTimeInterval)timeoutSeconds
            finishedBlock:(ARNetFinishedBlock _Nonnull)finishedBlock
              failedBlock:(ARNetFailedBlock _Nonnull)failedBlock
{
    // NSURLSession配置（使用defaultSessionConfiguration，可以使用缓存的Cache，Cookie，鉴权。）
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    // 创建一个请求对象，以及设置请求参数
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = timeoutSeconds; //超时时间，秒
    for (NSString *key in attachHeadInfo.allKeys) { //添加附加的头信息
        [request setValue:attachHeadInfo[key] forHTTPHeaderField:key];
    }
    if (contenType) {
        [request setValue:contenType forHTTPHeaderField:@"Content-Type"];
    }
    // 创建NSURLSession
    NSURLSession *session;
    if (self.isUseDefaultQueue) { //使用自己默认的队列
        session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:self.defaultQueue];
    }
    else {
        session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    // 创建一个数据任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                //
                                                if (error) {
                                                    failedBlock(error, userInfo);
                                                }
                                                else {
                                                    finishedBlock(data, userInfo);
                                                }
                                            }];
    // 执行任务
    [task resume];
}



#pragma mark - Upload Methods
/**
 * 上传一个文件。默认为异步请求。
 *
 * @param urlString 服务端接口URL
 * @param tag 标志，便于请求回调后区分是哪个请求用的
 * @param userInfo 自己放的一些值，便于请求的回调函数中使用
 * @param fullFilePath 完整的文件路径名
 * @param attachHeadInfo 附加的头信息
 * @param timeoutSeconds 请求超时时间（秒）
 * @param progressBlock 请求已发送的字节数的Block回调
 * @param finishedBlock 请求和响应结束的Block回调
 * @param failedBlock 请求失败后的Block回调
 */
- (void)uploadFile:(NSString * _Nonnull)urlString
               tag:(NSInteger)tag
          userInfo:(NSDictionary* _Nullable)userInfo
      fullFilePath:(NSString* _Nonnull)fullFilePath
    attachHeadInfo:(NSMutableDictionary* _Nullable)attachHeadInfo
    timeoutSeconds:(NSTimeInterval)timeoutSeconds
    progressBlock:(ARNetProgressBlock _Nullable)progressBlock
     finishedBlock:(ARNetFinishedBlock _Nonnull)finishedBlock
       failedBlock:(ARNetFailedBlock _Nonnull)failedBlock
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:fullFilePath]) {
        NSException *ex = [NSException exceptionWithName:@"uploadFile Fail" reason:[NSString stringWithFormat:@"File is not exists: %@",fullFilePath] userInfo:nil];
        [ex raise];
        return;
    }
    
    NSMutableData *fileData = [NSMutableData dataWithContentsOfFile:fullFilePath];
    
    [self uploadFile:urlString
                 tag:tag
            userInfo:userInfo
            fileData:fileData
      attachHeadInfo:attachHeadInfo
      timeoutSeconds:timeoutSeconds
      progressBlock:progressBlock
       finishedBlock:finishedBlock
         failedBlock:failedBlock];
}

/**
 * 上传一个文件。默认为异步请求。
 *
 * @param urlString 服务端接口URL
 * @param tag 标志，便于请求回调后区分是哪个请求用的
 * @param userInfo 自己放的一些值，便于请求的回调函数中使用
 * @param fileData 文件数据
 * @param attachHeadInfo 附加的头信息
 * @param timeoutSeconds 请求超时时间（秒）
 * @param progressBlock 请求已发送的字节数的Block回调
 * @param finishedBlock 请求和响应结束的Block回调
 * @param failedBlock 请求失败后的Block回调
 */
- (void)uploadFile:(NSString * _Nonnull)urlString
               tag:(NSInteger)tag
          userInfo:(NSDictionary* _Nullable)userInfo
          fileData:(NSMutableData* _Nonnull)fileData
    attachHeadInfo:(NSMutableDictionary* _Nullable)attachHeadInfo
    timeoutSeconds:(NSTimeInterval)timeoutSeconds
    progressBlock:(ARNetProgressBlock _Nullable)progressBlock
     finishedBlock:(ARNetFinishedBlock _Nonnull)finishedBlock
       failedBlock:(ARNetFailedBlock _Nonnull)failedBlock
{
    // NSURLSession配置（使用defaultSessionConfiguration，可以使用缓存的Cache，Cookie，鉴权。）
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    // 创建一个请求对象，以及设置请求参数
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = timeoutSeconds; //超时时间，秒
    
    for (NSString *key in attachHeadInfo.allKeys) { //添加附加的头信息
        [request setValue:attachHeadInfo[key] forHTTPHeaderField:key];
    }
    
    // 创建NSURLSession
    NSURLSession *session;
    if (self.isUseDefaultQueue) { //使用自己默认的队列
        session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:self.defaultQueue];
    }
    else {
        session = [NSURLSession sessionWithConfiguration:config];
    }
    // 创建一个上传任务
    NSURLSessionUploadTask *uploadTask =[session uploadTaskWithRequest:request fromData:fileData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //
        if (error) {
            failedBlock(error, userInfo);
        }
        else {
            finishedBlock(data, userInfo);
        }

    }];
    // 执行任务
    [uploadTask resume];
}

#pragma mark - Download Methods

//// 会话默认为前台模式
//- (NSURLSession *)downloadSession
//{
//    if (!_downloadSession) {
//        // 获得session
//        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
//        self.downloadSession = [NSURLSession sessionWithConfiguration:cfg delegate:self delegateQueue:[NSOperationQueue mainQueue]];
//    }
//    return _downloadSession;
//}

/**
 * 下载一个文件。默认为异步请求。
 *
 * @param urlString 服务端接口URL
 * @param tag 标志，便于请求回调后区分是哪个请求用的
 * @param destinationPath 下载的文件最终保存的带文件名的完整路径，若不含文件名则自动使用url的文件名
 * @param tempPath 下载文件临时保存的带文件名的完整路径，若不含文件名则自动使用url的文件名，断点续传时同样路径则恢复下载
 * @param timeoutSeconds 请求超时时间（秒）
 * @param bytesReceivedBlock 请求响应收到的字节数的Block回调
 * @param finishedBlock 请求和响应结束的Block回调
 * @param failedBlock 请求失败后的Block回调
 */
- (void)downloadFile:(NSString * _Nonnull)urlString
                 tag:(NSInteger)tag
     destinationPath:(NSString* _Nonnull)destinationPath
            tempPath:(NSString* _Nonnull)tempPath
      timeoutSeconds:(NSTimeInterval)timeoutSeconds
  progressBlock:(ARNetProgressBlock _Nullable)progressBlock
       finishedBlock:(ARNetFinishedBlock _Nonnull)finishedBlock
         failedBlock:(ARNetFailedBlock _Nonnull)failedBlock
{
    [self downloadFile:urlString
                   tag:tag
              userInfo:nil
       destinationPath:destinationPath
              tempPath:tempPath
        attachHeadInfo:nil
        timeoutSeconds:timeoutSeconds
    progressBlock:progressBlock
         finishedBlock:finishedBlock
           failedBlock:failedBlock];
}

/**
 * 下载一个文件。默认为异步请求。
 *
 * @param urlString 服务端接口URL
 * @param tag 标志，便于请求回调后区分是哪个请求用的
 * @param userInfo 自己放的一些值，便于请求的回调函数中使用
 * @param destinationPath 下载的文件最终保存的带文件名的完整路径，若不含文件名则自动使用url的文件名
 * @param tempPath 下载文件临时保存的带文件名的完整路径，若不含文件名则自动使用url的文件名，断点续传时同样路径则恢复下载
 * @param attachHeadInfo 附加的头信息
 * @param timeoutSeconds 请求超时时间（秒）
 * @param bytesReceivedBlock 请求响应收到的字节数的Block回调
 * @param finishedBlock 请求和响应结束的Block回调
 * @param failedBlock 请求失败后的Block回调
 */
- (void)downloadFile:(NSString * _Nonnull)urlString
                 tag:(NSInteger)tag
            userInfo:(NSMutableDictionary* _Nullable)userInfo
     destinationPath:(NSString* _Nonnull)destinationPath
            tempPath:(NSString* _Nonnull)tempPath
      attachHeadInfo:(NSMutableDictionary* _Nullable)attachHeadInfo
      timeoutSeconds:(NSTimeInterval)timeoutSeconds
  progressBlock:(ARNetProgressBlock _Nullable)progressBlock
       finishedBlock:(ARNetFinishedBlock _Nonnull)finishedBlock
         failedBlock:(ARNetFailedBlock _Nonnull)failedBlock
{
    // NSURLSession配置（使用defaultSessionConfiguration，可以使用缓存的Cache，Cookie，鉴权。）
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    if (timeoutSeconds > 0) {
        config.timeoutIntervalForRequest = timeoutSeconds;
    }
    [config setHTTPAdditionalHeaders:attachHeadInfo];

    // 创建NSURLSession
    NSURLSession *session;
    if (self.isUseDefaultQueue) { //使用自己默认的队列
        session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:self.defaultQueue];
    }
    else {
        session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    
    // 创建一个下载任务
    NSString *encodedUrl = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:encodedUrl];
    NSURLSessionDownloadTask *downloadTask =[session downloadTaskWithURL:url];

    // 缓存参数，下载委托回调函数中使用
    if (!_taskDict) self.taskDict = [NSMutableDictionary dictionary];
    NSDictionary *dict = @{@"progressBlock":progressBlock
                           , @"finishedBlock": finishedBlock
                           , @"failedBlock": failedBlock
                           , @"destinationPath": destinationPath
                           , @"tempPath": tempPath
                           , @"filename": [urlString lastPathComponent]
                           , @"userInfo": (userInfo ? userInfo : @"")
                           , @"downloadTask": downloadTask
                           , @"downloadSession": session
                           };
    NSString *userTag = [NSString stringWithFormat:@"%lu", (unsigned long)tag];
    [self.taskDict setObject:dict forKey:userTag];
    //
    NSString *taskId = [NSString stringWithFormat:@"%lu", (unsigned long)downloadTask.taskIdentifier];
    NSDictionary *mappingDict = @{taskId:userTag}; //建立任务ID和用户tag的映射关系
    [self.taskDict setObject:mappingDict forKey:@"Mapping"];

    // 执行任务
    [downloadTask resume];
}

/**
 * 暂停下载任务。
 *
 */
- (void)downloadPause:(NSInteger)tag
{
    if (_taskDict) {
        NSString *keyName = [NSString stringWithFormat:@"%lu", (unsigned long)tag];
        NSURLSessionDownloadTask *downloadTask = _taskDict[keyName][@"downloadTask"];
        NSString *tempPath = _taskDict[keyName][@"tempPath"];
        if (downloadTask && tempPath) {
            [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
//                NSString *filename = _downTaskDict[keyName][@"filename"];
//                if (!filename) {
//                    filename = [NSString stringWithFormat:@"%i", (arc4random() % 1000000)];
//                };
//                NSString *filePath = [tempPath stringByAppendingPathComponent:[NSString stringWithFormat:@"_%@", filename]];
//                [resumeData writeToFile:filePath atomically:YES];
//                [_downTaskDict[keyName] setObject:filePath forKey:@"tempPathFullPath"];
                
                [resumeData writeToFile:tempPath atomically:YES];
            }];
        }
    }
}

/**
 * 继续（续传）下载任务。
 *
 */
- (void)downloadResume:(NSInteger)tag
{
    if (_taskDict) {
        NSString *keyName = [NSString stringWithFormat:@"%lu", (unsigned long)tag];
        
//        NSString *filePath = _downTaskDict[keyName][@"tempPathFullPath"];
        NSString *filePath = _taskDict[keyName][@"tempPath"];
        if (!filePath || filePath.length < 1) return;
        NSData *resumeData = [NSData dataWithContentsOfFile:filePath];
        if (!resumeData) return;
        NSURLSession *session = _taskDict[keyName][@"downloadSession"];
        
        if (session && resumeData) {
            NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithResumeData:resumeData];
            self.taskDict[keyName][@"downloadTask"] = downloadTask;
        }
    }

}

#pragma mark - HTTP FormData Post Methods

/**
 * 基于FormData的HTTP Post请求方法。默认为异步请求。
 *
 * @param urlString 服务端接口URL
 * @param tag 标志，便于请求回调后区分是哪个请求用的
 * @param userInfo 自己放的一些值，便于请求的回调函数中使用
 * @param postValues 表单上需要提交的字段。key是服务端确定的字段名，value是客户端输入的值
 * @param attachFiles 附件列表，数组里放的是ASIFormDataRequestFile对象
 * @param attachHeadInfo 附加的头信息
 * @param timeoutSeconds 请求超时时间（秒）
 * @param finishedBlock 请求和响应结束的Block回调
 * @param failedBlock 请求失败后的Block回调
 */
- (void)postFormData:(NSString * _Nonnull)urlString
                              tag:(NSInteger)tag
                         userInfo:(NSDictionary* _Nullable)userInfo
                       postValues:(NSMutableDictionary* _Nullable)postValues
                      attachFiles:(NSMutableArray* _Nullable)attachFiles
                   attachHeadInfo:(NSMutableDictionary* _Nullable)attachHeadInfo
                   timeoutSeconds:(NSTimeInterval)timeoutSeconds
                    finishedBlock:(ARNetFinishedBlock _Nonnull)finishedBlock
                      failedBlock:(ARNetFailedBlock _Nonnull)failedBlock
{
    [self postFormData:urlString
                                tag:tag
                           userInfo:userInfo
                       postBodyData:nil
                         postValues:postValues
                        attachFiles:attachFiles
                     attachHeadInfo:attachHeadInfo
                     timeoutSeconds:timeoutSeconds
                      finishedBlock:finishedBlock
                        failedBlock:failedBlock];
}

/**
 * 基于FormData的HTTP Post请求方法。默认为异步请求。
 * 注2：如果postBodyData有值，则参数postValues和attachFiles就会忽略。
 *
 * @param urlString 服务端接口URL
 * @param tag 标志，便于请求回调后区分是哪个请求用的
 * @param userInfo 自己放的一些值，便于请求的回调函数中使用
 * @param postValues 表单上需要提交的字段。key是服务端确定的字段名，value是客户端输入的值
 * @param attachFiles 附件列表，数组里放的是ASIFormDataRequestFile对象
 * @param attachHeadInfo 附加的头信息
 * @param timeoutSeconds 请求超时时间（秒）
 * @param finishedBlock 请求和响应结束的Block回调
 * @param failedBlock 请求失败后的Block回调
 */
- (void)postFormData:(NSString * _Nonnull)urlString
                              tag:(NSInteger)tag
                         userInfo:(NSDictionary* _Nullable)userInfo
                     postBodyData:(NSMutableData* _Nullable)postBodyData
                       postValues:(NSMutableDictionary* _Nullable)postValues
                      attachFiles:(NSMutableArray* _Nullable)attachFiles
                   attachHeadInfo:(NSMutableDictionary* _Nullable)attachHeadInfo
                   timeoutSeconds:(NSTimeInterval)timeoutSeconds
                    finishedBlock:(ARNetFinishedBlock _Nonnull)finishedBlock
                      failedBlock:(ARNetFailedBlock _Nonnull)failedBlock
{
    // 1 生成body数据
    NSString *boundary = @"RLNetworkBoundary";
//    NSString *prefix = @"--";
    NSMutableData *body;
    
    if (postBodyData) {
        body = postBodyData;
    }
    else {
        body = [NSMutableData data];
        if (postValues) { //如果有表单字段
            //1.1 添加post字段值
            for (NSString *fieldName in [postValues allKeys] ) {
                // 拼接表单字段部分
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", fieldName] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"%@\r\n", postValues[fieldName]] dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }
        //1.2 添加post文件
        if(attachFiles && [attachFiles count] > 0) {
            for (ARFormDataFile *file in attachFiles) {
                if (!file.filePath) continue;
                NSData *fileData = [NSData dataWithContentsOfFile:file.filePath];
                if (fileData) {
                    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", file.keyName, file.fileName] dataUsingEncoding:NSUTF8StringEncoding]];
                    if (file.contentType && file.contentType.length > 0) {
                        [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", file.contentType] dataUsingEncoding:NSUTF8StringEncoding]];
                    }
                    else {
                        [body appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream; charset=utf-8\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                    }
                    [body appendData:fileData];
                    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                }
            }
        }

    }
    
    // 1.3 body结尾
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 2 NSURLSession配置（使用defaultSessionConfiguration，可以使用缓存的Cache，Cookie，鉴权。）
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];

    // 3 创建NSURLSession
    NSURLSession *session;
    if (self.isUseDefaultQueue) { //使用自己默认的队列
        session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:self.defaultQueue];
    }
    else {
        session = [NSURLSession sessionWithConfiguration:config];
    }
    
    // 4 创建一个请求对象，以及设置请求参数
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    //setting header
//    for (NSString *key in attachHeadInfo.allKeys) {
//        [request setValue:attachHeadInfo[key] forHTTPHeaderField:key];
//    }
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
//    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)body.length] forHTTPHeaderField:@"Content-Length"];
    //setting body
    request.HTTPBody = body;
    
    // 5 创建一个数据任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //
        if (error) {
            failedBlock(error, userInfo);
        }
        else {
            finishedBlock(data, userInfo);
        }
    }];
    // 6 执行任务
    [task resume];
}

#pragma mark - NSURLSessionDownloadDelegate <NSURLSessionTaskDelegate>

/* Sent when a download task that has completed a download.  The delegate should
 * copy or move the file at the given location to a new location as it will be
 * removed when the delegate message returns. URLSession:task:didCompleteWithError: will
 * still be called.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"Temporary File :%@\n", location);
    
    if (!_taskDict) {
        NSLog(@">>> download finish, but can't get callback block");
        return;
    }
    // 根据内部任务ID取得用户设置的tag
    NSString *taskId = [NSString stringWithFormat:@"%lu", (unsigned long)downloadTask.taskIdentifier];
    NSDictionary *mappingDict = _taskDict[@"Mapping"];
    if (!mappingDict) return;
    NSString *userTag = mappingDict[taskId];
    if (!userTag) return;

    // 取出当前任务的相关参数
    NSString *destinationPath = _taskDict[userTag][@"destinationPath"];
    NSString *filename = _taskDict[userTag][@"filename"];
//    ARNetProgressBlock progressBlock = _downTaskBlockDict[userTag][@"progressBlock"];
    ARNetFinishedBlock finishedBlock = _taskDict[userTag][@"finishedBlock"];
    ARNetFailedBlock failedBlock = _taskDict[userTag][@"failedBlock"];
    NSDictionary *userInfo = _taskDict[userTag][@"userInfo"];
    
    NSURL *destFullPath;
    // 检查参数destinationPath是否含有文件名，没有则从url里取文件名
    if ([[destinationPath lastPathComponent] rangeOfString:@"."].length == 1)
        destFullPath = [NSURL fileURLWithPath:destinationPath];
    else
        destFullPath = [[NSURL fileURLWithPath:destinationPath] URLByAppendingPathComponent:filename];

    // 将下载的临时文件移动到目标目录
    NSError *err = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 如果目标目录存在同名文件，则删除后再移动新
    if ([fileManager fileExistsAtPath:[destFullPath path]]) {
        [fileManager removeItemAtURL:destFullPath error: &err];
    }
    // 移动文件
    if ([fileManager moveItemAtURL:location
                             toURL:destFullPath
                             error: &err])
    {
        NSLog(@"File is saved to =%@",destFullPath);
        if (finishedBlock) {
            finishedBlock(nil, userInfo); //执行回调Block
        }
    }
    else
    {
        NSLog(@"failed to move: %@",[err userInfo]);
        if (failedBlock) {
            failedBlock(err, userInfo); //执行回调Block
        }
    }
    
}

//@optional
/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    //You can get progress here
    NSLog(@"Received: %lld bytes (Downloaded: %lld bytes)  Expected: %lld bytes.\n",
          bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    
    if (_taskDict) {
        NSString *taskId = [NSString stringWithFormat:@"%lu", (unsigned long)downloadTask.taskIdentifier];
        NSDictionary *mappingDict = _taskDict[@"Mapping"];
        if (!mappingDict) return;
        NSString *userTag = mappingDict[taskId];
        if (!userTag) return;
        
        ARNetProgressBlock progressBlock = _taskDict[userTag][@"progressBlock"];
        if (progressBlock) {
            progressBlock(bytesWritten, totalBytesWritten);
        }
    }

}

///* Sent when a download has been resumed. If a download failed with an
// * error, the -userInfo dictionary of the error will contain an
// * NSURLSessionDownloadTaskResumeData key, whose value is the resume
// * data.
// */
//- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
// didResumeAtOffset:(int64_t)fileOffset
//expectedTotalBytes:(int64_t)expectedTotalBytes
//{
//    
//}

#pragma mark -  KVO回调
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{

    
    if (object == self.defaultQueue && [keyPath isEqualToString:@"operations"])
    {
        if (0 == self.defaultQueue.operations.count)
        {
#if DEBUG
            NSLog(@"Finished queue, request count=%lu",(unsigned long)self.defaultQueue.operations.count);
#endif
            //
            [_defaultQueue setSuspended:YES];
            //
            if (defaultQueueFinishBlock) {
                defaultQueueFinishBlock();
            }
            
            
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
