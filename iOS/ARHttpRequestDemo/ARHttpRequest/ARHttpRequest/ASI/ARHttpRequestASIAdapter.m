/**
 * @file ARHttpRequestASIAdapter.m
 * @brief 实现IRLNetwork接口，封装ASIHTTPRequest对网络通信的操作
 * @details
 * @version v1.0
 * @author 创建人：LongJun
 * @date 创建日期：2016-05-30
 * @copyright Copyright (c) 2009-2016 ArwerSoftware All rights reserved.
 *
 * @date 2016-06-18
 * @details 完善队列部分功能
 * @author LongJun
 *
 * @date 修改日期，例：xxxx年x月xx日
 * @details 修改历史记录：详细说明修改的内容。
 * @author 修改人的名字及单位
 *
 */
#import "ARHttpRequestASIAdapter.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"
#import "ARFormDataFile.h"
#import "ARHttpRequestUtils.h"

#define kParams             @"_Params_"
#define kParams_UrlString   @"urlString"
#define kParams_Tag         @"tag"
#define kParams_UserInfo    @"userInfo"
#define kParams_DestPath    @"destinationPath"
#define kParams_TmpPath     @"tempPath"
#define kParams_Headers     @"attachHeadInfo"
#define kParams_Timeout     @"timeoutSeconds"
#define kParams_ProgressBlock   @"progressBlock"
#define kParams_FinishedBlock   @"finishedBlock"
#define kParams_FailedBlock     @"failedBlock"

@interface ARHttpRequestASIAdapter()
{
    void(^defaultQueueFinishBlock)(void);
}
@property (nonatomic, strong) ASINetworkQueue *defaultQueue;
@property (nonatomic) BOOL isUseDefaultNetworkQueue;

// 记录ASIHTTPRequest的数组，作用：
// 1、类析构（如退出页面)时清空delegate和取消操作，防止闪退和异常
// 2、方法间操作ASIHTTPRequest对象，如下载暂停和恢复
@property (nonatomic, strong) NSMutableArray *requestRecorder;

@end


@implementation ARHttpRequestASIAdapter

#pragma mark - Class lift cycle

- (id)init
{
    if ((self=[super init]))
    {
        
        ////// 初始化request清理管理器 ///////
        self.requestRecorder = [NSMutableArray array];

    }
    return self;
}

- (void)dealloc
{
#if DEBUG
    NSLog(@"LogicBaseForASIHttp dealloc");
#endif
    
    // 清理默认队列 Call this to reset a queue - it will cancel all operations, clear delegates, and suspend operation
    [self.defaultQueue reset];
    
    // 清理请求
    for (int i=0; i<self.requestRecorder.count; i++) {
        ASIHTTPRequest *request = self.requestRecorder[i];
        [request clearDelegatesAndCancel];
    }
    [self.requestRecorder removeAllObjects];
    self.requestRecorder = nil;
    
}

#pragma mark - 默认队列相关

/**
 * 是否启用默认队列
 *
 * @param isOn YES=启用；NO=不启用
 */
