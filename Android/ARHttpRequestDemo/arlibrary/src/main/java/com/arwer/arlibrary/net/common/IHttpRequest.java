package com.arwer.arlibrary.net.common;

import com.arwer.arlibrary.threads.TaskQueue;

import java.io.File;
import java.net.MalformedURLException;
import java.util.HashMap;
import java.util.Map;


/**
 * @file IHttpRequest.java
 * @brief ARHttpRequest是一个网络通信的适配层，对上层业务调用提供简明接口，对下层具体网络库轻度包装，并以适配器模式进行扩展和无缝替换。
 * @details https://github.com/longjun3000/ARHttpRequest
 * 现有功能：
 * 1、提供简明的网络操作API，包括get/post/postJson/postXml/postSoapXml/postFormData/downloadFile/uploadFile等。
 * 2、downloadFile支持断点续传。
 * 3、默认网络操作都为异步方式，提供完成/失败的回调Block，下载有进度状态Block。
 * 4、提供简洁的队列操作方式，以及队列完成的回调Block。
 * 5、ARHttpRequest实例类析构时自动释放和清理相关对象的引用，上层代码无需关注具体网络库的内存释放问题。
 * 6、iOS现提供NSURLSession和ASIHTTPRequest的适配器；Android现提供HttpURLConnection的适配器。
 * @version v1.0
 * @author 创建人：LongJun
 * @date 创建日期：2016-02-20
 * @copyright Copyright (c) 2016 ArwerSoftware All rights reserved.
 *
 */
public interface IHttpRequest {

    ////////////////////////////////////////////////////////////////
    // 常量
    ////////////////////////////////////////////////////////////////

    /** 默认网络请求超时的秒数 */
    public static final int REQUEST_DEFAULT_TIMEOUT = 1000*30; //30秒


    ////////////////////////////////////////////////////////////////
    // 队列相关函数
    ////////////////////////////////////////////////////////////////

    /**
     * 是否启用默认队列
     *
     * @param isOn YES=启用；NO=不启用
     */
    public void setQueueIsOn(boolean isOn);

    /**
     * 定义队列完成时的回调代码
     *
     * @param finishBlock 回调Block
     */
    public void setQueueFinishedCallback(TaskQueue.IQueueFinishedCallback finishBlock);

    /**
     * 设置最大并发线程数
     * @param maxConcurrentRequestCount
     */
    public void setMaxConcurrentThreadCount(int maxConcurrentRequestCount);

    /**
     * 任务队列开始执行
     */
    public void queueStart();

    /**
     * 任务队列停止、清理和触发队列完成的回调
     */
    public void queueStop();


    ////////////////////////////////////////////////////////////////
    // Get相关函数
    ////////////////////////////////////////////////////////////////


    /**
     * HTTP Get 请求方法。默认为异步请求。
     *
     * @param callback  请求成功或失败后的回调
     */
    public void get(String urlString, int tag, IHttpCallback callback) throws Exception;


    /**
     * HTTP Get 请求方法。默认为异步请求。
     *
     * @param timeoutMillis 请求超时时间（毫秒）
     * @param callback       请求成功或失败后的回调
     */
    public void get(String urlString,
                    int tag,
                    int timeoutMillis,
                    IHttpCallback callback) throws Exception;

    /**
     * HTTP Get 请求方法。默认为异步请求。
     *
     * @param params         URL参数字典

     * @param timeoutMillis 请求超时时间（毫秒）
     * @param callback       请求成功或失败后的回调
     */
    public void get(String urlString,
                    int tag,
                    HashMap<String, String> params,
                    int timeoutMillis,
                    IHttpCallback callback) throws Exception;

    /**
     * HTTP Get 请求方法。默认为异步请求。
     *
     * @param params         URL参数字典
     * @param timeoutMillis 请求超时时间（毫秒）
     * @param callback       请求成功或失败后的回调
     */
    public void get(String urlString,
                    int tag,
                    HashMap<String, String> params,
                    HashMap<String, String> attachHeadInfo,
                    int timeoutMillis,
                    IHttpCallback callback) throws Exception;


    ////////////////////////////////////////////////////////////////
    // Post相关函数
    ////////////////////////////////////////////////////////////////

    /**
     * HTTP post json 请求方法。默认为异步请求。
     *
     * @param jsonString json字符串格式的发送内容
     * @param callback   请求成功或失败后的回调
     */
    public void postJson(String urlString,
                         int tag,
                         String jsonString,
                         IHttpCallback callback) throws Exception;

    /**
     * HTTP post json 请求方法。默认为异步请求。
     *
     * @param jsonString     json字符串格式的发送内容
     * @param attachHeadInfo 附加的头部的信息
     * @param timeoutMillis 请求超时时间（毫秒）
     * @param callback       请求成功或失败后的回调
     */
    public void postJson(String urlString,
                         int tag,
                         String jsonString,
                         HashMap<String, String> attachHeadInfo,
                         int timeoutMillis,
                         IHttpCallback callback) throws Exception;


    /**
     * HTTP Post 常规 XML 请求方法。默认为异步请求。
     *
     * 注：请在子类实现覆盖方法requestFinished、requestFailed、queueFinished（如果用了队列），
     * 以实现请求响应后的回调处理。
     *
     * @param xmlString 需要post的XML字符串
     * @param callback  请求成功或失败后的回调
     */
    public void postXml(String urlString,
                        int tag,
                        String xmlString,
                        IHttpCallback callback) throws Exception;

