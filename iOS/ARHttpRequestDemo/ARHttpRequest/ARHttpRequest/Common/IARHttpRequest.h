/**
 * @file IARHttpRequest.h
 * @brief 定义一个网络通信的接口类，对上层业务调用统一接口，对下层具体网络库以适配器模式扩展
 * @details 兼容ASIHttpRequest和NSURLSession
 * @version v1.0
 * @author 创建人：LongJun
 * @date 创建日期：2016-05-30
 * @copyright Copyright (c) 2009-2016 ArwerSoftware All rights reserved.
 *
 * @date 修改日期，例：xxxx年x月xx日
 * @details 修改历史记录：详细说明修改的内容。
 * @author 修改人的名字及单位
 *
 * @date 修改日期，例：xxxx年x月xx日
 * @details 修改历史记录：详细说明修改的内容。
 * @author 修改人的名字及单位
 *
 */
#import <Foundation/Foundation.h>

/** 默认网络请求超时的秒数 */
#define REQUEST_DEFAULT_TIMEOUT 30

typedef void (^ARNetFinishedBlock)(NSData * _Nullable data, NSDictionary * _Nullable userInfo);
typedef void (^ARNetFailedBlock)(NSError * _Nonnull error, NSDictionary * _Nullable userInfo);
typedef void (^ARNetProgressBlock)(unsigned long long progressingSize, unsigned long long totalSize);


@protocol IARHttpRequest <NSObject>

@required
#pragma mark - 默认队列相关

/**
 * 是否启用默认队列
 *
 * @param isOn YES=启用；NO=不启用
 */
- (void)setQueueIsOn:(BOOL)isOn;

/**
 * 定义队列完成时的回调Block
 *
 * @param finishBlock 回调Block
 */
- (void)setQueueFinishedBlock:(void(^ _Nullable)(void))finishBlock;

/**
 * 设置默认队列最大并发数
 *
 * @return 返回一个NSOperationQueue实例对象
 */
- (void)setQueueMaxConcurrentOperationCount:(NSInteger)count;

/**
 * 开始默认队列
 *
 */
- (void)queueStart;

/**
 * 停止默认队列
 *
 */
- (void)queueStop;

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
             failedBlock:(ARNetFailedBlock _Nonnull)failedBlock;

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
             failedBlock:(ARNetFailedBlock _Nonnull)failedBlock;

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
             failedBlock:(ARNetFailedBlock _Nonnull)failedBlock;

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
             failedBlock:(ARNetFailedBlock _Nonnull)failedBlock;

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
             failedBlock:(ARNetFailedBlock _Nonnull)failedBlock;

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
                  failedBlock:(ARNetFailedBlock _Nonnull)failedBlock;

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
                  failedBlock:(ARNetFailedBlock _Nonnull)failedBlock;

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
                  failedBlock:(ARNetFailedBlock _Nonnull)failedBlock;

- (void)postJson:(NSString * _Nonnull)urlString
                          tag:(NSInteger)tag
                     userInfo:(NSDictionary* _Nullable)userInfo
                     jsonDict:(NSDictionary* _Nonnull)jsonDict
               attachHeadInfo:(NSMutableDictionary* _Nullable)attachHeadInfo
               timeoutSeconds:(NSTimeInterval)timeoutSeconds
                finishedBlock:(ARNetFinishedBlock _Nonnull)finishedBlock
                  failedBlock:(ARNetFailedBlock _Nonnull)failedBlock;

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
                 failedBlock:(ARNetFailedBlock _Nonnull)failedBlock;

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
                 failedBlock:(ARNetFailedBlock _Nonnull)failedBlock;

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
              failedBlock:(ARNetFailedBlock _Nonnull)failedBlock;

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
              failedBlock:(ARNetFailedBlock _Nonnull)failedBlock;



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
       failedBlock:(ARNetFailedBlock _Nonnull)failedBlock;

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
       failedBlock:(ARNetFailedBlock _Nonnull)failedBlock;

#pragma mark - Download Methods

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
         failedBlock:(ARNetFailedBlock _Nonnull)failedBlock;

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
         failedBlock:(ARNetFailedBlock _Nonnull)failedBlock;

/**
 * 暂停下载任务。
 *
 */
- (void)downloadPause:(NSInteger)tag;

/**
 * 继续（恢复）下载任务。
 * 注意：当前类如果被释放了使用该方法无效（因为缓存的request对象不存在了）；而是调用“downloadFile”方法进行恢复下载
 *
 */
- (void)downloadResume:(NSInteger)tag;


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
                      failedBlock:(ARNetFailedBlock _Nonnull)failedBlock;

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
                      failedBlock:(ARNetFailedBlock _Nonnull)failedBlock;



@end