- (void)setQueueIsOn:(BOOL)isOn {
    self.isUseDefaultNetworkQueue = isOn;
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

- (ASINetworkQueue*)defaultQueue
{
    if (!_defaultQueue) {
        //////// 初始化defaultQueue ///////
        _defaultQueue = [ASINetworkQueue queue];
        
        _defaultQueue.delegate = self;
        _defaultQueue.queueDidFinishSelector = @selector(queueFinished:);
        
        // 当ASINetworkQueue中的一个request失败时，默认情况下，ASINetworkQueue会取消所有其他的request。要禁用这个特性则设置NO.
        _defaultQueue.shouldCancelAllRequestsOnFailure = NO;
        _defaultQueue.maxConcurrentOperationCount = 1; //默认并发数为1
        
//        [_defaultQueue go];
    }
    return _defaultQueue;
}

/// 队列中所有请求完成的回调
- (void)queueFinished:(ASINetworkQueue *)queue
{
#if DEBUG
    NSLog(@"Finished queue, request count=%d",[queue requestsCount]);
#endif
    if (defaultQueueFinishBlock) {
        defaultQueueFinishBlock();
    }
}

/**
 * 开始默认队列
 *
 */
- (void)queueStart
{
    if (_defaultQueue) {
        [_defaultQueue go];
    }
}

/**
 * 停止默认队列
 *
 */
- (void)queueStop
{
    if (_defaultQueue) {
        // 清理请求
        for (ASIHTTPRequest *request in _defaultQueue.operations) {
            [request clearDelegatesAndCancel];
        }
        if (_requestRecorder) {
            [_requestRecorder removeAllObjects];
            _requestRecorder = nil;
        }
        
        // 清理默认队列 Call this to reset a queue - it will cancel all operations, clear delegates, and suspend operation
        [_defaultQueue reset];
        
        // callback
        if (defaultQueueFinishBlock) {
            defaultQueueFinishBlock();
        }
        
    }
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
    
//    NSString *encodedUrl = [fullUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; //ios9+弃用
//    NSString *encodedUrl = [fullUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];//ASIHTTPRequest报错“Unable to start HTTP connection”
    
//#if DEBUG
//    NSLog(@"get, encoded urlString=%@",encodedUrl);
//#endif
    
    NSURL *url = [NSURL URLWithString:[ARHttpRequestUtils encodeUrlLastComponent:encodedUrl]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request setValidatesSecureCertificate:NO];
    [request setUserInfo:userInfo];
    [request setTag:tag];
    [request setTimeOutSeconds:timeoutSeconds];
    
    [self sendRequest:request
        finishedBlock:finishedBlock
          failedBlock:failedBlock];
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
    NSData *jsonTmpData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonTmpData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
    if(error) {
#if DEBUG
        NSLog(@">>> postJson, json解析失败：%@",error);
#endif
        if (failedBlock) {
            failedBlock(error, userInfo);
        }
        return;
    }
    
    [self postJson:urlString
                            tag:tag
                       userInfo:userInfo
                       jsonDict:jsonDict
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
#if DEBUG
    NSLog(@"post, urlString=%@",urlString);
    if (postData) {
        NSString *tmpStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
        NSLog(@"postData to string = %@",tmpStr);
        //        [tmpStr release];
    }
#endif
    
//    NSString *utf8=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSURL *url=[NSURL URLWithString:utf8];
//    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSURL *url=[NSURL URLWithString:urlString];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    request.userInfo = userInfo;
    request.tag = tag;
    [request setTimeOutSeconds: timeoutSeconds];
    
    if (attachHeadInfo && attachHeadInfo.allKeys.count > 0) {
        for (NSString *key in attachHeadInfo.allKeys) {
            [request addRequestHeader:key value:[attachHeadInfo objectForKey:key]];
        }
    }
    //[request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
    //[request addRequestHeader:@"Content-Type" value:@"application/json; charset=utf-8"];
    [request addRequestHeader:@"Content-Type" value: contenType];
    [request  setRequestMethod:@"POST"];
    [request setValidatesSecureCertificate:NO];
    [request setShouldContinueWhenAppEntersBackground:YES];
    
    if (postData) {
//        [request appendPostData:postData];
        [request setPostBody:[NSMutableData dataWithData:postData]];
    }
    
    [self sendRequest:request
        finishedBlock:finishedBlock
          failedBlock:failedBlock];
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
#if DEBUG
    NSLog(@"uploadFile, urlString=%@",urlString);
#endif
    // 1 init
    NSURL *url=[NSURL URLWithString:urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    request.tag = tag;
    request.userInfo = userInfo;
    
    // 2 添加头
    if (attachHeadInfo && attachHeadInfo.allKeys.count > 0) {
        for (NSString *key in attachHeadInfo.allKeys) {
            [request addRequestHeader:key value:[attachHeadInfo objectForKey:key]];
        }
    }
    
    //添加post文件
    if (fileData) {
        [request setPostBody:fileData];
    }
    
    [request setTimeOutSeconds: timeoutSeconds];
    [request setShouldContinueWhenAppEntersBackground:YES];
    [request setShowAccurateProgress:YES];//显示精确的进度
    
    //上传的字节数的回调
    static long long sentedBytes = 0;
    ASIProgressBlock asiProgressBlock = ^(unsigned long long size, unsigned long long total){
        sentedBytes += size;
        progressBlock(sentedBytes, total);
    };
    [request setprogressBlock:asiProgressBlock];
    
    //上传完成时将静态变量sentedBytes归0.
    ARNetFinishedBlock newFinishedBlock = ^(NSData * _Nullable data, NSDictionary * _Nullable userInfo) {
        sentedBytes = 0;
        finishedBlock(data, userInfo);
    };
    
    [self sendRequest:request
        finishedBlock:newFinishedBlock
          failedBlock:failedBlock];
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
#if DEBUG
    NSLog(@"downloadFile, urlString=%@",urlString);
#endif
    // 1 检查参数
    if (!progressBlock || !finishedBlock || !failedBlock) {
        return;
    }
    
    NSString *urlFilename = [urlString lastPathComponent];
    // 2 创建ASIHTTPRequest请求对象
    /*
     备注：
     比如urlString=http://localhost:3000/download/凯文·凯利：Out of Control.pdf
     使用stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding编码后为：http://localhost:3000/download/%E5%87%AF%E6%96%87%C2%B7%E5%87%AF%E5%88%A9%EF%BC%9AOut%20of%20Control.pdf ，这个ASI可以正常访问，但是该API因为iOS9+已经用，官方API变为stringByAddingPercentEncodingWithAllowedCharacters，使用新API及其URLHostAllowedCharacterSet参数编码后为：http%3A%2F%2Flocalhost%3A3000%2Fdownload%2F%E5%87%AF%E6%96%87%C2%B7%E5%87%AF%E5%88%A9%EF%BC%9AOut%20of%20Control.pdf，调用ASIHTTPRequest则报错“Unable to start HTTP connection”。
     所以折中解决方法是urlString只编码文件名部分。
     */
//    NSString *encodedUrl = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; //ios9+弃用
//    NSString *encodedUrl = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
//    NSURL *url=[NSURL URLWithString:encodedUrl];
    
    NSURL *url = [NSURL URLWithString:[ARHttpRequestUtils encodeUrlLastComponent:urlString]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    // 3 设置参数
    request.tag = tag;

    // 缓存参数信息到userInfo，以便下载恢复时使用
    if (!userInfo) userInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (urlString) [dict setObject:(urlString) forKey:kParams_UrlString];
    [dict setObject:[NSNumber numberWithInteger:tag] forKey:kParams_Tag];
    [dict setObject:userInfo forKey:kParams_UserInfo];
    [dict setObject:destinationPath forKey:kParams_DestPath];
    [dict setObject:tempPath forKey:kParams_TmpPath];
    if (attachHeadInfo) [dict setObject:attachHeadInfo forKey:kParams_Headers];
    [dict setObject:[NSNumber numberWithDouble:timeoutSeconds] forKey:kParams_Timeout];
    if (progressBlock) [dict setObject:progressBlock forKey:kParams_ProgressBlock];
    [dict setObject:finishedBlock forKey:kParams_FinishedBlock];
    [dict setObject:failedBlock forKey:kParams_FailedBlock];
    
    [userInfo setObject:dict forKey:kParams];
    request.userInfo = userInfo;
    
    // 添加需要附加的头信息
    if (attachHeadInfo && attachHeadInfo.allKeys.count > 0) {
        for (NSString *key in attachHeadInfo.allKeys) {
            [request addRequestHeader:key value:[attachHeadInfo objectForKey:key]];
        }
    }
    
    [request setTimeOutSeconds: timeoutSeconds];
    [request setShouldContinueWhenAppEntersBackground:YES];
    [request setShowAccurateProgress:YES];//显示精确的进度
    [request setAllowResumeForFileDownloads:YES]; //允许断点续传
    
    // 设置下载目标路径和临时路径(ASI需要带文件名的完整路径)
    NSString *destFullPath, *tmpFullPath;
    // 检查参数destinationPath是否含有文件名，没有则从url里取文件名
    if ([[destinationPath lastPathComponent] rangeOfString:@"."].length == 1)
        destFullPath = destinationPath;
    else
        destFullPath = [destinationPath stringByAppendingPathComponent:urlFilename];
    // 检查参数tempPath是否含有文件名，没有则从url里取文件名
    if ([[tempPath lastPathComponent] rangeOfString:@"."].length == 1)
        tmpFullPath = tempPath;
    else
        tmpFullPath = [tempPath stringByAppendingPathComponent:urlFilename];
    
    [request setDownloadDestinationPath:destFullPath]; //需要完整带文件名的完整路径
    [request setTemporaryFileDownloadPath:tmpFullPath]; //需要完整带文件名的完整路径
    
    // 下载的字节数的回调
    static long long downloadedBytes = 0;
    ASIProgressBlock asiProgressBlock = ^(unsigned long long size, unsigned long long total){
        downloadedBytes += size;
        progressBlock(downloadedBytes, total);
    };
    [request setBytesReceivedBlock:asiProgressBlock];

    // 下载完成时将静态变量downloadedBytes归0.
    ARNetFinishedBlock newFinishedBlock = ^(NSData * _Nullable data, NSDictionary * _Nullable userInfo) {
        downloadedBytes = 0;
        finishedBlock(data, userInfo);
    };
    
    // 3 send request
    [self sendRequest:request
        finishedBlock:newFinishedBlock
          failedBlock:failedBlock];
}

/**
 * 暂停下载任务。
 *
 */
- (void)downloadPause:(NSInteger)tag
{
    if (!_requestRecorder || _requestRecorder.count < 1) return;
    
    // 
    for (int i=0; i<self.requestRecorder.count; i++) {
        ASIHTTPRequest *request = self.requestRecorder[i];
        if (request.tag == tag) {
            [request cancel]; //取消操作但不做清理
            break;
        }
    }
}

/**
 * 继续（恢复）下载任务。
 * 注意：当前类如果被释放了使用该方法无效（因为缓存的request对象不存在了）；而是调用“downloadFile”方法进行恢复下载
 *
 */
- (void)downloadResume:(NSInteger)tag
{
    if (!_requestRecorder || _requestRecorder.count < 1) return;
    
    ASIHTTPRequest *request;
    for (int i=0; i<self.requestRecorder.count; i++) {
        ASIHTTPRequest *req = self.requestRecorder[i];
        if (req.tag == tag) {
            request = req;
            break;
        }
    }
    if (!request.userInfo) return;
    
    NSDictionary *paramDict = request.userInfo[kParams];
    if (request && paramDict) {
        // 复制参数
        NSString *urlString = (paramDict[kParams_UrlString] ? [paramDict[kParams_UrlString] copy] : nil);
        NSMutableDictionary *userInfo = (paramDict[kParams_UserInfo] ? [paramDict[kParams_UserInfo] copy] : nil);
        NSString *destinationPath = (paramDict[kParams_DestPath] ? [paramDict[kParams_DestPath] copy] : nil);
        NSString *tempPath = (paramDict[kParams_TmpPath] ? [paramDict[kParams_TmpPath] copy] : nil);
        NSMutableDictionary *attachHeadInfo = (paramDict[kParams_Headers] ? [paramDict[kParams_Headers] copy] : nil);
        NSInteger timeOutSeconds = (paramDict[kParams_Timeout] ? (NSInteger)[paramDict[kParams_Timeout] integerValue] : REQUEST_DEFAULT_TIMEOUT);
        ARNetProgressBlock progressBlock = (paramDict[kParams_ProgressBlock] ? [paramDict[kParams_ProgressBlock] copy] : nil);
        ARNetFinishedBlock finishedBlock = (paramDict[kParams_FinishedBlock] ? [paramDict[kParams_FinishedBlock] copy] : nil);
        ARNetFailedBlock failedBlock = (paramDict[kParams_FailedBlock] ? [paramDict[kParams_FailedBlock] copy] : nil);
        
        // 清理和释放旧的ASIHTTPRequest
        [request clearDelegatesAndCancel];
        // 缓存数组移除旧的ASIHTTPRequest
        [_requestRecorder removeObject:request];
        
        // 开始一个新的下载（就是创建新一个ASIHTTPRequest）
        [self downloadFile:urlString
                       tag:tag
                  userInfo:userInfo
           destinationPath:destinationPath
                  tempPath:tempPath
            attachHeadInfo:attachHeadInfo
            timeoutSeconds:timeOutSeconds
             progressBlock:progressBlock
             finishedBlock:finishedBlock
               failedBlock:failedBlock];
        
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
#if DEBUG
    NSLog(@"postFormData, urlString=%@",urlString);
#endif
    // 1 init
    NSURL *url=[NSURL URLWithString:urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    request.tag = tag;
    request.userInfo = userInfo;
    
    // 2 添加头
    if (attachHeadInfo && attachHeadInfo.allKeys.count > 0) {
        for (NSString *key in attachHeadInfo.allKeys) {
            [request addRequestHeader:key value:[attachHeadInfo objectForKey:key]];
        }
    }
    
    if (postBodyData) {
        [request setPostBody:postBodyData];
    }
    else {
        
        //2 添加post字段值
        for (NSString *keyName in [postValues allKeys] ) {
            
            [request setPostValue:(NSString*)[postValues objectForKey:keyName] forKey:keyName];
        }
        
        //3 添加post文件
        if(attachFiles && [attachFiles count] > 0) {
            for (ARFormDataFile *file in attachFiles) {
                if (file.fileName && file.contentType) {
                    [request setFile:file.filePath withFileName:file.fileName andContentType:file.contentType forKey:file.keyName];
                }
                else {
                    [request setFile:file.filePath forKey:file.keyName];
                }
            }
        }
    }
    
    
    [request setTimeOutSeconds: timeoutSeconds];
    [request setShouldContinueWhenAppEntersBackground:YES];
    
    
    [self sendRequest:request
        finishedBlock:finishedBlock
          failedBlock:failedBlock];
}

#pragma mark - 2 发送一个ASIHttpRequest请求
/**
 * 发送一个请求。默认为异步请求。
 *
 * 注意：该方法内部原则上不对request做任何参数赋值，需在外部初始化好；该方法内部原则上仅作队列和释放管理。
 *
 * @param request ASIHTTPRequest或者ASIFormDataRequest对象
 * @param finishedBlock 请求和响应结束的Block回调
 * @param failedBlock 请求失败后的Block回调
 */
- (void)sendRequest:(ASIHTTPRequest*)request
      finishedBlock:(ARNetFinishedBlock _Nonnull)finishedBlock
        failedBlock:(ARNetFailedBlock _Nonnull)failedBlock
{
#if DEBUG
    NSLog(@"sendRequest, request url=%@",request.url.absoluteString);
#endif
    
    if (!request) {
        NSException *ex = [NSException exceptionWithName:@"sendRequest Fail" reason:@"ASIHTTPRequest object is nil" userInfo:nil];
        [ex raise];
        return;
    }
    else if (!request.requestMethod || [request.requestMethod isEqualToString:@""]) {
        NSException *ex = [NSException exceptionWithName:@"sendRequest Fail" reason:@"request.requestMethod is nil or empty" userInfo:nil];
        [ex raise];
        return;
    }
    
    // 请求加入缓存，便于操作和清理
    [self.requestRecorder addObject:request];
    //
    //    //    NSString *requestTag = [NSString stringWithFormat:@"%li", (long)request.tag];
    //    //
    //    //    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //    //    [dict setObject:request forKey:@"Request"];
    //    //    [dict setObject:[NSNumber numberWithInteger:request.tag] forKey:@"Tag"];
    //    //    [dict setObject:finishedBlock forKey:@"RequestCompletionBlock"];
    //    //    [dict setObject:failedBlock forKey:@"RequestFailBlock"];
    //    //    [self.requestInfo setObject:dict forKey:requestTag];
    //    [request setCompletionBlock:finishedBlock];
    //    [request setFailedBlock:failedBlock];
    //    [request setDataReceivedBlock:dataReceivedBlock];
    
    
    // 请求完成时，把它从数组移除
    __weak ASIHTTPRequest *weakRequest = request;
    __weak __typeof(self)  weakSelf = self;
    
    ASIBasicBlock beforFinishBlock = request.didCompletionBlock;
    ASIBasicBlock beforfailedBlock = request.didFailedBlock;
    
    ASIBasicBlock block = ^(void) {
        if (weakRequest) {
            [weakSelf.requestRecorder removeObject:weakRequest];
        }
    };
    
    ASIBasicBlock reqFinishBlock;
    ASIBasicBlock reqFailedBlock;
    
    if (beforFinishBlock) {
        reqFinishBlock = ^(void) {
            finishedBlock(weakRequest.responseData, weakRequest.userInfo);
            beforFinishBlock();
            block();
        };
        
    } else {
        reqFinishBlock = ^(void) {
            finishedBlock(weakRequest.responseData, weakRequest.userInfo);
            block();
        };
    }
    
    if (beforfailedBlock) {
        reqFailedBlock = ^(void) {
            failedBlock(weakRequest.error, weakRequest.userInfo);
            beforfailedBlock();
            block();
        };
        
    } else {
        reqFailedBlock = ^(void) {
            failedBlock(weakRequest.error, weakRequest.userInfo);
            block();
        };
    }
    
    [request setCompletionBlock:reqFinishBlock];
    [request setFailedBlock:reqFailedBlock];
//    // 如果出现错误 Authentication needed ，添加下面这行解决问题
//    [request setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
    
    if (self.isUseDefaultNetworkQueue) {
        [self.defaultQueue addOperation:request];
    }
    else{
        //        request.delegate = self;
        //        request.uploadProgressDelegate = self;
        //        request.downloadProgressDelegate = self;
        [request startAsynchronous];
    }
}

@end