    /**
     * HTTP Post 常规 XML 请求方法。默认为异步请求。
     *
     * 注：请在子类实现覆盖方法requestFinished、requestFailed、queueFinished（如果用了队列），
     * 以实现请求响应后的回调处理。
     *
     * @param xmlString      需要post的XML字符串
     * @param attachHeadInfo 附加的头信息
     * @param timeoutMillis 请求超时时间（毫秒）
     * @param callback       请求成功或失败后的回调
     */
    public void postXml(String urlString,
                        int tag,
                        String xmlString,
                        HashMap<String, String> attachHeadInfo,
                        int timeoutMillis,
                        IHttpCallback callback) throws Exception;

    /**
     * HTTP Post Soap XML (WebService) 请求方法。默认为异步请求。
     *
     * 注：请在子类实现覆盖方法requestFinished、requestFailed、queueFinished（如果用了队列），
     * 以实现请求响应后的回调处理。
     *
     * @param soapAction     SOAP Action
     * @param postData       需要post的数据
     * @param attachHeadInfo 附加的头信息
     * @param timeoutMillis 请求超时时间（毫秒）
     * @param callback       请求成功或失败后的回调
     */
    public void postSoapXml(String urlString,
                            int tag,
                            String soapAction,
                            byte[] postData,
                            HashMap<String, String> attachHeadInfo,
                            int timeoutMillis,
                            IHttpCallback callback) throws MalformedURLException, Exception;

    /**
     * HTTP Post请求方法。默认为异步请求。
     *
     * 注：请在子类实现覆盖方法requestFinished、requestFailed、queueFinished（如果用了队列），
     * 以实现请求响应后的回调处理。
     *
     * @param postData       需要post的数据
     * @param contenType     Content-Type
     * @param attachHeadInfo 附加的头信息
     * @param timeoutMillis 请求超时时间（毫秒）
     * @param callback       请求成功或失败后的回调
     */
    public void post(String urlString,
                     int tag,
                     byte[] postData,
                     String contenType,
                     HashMap<String, String> attachHeadInfo,
                     int timeoutMillis,
                     IHttpCallback callback) throws Exception;

    ////////////////////////////////////////////////////////////////
    // 上传下载相关函数
    ////////////////////////////////////////////////////////////////

    /**
     * 上传一个文件。默认为异步请求。
     *
     * 注：请在子类实现覆盖方法requestFinished、requestFailed、queueFinished（如果用了队列），
     * 以实现请求响应后的回调处理。
     *
     * @param fullFilePath   完整的文件路径名
     * @param attachHeadInfo 附加的头信息
     * @param timeoutMillis 请求超时时间（毫秒）
     * @param callback       请求成功或失败后的回调
     */
    public void uploadFile(String urlString,
                           int tag,
                           String fullFilePath,
                           HashMap<String, String> attachHeadInfo,
                           int timeoutMillis,
                           IHttpCallback callback) throws Exception;

    /**
     * 上传一个文件。默认为异步请求。
     *
     * 注：请在子类实现覆盖方法requestFinished、requestFailed、queueFinished（如果用了队列），
     * 以实现请求响应后的回调处理。
     *
     * @param fileKeyName    文件的Key名，即为Web表单中input标签的name
     * @param fullFilePath   完整的文件路径名
     * @param attachHeadInfo 附加的头信息
     * @param timeoutMillis 请求超时时间（毫秒）
     * @param callback       请求成功或失败后的回调
     */
    public void uploadFile(String urlString,
                           int tag,
                           String fileKeyName,
                           String fullFilePath,
                           HashMap<String, String> attachHeadInfo,
                           int timeoutMillis,
                           IHttpCallback callback) throws Exception;

    /**
     * 下载一个文件。支持断点续传。
     *
     * @param destinationPath 下载的文件最终保存的目录
     * @param tempPath        下载的文件临时保存的文件路径，包含文件名的完整路径。（断点续传时使用）
     * @param timeoutMillis  请求超时时间（毫秒）
     * @param progressState   进度状态
     */
    public void downloadFile(String urlString,
                             int tag,
                             String destinationPath,
                             String tempPath,
                             int timeoutMillis,
                             IProgressCallback progressState) throws Exception;


    /**
     * 下载一个文件。默认为异步请求，支持断点续传。
     * 注：参数tempFile临时文件名称可以随便起，下载完成后文件会使用原始文件名的
     *
     * @param destinationPath 下载的文件最终保存的目录，仅目录
     * @param tempPath        下载的文件临时保存的文件路径，包含文件名的完整路径。（断点续传时使用）
     * @param attachHeadInfo  附加的头信息
     * @param timeoutMillis  请求超时时间（毫秒）
     * @param progressState   进度状态。完成时会传回下载文件的完整路径。
     */
    public void downloadFile(String urlString,
                             int tag,
                             String destinationPath,
                             String tempPath,
                             HashMap<String, String> attachHeadInfo,
                             int timeoutMillis,
                             IProgressCallback progressState) throws Exception;

    ////////////////////////////////////////////////////////////////
    // FormData post相关函数
    ////////////////////////////////////////////////////////////////

    /**
     * 基于FormData的HTTP Post请求方法。
     *
     * @param fields         表单上需要提交的字段。key是服务端确定的字段名，value是客户端输入的值
     * @param files          文件列表。注：Map中的key即为Web表单中input标签的name
     * @param attachHeadInfo 附加的头信息
     * @param timeoutMillis 请求超时时间（毫秒）
     * @param callback       请求成功或失败后的回调
     */
    public void postFormData(String urlString,
                             int tag,
                             Map<String, String> fields,
                             Map<String, File> files,
                             HashMap<String, String> attachHeadInfo,
                             int timeoutMillis,
                             IHttpCallback callback) throws Exception;
}
