package com.arwer.arlibrary.net.urlconnection;

import com.arwer.arlibrary.net.common.HttpUtils;
import com.arwer.arlibrary.net.common.IHttpCallback;
import com.arwer.arlibrary.net.common.IHttpRequest;
import com.arwer.arlibrary.net.common.IProgressCallback;
import com.arwer.arlibrary.threads.TaskQueue;
import com.arwer.arlibrary.utils.IOUtils;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.RandomAccessFile;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLDecoder;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.Callable;


/**
 * @file HttpRequest.java
 * @brief 实现基于HttpURLConnection的适配器
 * @details https://github.com/longjun3000/ARHttpRequest
 * @version v1.0
 * @author 创建人：LongJun
 * @date 创建日期：2016-02-20
 * @copyright Copyright (c) 2016 ArwerSoftware All rights reserved.
 *
 * @date 修改日期，例：xxxx年x月xx日
 * @details 修改历史记录：详细说明修改的内容。
 * @author 修改人的名字及单位
 *
 */
public class HttpRequest implements IHttpRequest {

    ////////////////////////////////////////////////////////////////
    // 常量、变量定义
    ////////////////////////////////////////////////////////////////

    //    /** 标签，标记 */
//    public int tag;
    //
//    private String mUrlString = null;
    //
//    private HttpURLConnection mConnection = null;
    // 是否取消请求
    private boolean mIsCancel = false;
    //
    private boolean mIsUseDefaultQueue = false;
    //
    private TaskQueue mDefaultQueue;
    public TaskQueue getDefaultQueue() {
        if (mDefaultQueue == null) {
            mDefaultQueue = new TaskQueue();
            mDefaultQueue.setMaxConcurrentThreadCount(4);
        }
        return mDefaultQueue;
    }

    ////////////////////////////////////////////////////////////////
    // 生命周期相关函数
    ////////////////////////////////////////////////////////////////

//    private HttpRequest() {};

//    public HttpRequest(String urlString) throws Exception {
//        if (urlString == null || urlString.length() < 1) {
//            throw new Exception("param \"urlString\"不能为空");
//        }
//        this.mUrlString = urlString;
//    }


    ////////////////////////////////////////////////////////////////
    // 队列相关函数
    ////////////////////////////////////////////////////////////////



    @Override
    public void setQueueIsOn(boolean isOn) {
        mIsUseDefaultQueue = isOn;
        if (!isOn) {
            if (mDefaultQueue != null) mDefaultQueue.cancelAll();
        }
    }

    @Override
    public void setQueueFinishedCallback(TaskQueue.IQueueFinishedCallback finishBlock) {
        if (finishBlock == null) return;

        getDefaultQueue().setQueueFinishedCallback(finishBlock);
    }

    @Override
    public void setMaxConcurrentThreadCount(int maxConcurrentRequestCount) {
        getDefaultQueue().setMaxConcurrentThreadCount(maxConcurrentRequestCount);
    }

    @Override
    public void queueStart() {
        getDefaultQueue().start();
    }

    @Override
    public void queueStop() {
        getDefaultQueue().stop();
    }


    ////////////////////////////////////////////////////////////////
    // HttpURLConnection对象
    ////////////////////////////////////////////////////////////////

//    /**
//     * 得到或创建一个HttpURLConnection对象
//     *
//     * @return 返回一个HttpURLConnection实例对象
//     */
//    public HttpURLConnection getConnection() throws IOException {
//        if (mConnection == null) {
////            String urlStr = new String(mUrlString.getBytes(), "UTF-8");
////            urlStr = URLEncoder.encode(urlStr, "UTF-8");
////            mConnection = (HttpURLConnection) (new URL(urlStr)).openConnection();
//            mConnection = (HttpURLConnection) (new URL(mUrlString)).openConnection();
//        }
//        return mConnection;
//    }
//
//    /**
//     * 手动断开网络连接
//     *
//     */
//    public void disconnect() {
//        mIsCancel = true;
//        if (mConnection != null) mConnection.disconnect();
//    }


    ////////////////////////////////////////////////////////////////
    // Get相关函数
    ////////////////////////////////////////////////////////////////

    /**
     * HTTP Get 请求方法。默认为异步请求。
     *
     * @param callback  请求成功或失败后的回调
     */
    public void get(String urlString, int tag, IHttpCallback callback) throws Exception {
        get(urlString, tag, IHttpRequest.REQUEST_DEFAULT_TIMEOUT, callback);
    }


    /**
     * HTTP Get 请求方法。默认为异步请求。
     *
     * @param timeoutMillis 请求超时时间（毫秒）
     * @param callback       请求成功或失败后的回调
     */
    public void get(String urlString,
                    int tag,
                    int timeoutMillis,
                    IHttpCallback callback) throws Exception {
        get(urlString, tag, null, IHttpRequest.REQUEST_DEFAULT_TIMEOUT, callback);
    }

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
                    IHttpCallback callback) throws Exception {
        get(urlString, tag, params, null, timeoutMillis, callback);
    }

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
                    IHttpCallback callback) throws Exception {

        if (mIsUseDefaultQueue) {
            getDefaultQueue().add(String.valueOf(tag), new GetCallable(urlString, tag, params, attachHeadInfo, timeoutMillis, callback));
        }
        else {
            new GetCallable(urlString, tag, params, attachHeadInfo, timeoutMillis, callback).call();
        }
    }

    private class GetCallable implements Callable<String> {

        private String mUrlString;
        private int tag;
        private HashMap<String, String> mParams;
        private HashMap<String, String> mAttachHeadInfo;
        private int mTimeoutMillis;
        private IHttpCallback mCallback;

        public GetCallable(String urlString,
                           int tag,
                           HashMap<String, String> params,
                           HashMap<String, String> attachHeadInfo,
                           int timeoutMillis,
                           IHttpCallback callback) {
            this.mUrlString = urlString;
            this.tag = tag;
            this.mParams = params;
            this.mAttachHeadInfo = attachHeadInfo;
            this.mTimeoutMillis = timeoutMillis;
            this.mCallback = callback;
        }

        @Override
        public String call() throws Exception {
            // 1 条件检查
            if (mUrlString == null) throw new Exception("请求URL不能为空");
            if (mCallback == null) throw new Exception("参数callback不能为空");

            // 2 实例化
            HttpURLConnection connection = null;
            try {
                // 1 拼成完整的带参数的url
                String fullUrl = HttpUtils.createGetUrlByDictParam(mUrlString, mParams);

                // 2 创建HttpURLConnection对象
                URL url = new URL(fullUrl);
                connection = (HttpURLConnection) url.openConnection();
//            connection = getConnection();

                // 添加附加头信息
                if (mAttachHeadInfo != null && mAttachHeadInfo.size() > 0) {
                    for (Map.Entry<String, String> entry : mAttachHeadInfo.entrySet()) {
                        connection.setRequestProperty(entry.getKey(), entry.getValue());
                    }
                }

                connection.setRequestMethod("GET");
                connection.setReadTimeout(mTimeoutMillis); //设置从主机读取数据超时（单位：毫秒）
                connection.setConnectTimeout(mTimeoutMillis); //设置连接主机超时（单位：毫秒）

                // 发送请求
                connection.connect(); //和远程资源建立真正的连接，但尚无返回的数据流

                // 得到响应
//            if (connection.getResponseCode() == 200) {
                InputStream is = connection.getInputStream();
                ByteArrayOutputStream os = new ByteArrayOutputStream();
                int len = 0;
                byte buffer[] = new byte[1024];
                while ((len = is.read(buffer)) != -1) {
                    os.write(buffer, 0, len);
                }
                is.close();
                os.close();

                String resultStr = new String(os.toByteArray());
//                System.out.print(resultStr);
                mCallback.onFinished(resultStr);

                return resultStr;
//            }
//            else {
//                System.out.print(">>> 请求失败:" + connection.getResponseMessage());
//                callback.onFailure(connection.getResponseMessage());
//            }
            }
            catch (Exception e) {
                System.out.print(e.getMessage());
                e.printStackTrace();
                if (mCallback != null) {
                    mCallback.onFailure(e.getMessage());
                }
                else {
                    throw new Exception("回调函数未定义");
                }
            }
            finally {
                connection.disconnect();
            }
            return null;
        }
    }

//    /**
//     * HTTP Get 请求方法。默认为异步请求。
//     *
//     * @param params         URL参数字典
//     * @param timeoutMillis 请求超时时间（毫秒）
//     * @param callback       请求成功或失败后的回调
//     */
//    private void get(String urlString,
//                    HashMap<String, String> params,
//                    HashMap<String, String> attachHeadInfo,
//                    int timeoutMillis,
//                    IHttpCallback callback) throws Exception {
//        // 1 条件检查
//        if (urlString == null) throw new Exception("请求URL不能为空");
//        if (callback == null) throw new Exception("参数callback不能为空");
//
//        // 2 实例化
//        HttpURLConnection connection = null;
//        try {
//            // 1 拼成完整的带参数的url
//            String fullUrl = HttpUtils.createGetUrlByDictParam(urlString, params);
//
//            // 2 创建HttpURLConnection对象
//            URL url = new URL(fullUrl);
//            connection = (HttpURLConnection) url.openConnection();
////            connection = getConnection();
//
//            // 添加附加头信息
//            if (attachHeadInfo != null && attachHeadInfo.size() > 0) {
//                for (Map.Entry<String, String> entry : attachHeadInfo.entrySet()) {
//                    connection.setRequestProperty(entry.getKey(), entry.getValue());
//                }
//            }
//
//            connection.setRequestMethod("GET");
//            connection.setReadTimeout(timeoutMillis); //设置从主机读取数据超时（单位：毫秒）
//            connection.setConnectTimeout(timeoutMillis); //设置连接主机超时（单位：毫秒）
//
//            // 发送请求
//            connection.connect(); //和远程资源建立真正的连接，但尚无返回的数据流
//
//            // 得到响应
////            if (connection.getResponseCode() == 200) {
//            InputStream is = connection.getInputStream();
//            ByteArrayOutputStream os = new ByteArrayOutputStream();
//            int len = 0;
//            byte buffer[] = new byte[1024];
//            while ((len = is.read(buffer)) != -1) {
//                os.write(buffer, 0, len);
//            }
//            is.close();
//            os.close();
//
//            String resultStr = new String(os.toByteArray());
//            System.out.print(resultStr);
//            callback.onFinished(resultStr);
////            }
////            else {
////                System.out.print(">>> 请求失败:" + connection.getResponseMessage());
////                callback.onFailure(connection.getResponseMessage());
////            }
//        }
//        catch (Exception e) {
//            System.out.print(e.getMessage());
//            e.printStackTrace();
//            if (callback != null) {
//                callback.onFailure(e.getMessage());
//            }
//            else {
//                throw new Exception("回调函数未定义");
//            }
//        }
//        finally {
//            connection.disconnect();
//        }
//    }

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
                         IHttpCallback callback) throws Exception {
        postJson(urlString, tag, jsonString, null, IHttpRequest.REQUEST_DEFAULT_TIMEOUT, callback);
    }


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
                         IHttpCallback callback) throws Exception {
        if (jsonString == null || jsonString.length() < 1) {
//            callback.onFailure("请求JSON字符串不能为空");
            throw new Exception("请求JSON字符串不能为空");
        }
        byte[] postData = jsonString.getBytes("utf-8");
        String contentType = "application/json";
        post(urlString, tag, postData, contentType, attachHeadInfo, timeoutMillis, callback);
    }


    /**
     * HTTP Post 常规 XML 请求方法。默认为异步请求。
     * <p/>
     * 注：请在子类实现覆盖方法requestFinished、requestFailed、queueFinished（如果用了队列），
     * 以实现请求响应后的回调处理。
     *
     * @param xmlString 需要post的XML字符串
     * @param callback  请求成功或失败后的回调
     */
    public void postXml(String urlString,
                        int tag,
                        String xmlString,
                        IHttpCallback callback) throws Exception {
        postXml(urlString, tag, xmlString, null, IHttpRequest.REQUEST_DEFAULT_TIMEOUT, callback);
    }

    /**
     * HTTP Post 常规 XML 请求方法。默认为异步请求。
     * <p/>
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
                        IHttpCallback callback) throws Exception {
        if (xmlString == null || xmlString.length() < 1) {
//            callback.onFailure("请求JSON字符串不能为空");
            throw new Exception("请求XML字符串不能为空");
        }
        byte[] postData = xmlString.getBytes("utf-8");
        String contentType = "application/xml;charset=utf-8";
        post(urlString, tag, postData, contentType, attachHeadInfo, timeoutMillis, callback);
    }

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
                            IHttpCallback callback) throws Exception {
        // SOAPAction
        if (attachHeadInfo == null) attachHeadInfo = new HashMap<String, String>();
        attachHeadInfo.put("SOAPAction", soapAction);
        //
        String contentType = "text/xml; charset=utf-8";
        //
        post(urlString, tag, postData, contentType, attachHeadInfo, timeoutMillis, callback);
    }

    public void post(String urlString,
                     int tag,
                     HashMap<String, String> params,
                     String contenType,
                     HashMap<String, String> attachHeadInfo,
                     int timeoutMillis,
                     IHttpCallback callback) throws Exception {
        // 将参数转变为url参数格式，再转换为byte[]
        StringBuffer paramStr = new StringBuffer();
        for (Map.Entry entry : params.entrySet()) {
            if (paramStr.length() > 0) paramStr.append("&");
            paramStr.append(entry.getKey()).append("=").append(entry.getValue());
        }
        byte[] postData = paramStr.toString().getBytes("utf-8");
        //
        post(urlString, tag, postData, contenType, attachHeadInfo, timeoutMillis, callback);
    }

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
                     IHttpCallback callback) throws Exception {

        if (mIsUseDefaultQueue) {
            getDefaultQueue().add(String.valueOf(tag), new PostCallable(urlString, tag, postData, contenType, attachHeadInfo, timeoutMillis, callback));
        }
        else {
            new PostCallable(urlString, tag, postData, contenType, attachHeadInfo, timeoutMillis, callback).call();
        }
    }

    private class PostCallable implements Callable<String> {

        String urlString;
        int tag;
        byte[] postData;
        String contenType;
        HashMap<String, String> attachHeadInfo;
        int timeoutMillis;
        IHttpCallback callback;

        public PostCallable(String urlString,
                            int tag,
                            byte[] postData,
                            String contenType,
                            HashMap<String, String> attachHeadInfo,
                            int timeoutMillis,
                            IHttpCallback callback) {
            this.urlString = urlString;
            this.tag = tag;
            this.postData = postData;
            this.contenType = contenType;
            this.attachHeadInfo = attachHeadInfo;
            this.timeoutMillis = timeoutMillis;
            this.callback = callback;
        }

        @Override
        public String call() throws Exception {
            HttpURLConnection connection = null;
            try {
                // 1 条件检查
                if (urlString == null) throw new Exception("请求URL不能为空");
                if (callback == null) throw new Exception("参数callback不能为空");


                // 2 创建HttpURLConnection对象
//                URL url = new URL(URLEncoder.encode(urlString, "UTF-8"));
                URL url = new URL(urlString);
                connection = (HttpURLConnection) url.openConnection();
//            connection = getConnection();

                // 添加附加头信息
                if (attachHeadInfo != null && attachHeadInfo.size() > 0) {
                    for (Map.Entry<String, String> entry : attachHeadInfo.entrySet()) {
                        connection.setRequestProperty(entry.getKey(), entry.getValue());
                    }
                }

                connection.setRequestMethod("POST");
//            connection.setRequestProperty("Content-Length", "" + Integer.toString(postData.length));
//            connection.setRequestProperty("Connection", "keep-alive");
//            connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
                if (contenType == null || contenType.length() < 1) throw new Exception("Content-Type参数不能为空");
                connection.setRequestProperty("Content-Type", contenType);

                connection.setReadTimeout(timeoutMillis); //设置从主机读取数据超时（单位：毫秒）
                connection.setConnectTimeout(timeoutMillis); //设置连接主机超时（单位：毫秒）

                // 设置是否向httpUrlConnection输出，因为这个是post请求，参数要放在
                // http正文内，因此需要设为true, 默认情况下是false;
                connection.setDoOutput(true); // 发送POST请求必须设置允许输出
                // 设置是否从httpUrlConnection读入，默认情况下是true;
                connection.setDoInput(true); // 发送POST请求必须设置允许输入 //setDoInput的默认值就是true
                // Post 请求不能使用缓存
                connection.setUseCaches(false);
                //
                connection.connect(); //和远程资源建立真正的连接，但尚无返回的数据流
                // 此处getOutputStream会隐含的进行connect (即：如同调用上面的connect()方法，
                // 所以在开发中不调用上述的connect()也可以)。
                // 现在通过输出流对象构建对象输出流对象，以实现输出可序列化的对象。
                DataOutputStream out = new DataOutputStream(connection.getOutputStream());
                // 向数据输出流写出数据，这些数据将存到内存缓冲区中
                out.write(postData);
//            out.writeBytes(new String(postData,"utf-8"));
                // 刷新对象输出流，将任何字节都写入潜在的流中
                out.flush();
                // 关闭流对象。此时，不能再向对象输出流写入任何数据，先前写入的数据存在于内存缓冲区中,
                // 再调用下边的getInputStream()函数时才把准备好的http请求正式发送到服务器
                out.close();

                // 得到响应
//            if (connection.getResponseCode() == 200) {
                // 获取响应的输入流对象
                // 将内存缓冲区中封装好的完整的HTTP请求电文发送到服务端。
                InputStream is = connection.getInputStream(); // <===注意，实际发送请求的代码段就在这里
                // 创建字节输出流对象
                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                // 定义读取的长度
                int len = 0;
                // 定义缓冲区
                byte buffer[] = new byte[1024];
                // 按照缓冲区的大小，循环读取
                while ((len = is.read(buffer)) != -1) {
                    // 根据读取的长度写入到os对象中
                    baos.write(buffer, 0, len);
                }
                // 释放资源
                is.close();
                baos.close();
                // 返回字符串
                final String resultStr = new String(baos.toByteArray());
                //
                callback.onFinished(resultStr);
                //
                return resultStr;
//            } else {
//                System.out.print(">>> 请求失败:" + connection.getResponseMessage());
//                callback.onFailure(connection.getResponseMessage());
//            }

            }
            catch (Exception e) {
                e.printStackTrace();
                callback.onFailure(e.getMessage());
            }
            finally {
                connection.disconnect();
            }
            return null;
        }
    }

//    /**
//     * HTTP Post请求方法。默认为异步请求。
//     *
//     * 注：请在子类实现覆盖方法requestFinished、requestFailed、queueFinished（如果用了队列），
//     * 以实现请求响应后的回调处理。
//     *
//     * @param postData       需要post的数据
//     * @param contenType     Content-Type
//     * @param attachHeadInfo 附加的头信息
//     * @param timeoutMillis 请求超时时间（毫秒）
//     * @param callback       请求成功或失败后的回调
//     */
//    public void post(String urlString,
//                     int tag,
//                     byte[] postData,
//                     String contenType,
//                     HashMap<String, String> attachHeadInfo,
//                     int timeoutMillis,
//                     IHttpCallback callback) throws MalformedURLException {
//        HttpURLConnection connection = null;
//        try {
//            // 1 条件检查
//            if (urlString == null) throw new Exception("请求URL不能为空");
//            if (callback == null) throw new Exception("参数callback不能为空");
//
//
//            // 2 创建HttpURLConnection对象
//            URL url = new URL(URLEncoder.encode(urlString, "UTF-8"));
//            connection = (HttpURLConnection) url.openConnection();
////            connection = getConnection();
//
//            // 添加附加头信息
//            if (attachHeadInfo != null && attachHeadInfo.size() > 0) {
//                for (Map.Entry<String, String> entry : attachHeadInfo.entrySet()) {
//                    connection.setRequestProperty(entry.getKey(), entry.getValue());
//                }
//            }
//
//            connection.setRequestMethod("POST");
////            connection.setRequestProperty("Content-Length", "" + Integer.toString(postData.length));
////            connection.setRequestProperty("Connection", "keep-alive");
////            connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
//            if (contenType == null || contenType.length() < 1) throw new Exception("Content-Type参数不能为空");
//            connection.setRequestProperty("Content-Type", contenType);
//
//            connection.setReadTimeout(timeoutMillis); //设置从主机读取数据超时（单位：毫秒）
//            connection.setConnectTimeout(timeoutMillis); //设置连接主机超时（单位：毫秒）
//
//            // 设置是否向httpUrlConnection输出，因为这个是post请求，参数要放在
//            // http正文内，因此需要设为true, 默认情况下是false;
//            connection.setDoOutput(true); // 发送POST请求必须设置允许输出
//            // 设置是否从httpUrlConnection读入，默认情况下是true;
//            connection.setDoInput(true); // 发送POST请求必须设置允许输入 //setDoInput的默认值就是true
//            // Post 请求不能使用缓存
//            connection.setUseCaches(false);
//            //
//            connection.connect(); //和远程资源建立真正的连接，但尚无返回的数据流
//            // 此处getOutputStream会隐含的进行connect (即：如同调用上面的connect()方法，
//            // 所以在开发中不调用上述的connect()也可以)。
//            // 现在通过输出流对象构建对象输出流对象，以实现输出可序列化的对象。
//            DataOutputStream out = new DataOutputStream(connection.getOutputStream());
//            // 向数据输出流写出数据，这些数据将存到内存缓冲区中
//            out.write(postData);
////            out.writeBytes(new String(postData,"utf-8"));
//            // 刷新对象输出流，将任何字节都写入潜在的流中
//            out.flush();
//            // 关闭流对象。此时，不能再向对象输出流写入任何数据，先前写入的数据存在于内存缓冲区中,
//            // 再调用下边的getInputStream()函数时才把准备好的http请求正式发送到服务器
//            out.close();
//
//            // 得到响应
////            if (connection.getResponseCode() == 200) {
//            // 获取响应的输入流对象
//            // 将内存缓冲区中封装好的完整的HTTP请求电文发送到服务端。
//            InputStream is = connection.getInputStream(); // <===注意，实际发送请求的代码段就在这里
//            // 创建字节输出流对象
//            ByteArrayOutputStream baos = new ByteArrayOutputStream();
//            // 定义读取的长度
//            int len = 0;
//            // 定义缓冲区
//            byte buffer[] = new byte[1024];
//            // 按照缓冲区的大小，循环读取
//            while ((len = is.read(buffer)) != -1) {
//                // 根据读取的长度写入到os对象中
//                baos.write(buffer, 0, len);
//            }
//            // 释放资源
//            is.close();
//            baos.close();
//            // 返回字符串
//            final String resultStr = new String(baos.toByteArray());
//
//            callback.onFinished(resultStr);
////            } else {
////                System.out.print(">>> 请求失败:" + connection.getResponseMessage());
////                callback.onFailure(connection.getResponseMessage());
////            }
//
//        }
//        catch (Exception e) {
//            e.printStackTrace();
//            callback.onFailure(e.getMessage());
//        }
//        finally {
//            connection.disconnect();
//        }
//    }

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
                           IHttpCallback callback) throws Exception {
//        throw new Exception("方法未实现");
        File file = new File(fullFilePath);

        uploadFile(urlString, tag, "file", fullFilePath, attachHeadInfo, timeoutMillis, callback);
    }

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
                           IHttpCallback callback) throws Exception {
//        throw new Exception("方法未实现");
        Map<String, File> files = new HashMap<>();
        files.put(fileKeyName, new File(fullFilePath));

        postFormData(urlString, tag, null, files, attachHeadInfo, timeoutMillis, callback);
    }

//    /**
//     * 上传一个文件。默认为异步请求。
//     *
//     * 注：请在子类实现覆盖方法requestFinished、requestFailed、queueFinished（如果用了队列），
//     * 以实现请求响应后的回调处理。
//     *
//     * @param fileData       文件数据
//     * @param attachHeadInfo 附加的头信息
//     * @param timeoutMillis 请求超时时间（毫秒）
//     * @param progressCallback  进度状态
//     */
//    public void uploadFile(byte[] fileData,
//                           HashMap<String, String> attachHeadInfo,
//                           int timeoutMillis,
//                           IProgressCallback progressCallback) throws Exception {
//        throw new Exception("方法未实现");
//    }

    /**
     * 下载一个文件。支持断点续传。
     *
     * @param destinationPath 下载的文件最终保存的目录
     * @param tempPath        下载的文件临时保存的文件路径，包含文件名的完整路径。（断点续传时使用）
     * @param timeoutMillis  请求超时时间（毫秒）
     * @param progressCallback   进度状态
     */
    public void downloadFile(String urlString,
                             int tag,
                             String destinationPath,
                             String tempPath,
                             int timeoutMillis,
                             IProgressCallback progressCallback) throws Exception {
        downloadFile(urlString, tag, destinationPath, tempPath, null, timeoutMillis, progressCallback);
    }

    /**
     * 下载一个文件。默认为异步请求，支持断点续传。
     * 注：参数tempFile临时文件名称可以随便起，下载完成后文件会使用原始文件名的
     *
     * @param destinationPath 下载的文件最终保存的目录，仅目录
     * @param tempPath        下载的文件临时保存的文件路径，包含文件名的完整路径。（断点续传时使用）
     * @param attachHeadInfo  附加的头信息
     * @param timeoutMillis  请求超时时间（毫秒）
     * @param progressCallback   进度状态。完成时会传回下载文件的完整路径。
     */
    public void downloadFile(String urlString,
                             int tag,
                             String destinationPath,
                             String tempPath,
                             HashMap<String, String> attachHeadInfo,
                             int timeoutMillis,
                             IProgressCallback progressCallback) throws Exception {

        if (mIsUseDefaultQueue) {
            getDefaultQueue().add(String.valueOf(tag), new DownloadCallable(urlString, tag, destinationPath, tempPath, attachHeadInfo, timeoutMillis, progressCallback));
        }
        else {
            new DownloadCallable(urlString, tag, destinationPath, tempPath, attachHeadInfo, timeoutMillis, progressCallback).call();
        }
    }

    private class DownloadCallable implements Callable<String> {

        String urlString;
        int tag;
        String destinationPath;
        String tempPath;
        HashMap<String, String> attachHeadInfo;
        int timeoutMillis;
        IProgressCallback progressCallback;

        public DownloadCallable(String urlString,
                                int tag,
                                String destinationPath,
                                String tempPath,
                                HashMap<String, String> attachHeadInfo,
                                int timeoutMillis,
                                IProgressCallback progressCallback) {
            this.urlString = urlString;
            this.tag = tag;
            this.destinationPath = destinationPath;
            this.tempPath = tempPath;
            this.attachHeadInfo = attachHeadInfo;
            this.timeoutMillis = timeoutMillis;
            this.progressCallback = progressCallback;
        }

        @Override
        public String call() throws Exception {
            // 1 条件检查
            if (urlString == null) throw new Exception("请求URL不能为空");
            if (destinationPath == null || destinationPath.length() < 1) throw new Exception("参数destinationPath不能为空");
            if (tempPath == null || tempPath.length() < 1) throw new Exception("参数tempPath不能为空");
            if (progressCallback == null) throw new Exception("参数progressCallback不能为空");

            HttpURLConnection connection = null;
            try {
                long downSize = 0;

                // 2 检查临时文件，看是否有未完成的下载，并获得已下载的大小
                File tmpFile = new File(tempPath);
                if (tmpFile.exists()) {
                    downSize = tmpFile.length();
                }

                // 3 创建HttpURLConnection对象
                URL url = new URL(HttpUtils.encodeUrlLastComponent(urlString));
                connection = (HttpURLConnection) url.openConnection();

                // 添加附加头信息
                if (attachHeadInfo != null && attachHeadInfo.size() > 0) {
                    for (Map.Entry<String, String> entry : attachHeadInfo.entrySet()) {
                        connection.setRequestProperty(entry.getKey(), entry.getValue());
                    }
                }

                connection.setRequestMethod("GET");
                connection.setReadTimeout(timeoutMillis); //设置从主机读取数据超时（单位：毫秒）
                connection.setConnectTimeout(timeoutMillis); //设置连接主机超时（单位：毫秒）

                // 设置下载区间
                connection.setRequestProperty("RANGE", "bytes=" + downSize + "-");

                //
                connection.connect(); //和远程资源建立真正的连接，但尚无返回的数据流

                // 4 得到响应
                int respCode = connection.getResponseCode();
                // 只要断点下载，返回的已经不是200，而是206
                if (respCode == 206) {

                    // 获取响应的输入流对象
                    InputStream is = connection.getInputStream();
                    // 从头信息里得到文件总大小
//                long totalSize = connection.getContentLength();
                    String totalSizeStr = getFileSizeFromHead(connection);
                    long totalSize = Long.parseLong(totalSizeStr);
                    // 回调函数，进度开始，最大值100
                    progressCallback.onBegin(100);
                    // 创建输出流对象
                    RandomAccessFile out = new RandomAccessFile(tempPath,"rw");
                    out.seek(downSize); // 跳到上次最后的位置

                    byte[] buffer = new byte[1024]; // 定义缓冲区
                    int len = -1; // 定义读取的长度
                    int lastVal = -1;
                    // 按照缓冲区的大小，循环读取
                    while ((len = is.read(buffer)) != -1) {
                        // 根据读取的长度写入到os对象中
                        out.write(buffer, 0, len);
                        downSize += len;
                        int currVal = (int)(downSize * 100 / totalSize);
//                    if (currVal >= 40) return; /////////////////////////////////DEBUG
                        if (mIsCancel) return null; //如果取消请求，则停止写文件
                        if (currVal != lastVal) {
                            lastVal = currVal;
                            progressCallback.onProgress(currVal);
                        }
                    }
                    out.close(); // 释放资源
                    is.close(); // 释放资源

                    // 获得下载文件原始文件名，
                    String originalFileName = IOUtils.getFileName(connection.getURL().getFile());
                    // 包含原始文件名的本地下载文件的最终路径
                    String destFile = IOUtils.addFilePathComponent(destinationPath, URLDecoder.decode(originalFileName,"UTF-8"));
                    // 移动临时文件到目的文件
                    if (IOUtils.rename(tempPath, destFile) ) {
                        // 完成下载，返回参数为目标文件路径
                        progressCallback.onFinished(destFile);
                        //
                        return destFile;
                    }
                    else {
                        progressCallback.onFailure("文件下载成功，重命名时失败");
                        //
                        return null;
                    }
                }
                else if (respCode == 416) { //所请求的范围无法满足 (Requested Range not satisfiable)
//                String contentRange = connection.getHeaderField("Content-Range");
//                String crStrArray[] = contentRange.split("/");
//                if (crStrArray != null && crStrArray.length >= 2) {
//                    String sizeStr = crStrArray[1].trim();
                    String sizeStr = getFileSizeFromHead(connection);
                    if (sizeStr.equals(String.valueOf(downSize)) ) { //临时文件和服务器文件一样大
                        // 获得下载文件原始文件名，
                        String originalFileName = IOUtils.getFileName(connection.getURL().getFile());
                        // 包含原始文件名的本地下载文件的最终路径
                        String destFile = IOUtils.addFilePathComponent(destinationPath, originalFileName);
                        // 移动临时文件到目的文件
                        if (IOUtils.rename(tempPath, destFile) ) {
                            // 完成下载，返回参数为目标文件路径
                            progressCallback.onFinished(destFile);
                            //
                            return destFile;
                        }
                        else {
                            progressCallback.onFailure("文件下载成功，重命名时失败");
                            //
                            return null;
                        }
                    }
//                }

                    System.out.print(">>> 下载失败:" + connection.getResponseMessage());
                    progressCallback.onFailure(connection.getResponseMessage());
                }
                else {
                    System.out.print(">>> 下载失败:" + connection.getResponseMessage());
                    progressCallback.onFailure(connection.getResponseMessage());
                }

            }
            catch (Exception e) {
                e.printStackTrace();
                progressCallback.onFailure(e.getMessage());
            }
            finally {
                connection.disconnect();
            }
            return null;
        }
    }

//    /**
//     * 下载一个文件。默认为异步请求，支持断点续传。
//     * 注：参数tempFile临时文件名称可以随便起，下载完成后文件会使用原始文件名的
//     *
//     * @param destinationPath 下载的文件最终保存的目录，仅目录
//     * @param tempPath        下载的文件临时保存的文件路径，包含文件名的完整路径。（断点续传时使用）
//     * @param attachHeadInfo  附加的头信息
//     * @param timeoutMillis  请求超时时间（毫秒）
//     * @param progressCallback   进度状态。完成时会传回下载文件的完整路径。
//     */
//    public void downloadFile(String urlString,
//                             int tag,
//                             String destinationPath,
//                             String tempPath,
//                             HashMap<String, String> attachHeadInfo,
//                             int timeoutMillis,
//                             IProgressCallback progressCallback) throws Exception {
//        // 1 条件检查
//        if (urlString == null) throw new Exception("请求URL不能为空");
//        if (destinationPath == null || destinationPath.length() < 1) throw new Exception("参数destinationPath不能为空");
//        if (tempPath == null || tempPath.length() < 1) throw new Exception("参数tempPath不能为空");
//        if (progressCallback == null) throw new Exception("参数progressCallback不能为空");
//
//        HttpURLConnection connection = null;
//        try {
//            long downSize = 0;
//
//            // 2 检查临时文件，看是否有未完成的下载，并获得已下载的大小
//            File tmpFile = new File(tempPath);
//            if (tmpFile.exists()) {
//                downSize = tmpFile.length();
//            }
//
//            // 3 创建HttpURLConnection对象
//            URL url = new URL(urlString);
//            connection = (HttpURLConnection) url.openConnection();
////            connection = getConnection();
//
//            // 添加附加头信息
//            if (attachHeadInfo != null && attachHeadInfo.size() > 0) {
//                for (Map.Entry<String, String> entry : attachHeadInfo.entrySet()) {
//                    connection.setRequestProperty(entry.getKey(), entry.getValue());
//                }
//            }
//
//            connection.setRequestMethod("GET");
//            connection.setReadTimeout(timeoutMillis); //设置从主机读取数据超时（单位：毫秒）
//            connection.setConnectTimeout(timeoutMillis); //设置连接主机超时（单位：毫秒）
//
//            // 设置下载区间
//            connection.setRequestProperty("RANGE", "bytes=" + downSize + "-");
//
//            //
//            connection.connect(); //和远程资源建立真正的连接，但尚无返回的数据流
//
//            // 4 得到响应
//            int respCode = connection.getResponseCode();
//            // 只要断点下载，返回的已经不是200，而是206
//            if (respCode == 206) {
//
//                // 获取响应的输入流对象
//                InputStream is = connection.getInputStream();
//                // 从头信息里得到文件总大小
////                long totalSize = connection.getContentLength();
//                String totalSizeStr = getFileSizeFromHead(connection);
//                long totalSize = Long.parseLong(totalSizeStr);
//                // 回调函数，进度开始，最大值100
//                progressCallback.onBegin(100);
//                // 创建输出流对象
//                RandomAccessFile out = new RandomAccessFile(tempPath,"rw");
//                out.seek(downSize); // 跳到上次最后的位置
//
//                byte[] buffer = new byte[1024]; // 定义缓冲区
//                int len = -1; // 定义读取的长度
//                int lastVal = -1;
//                // 按照缓冲区的大小，循环读取
//                while ((len = is.read(buffer)) != -1) {
//                    // 根据读取的长度写入到os对象中
//                    out.write(buffer, 0, len);
//                    downSize += len;
//                    int currVal = (int)(downSize * 100 / totalSize);
////                    if (currVal >= 40) return; /////////////////////////////////DEBUG
//                    if (mIsCancel) return; //如果取消请求，则停止写文件
//                    if (currVal != lastVal) {
//                        lastVal = currVal;
//                        progressCallback.onProgress(currVal);
//                    }
//                }
//                out.close(); // 释放资源
//                is.close(); // 释放资源
//
//                // 获得下载文件原始文件名，
//                String originalFileName = IOUtils.getFileName(connection.getURL().getFile());
//                // 包含原始文件名的本地下载文件的最终路径
//                String destFile = IOUtils.addFilePathComponent(destinationPath, URLDecoder.decode(originalFileName,"UTF-8"));
//                // 移动临时文件到目的文件
//                if (IOUtils.rename(tempPath, destFile) ) {
//                    // 完成下载，返回参数为目标文件路径
//                    progressCallback.onFinished(destFile);
//                }
//                else {
//                    progressCallback.onFailure("文件下载成功，重命名时失败");
//                }
//                return;
//            }
//            else if (respCode == 416) { //所请求的范围无法满足 (Requested Range not satisfiable)
////                String contentRange = connection.getHeaderField("Content-Range");
////                String crStrArray[] = contentRange.split("/");
////                if (crStrArray != null && crStrArray.length >= 2) {
////                    String sizeStr = crStrArray[1].trim();
//                String sizeStr = getFileSizeFromHead(connection);
//                if (sizeStr.equals(String.valueOf(downSize)) ) { //临时文件和服务器文件一样大
//                    // 获得下载文件原始文件名，
//                    String originalFileName = IOUtils.getFileName(connection.getURL().getFile());
//                    // 包含原始文件名的本地下载文件的最终路径
//                    String destFile = IOUtils.addFilePathComponent(destinationPath, originalFileName);
//                    // 移动临时文件到目的文件
//                    if (IOUtils.rename(tempPath, destFile) ) {
//                        // 完成下载，返回参数为目标文件路径
//                        progressCallback.onFinished(destFile);
//                    }
//                    else {
//                        progressCallback.onFailure("文件下载成功，重命名时失败");
//                    }
//                    return;
//                }
////                }
//
//                System.out.print(">>> 下载失败:" + connection.getResponseMessage());
//                progressCallback.onFailure(connection.getResponseMessage());
//            }
//            else {
//                System.out.print(">>> 下载失败:" + connection.getResponseMessage());
//                progressCallback.onFailure(connection.getResponseMessage());
//            }
//
//        }
//        catch (Exception e) {
//            e.printStackTrace();
//            progressCallback.onFailure(e.getMessage());
//        }
//        finally {
//            connection.disconnect();
//        }
//    }

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
                             IHttpCallback callback) throws Exception {

        if (mIsUseDefaultQueue) {
            getDefaultQueue().add(String.valueOf(tag), new PostFormDataCallable(urlString, tag, fields, files, attachHeadInfo, timeoutMillis, callback));
        }
        else {
            new PostFormDataCallable(urlString, tag, fields, files, attachHeadInfo, timeoutMillis, callback).call();
        }

    }

    private class PostFormDataCallable implements Callable<String> {

        String urlString;
        int tag;
        Map<String, String> fields;
        Map<String, File> files;
        HashMap<String, String> attachHeadInfo;
        int timeoutMillis;
        IHttpCallback callback;

        public PostFormDataCallable(String urlString,
                                    int tag,
                                    Map<String, String> fields,
                                    Map<String, File> files,
                                    HashMap<String, String> attachHeadInfo,
                                    int timeoutMillis,
                                    IHttpCallback callback) {
            this.urlString = urlString;
            this.tag = tag;
            this.fields = fields;
            this.files = files;
            this.attachHeadInfo = attachHeadInfo;
            this.timeoutMillis = timeoutMillis;
            this.callback = callback;
        }

        @Override
        public String call() throws Exception {
            // 1 条件检查
            if (urlString == null) throw new Exception("请求URL不能为空");
            if (fields == null && files == null) throw new Exception("参数fields和files不能都为空");
            if (callback == null) throw new Exception("参数callback不能为空");

            HttpURLConnection connection = null;
            try {
                String PREFIX = "--", CRLF = "\r\n";
                String BOUNDARY = UUID.randomUUID().toString().replace("-",""); // 边界标识 随机生成
//            String FULL_BOUNDARY = PREFIX + BOUNDARY + CRLF; // 完整分隔符
//            String CONTENT_TYPE_M = "multipart/form-data"; // 内容类型

                // 2 创建和初始化HttpURLConnection对象
                URL url = new URL(urlString);
                connection = (HttpURLConnection)url.openConnection();
//            connection = getConnection();

                // 添加附加头信息
                if (attachHeadInfo != null && attachHeadInfo.size() > 0) {
                    for (Map.Entry<String, String> entry : attachHeadInfo.entrySet()) {
                        connection.setRequestProperty(entry.getKey(), entry.getValue());
                    }
                }

                connection.setRequestMethod("POST");
                connection.setRequestProperty("Charset", "utf-8"); // 设置编码
                connection.setRequestProperty("connection", "keep-alive");
                connection.setRequestProperty("Content-Type", "multipart/form-data;boundary=" + BOUNDARY);

                connection.setReadTimeout(timeoutMillis); //设置从主机读取数据超时（单位：毫秒）
                connection.setConnectTimeout(timeoutMillis); //设置连接主机超时（单位：毫秒）
                connection.setDoOutput(true); // 发送POST请求必须设置允许输出
                connection.setDoInput(true); // 发送POST请求必须设置允许输入 //setDoInput的默认值就是true
                connection.setUseCaches(false);
                //
                connection.connect(); //和远程资源建立真正的连接，但尚无返回的数据流

                // 3 向服务器写入输出流
                DataOutputStream out = new DataOutputStream(connection.getOutputStream());
                // 3.1 向服务器写入输出流：表单字段部分
                if (fields != null && fields.size() > 0) {
                    StringBuilder sb = new StringBuilder();
                    for (Map.Entry entry : fields.entrySet()) {
                        sb.append(PREFIX).append(BOUNDARY).append(CRLF);
                        // 注意：name里面的值为服务器端需要的key
                        sb.append("Content-Disposition: form-data; name=\"" + entry.getKey() + "\"" ).append(CRLF);
                        sb.append(CRLF);
                        sb.append(entry.getValue());
                        sb.append(CRLF);
                    }
                    out.write(sb.toString().getBytes());
                }

                // 3.1 向服务器写入输出流：表单文件部分
                if (files != null && files.size() > 0) {
                    for (Map.Entry entry : files.entrySet()) {
                        File file = (File)entry.getValue();
                        if (file == null) {
                            throw new Exception("name为\""+ entry.getKey()+"\"的文件对象为空");
//                        return;
                        }

                        StringBuilder sb = new StringBuilder();
                        sb.append(PREFIX).append(BOUNDARY).append(CRLF);
                        // 注意：name里面的值为服务器端需要的key
                        sb.append("Content-Disposition: form-data; name=\"" + entry.getKey() + "\"; filename=\""+ file.getName() +"\"" ).append(CRLF);
                        sb.append("Content-Type: application/octet-stream; charset=utf-8").append(CRLF);
//                    sb.append("Content-Type: application/octet-stream").append(CRLF);
                        sb.append(CRLF);
                        out.write(sb.toString().getBytes());

                        InputStream is = new FileInputStream(file);
                        byte[] buffer = new byte[1024]; // 定义缓冲区
                        int len = 0; // 定义读取的长度
                        while ((len = is.read(buffer)) != -1) { // 按照缓冲区的大小，循环读取
                            out.write(buffer, 0, len); // 根据读取的长度写入到os对象中
                        }
                        out.write(CRLF.getBytes());
                        is.close(); // 释放资源
                    }
                }

                // 3.1 向服务器写入输出流：结束部分
                // 注意：最后结尾是两个横杠“--”
                byte[] endData = (PREFIX + BOUNDARY + "--" + CRLF).getBytes();
                out.write(endData);
                out.flush();
                out.close();

                // 4 得到响应
//            if (connection.getResponseCode() == 200) {
                // 获取响应的输入流对象
                InputStream is = connection.getInputStream();
                // 创建字节输出流对象
                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                // 定义读取的长度
                int len = 0;
                // 定义缓冲区
                byte buffer[] = new byte[1024];
                // 按照缓冲区的大小，循环读取
                while ((len = is.read(buffer)) != -1) {
                    // 根据读取的长度写入到os对象中
                    baos.write(buffer, 0, len);
                }
                // 释放资源
                is.close();
                baos.close();
                // 返回字符串
                final String resultStr = new String(baos.toByteArray());
                //
                callback.onFinished(resultStr);
                //
                return resultStr;
//            } else {
//                System.out.print(">>> 请求失败:" + connection.getResponseMessage());
//                callback.onFailure(connection.getResponseMessage());
//            }

            }
            catch (Exception e) {
                e.printStackTrace();
                callback.onFailure(e.getMessage());
            }
            finally {
                connection.disconnect();
            }
            return null;
        }
    }

//    /**
//     * 基于FormData的HTTP Post请求方法。
//     *
//     * @param fields         表单上需要提交的字段。key是服务端确定的字段名，value是客户端输入的值
//     * @param files          文件列表。注：Map中的key即为Web表单中input标签的name
//     * @param attachHeadInfo 附加的头信息
//     * @param timeoutMillis 请求超时时间（毫秒）
//     * @param callback       请求成功或失败后的回调
//     */
//    public void postFormData(String urlString,
//                             int tag,
//                             Map<String, String> fields,
//                             Map<String, File> files,
//                             HashMap<String, String> attachHeadInfo,
//                             int timeoutMillis,
//                             IHttpCallback callback) throws Exception {
//        // 1 条件检查
//        if (urlString == null) throw new Exception("请求URL不能为空");
//        if (fields == null && files == null) throw new Exception("参数fields和files不能都为空");
//        if (callback == null) throw new Exception("参数callback不能为空");
//
//        HttpURLConnection connection = null;
//        try {
//            String PREFIX = "--", CRLF = "\r\n";
//            String BOUNDARY = UUID.randomUUID().toString().replace("-",""); // 边界标识 随机生成
////            String FULL_BOUNDARY = PREFIX + BOUNDARY + CRLF; // 完整分隔符
////            String CONTENT_TYPE_M = "multipart/form-data"; // 内容类型
//
//            // 2 创建和初始化HttpURLConnection对象
//            URL url = new URL(urlString);
//            connection = (HttpURLConnection)url.openConnection();
////            connection = getConnection();
//
//            // 添加附加头信息
//            if (attachHeadInfo != null && attachHeadInfo.size() > 0) {
//                for (Map.Entry<String, String> entry : attachHeadInfo.entrySet()) {
//                    connection.setRequestProperty(entry.getKey(), entry.getValue());
//                }
//            }
//
//            connection.setRequestMethod("POST");
//            connection.setRequestProperty("Charset", "utf-8"); // 设置编码
//            connection.setRequestProperty("connection", "keep-alive");
//            connection.setRequestProperty("Content-Type", "multipart/form-data;boundary=" + BOUNDARY);
//
//            connection.setReadTimeout(timeoutMillis); //设置从主机读取数据超时（单位：毫秒）
//            connection.setConnectTimeout(timeoutMillis); //设置连接主机超时（单位：毫秒）
//            connection.setDoOutput(true); // 发送POST请求必须设置允许输出
//            connection.setDoInput(true); // 发送POST请求必须设置允许输入 //setDoInput的默认值就是true
//            connection.setUseCaches(false);
//            //
//            connection.connect(); //和远程资源建立真正的连接，但尚无返回的数据流
//
//            // 3 向服务器写入输出流
//            DataOutputStream out = new DataOutputStream(connection.getOutputStream());
//            // 3.1 向服务器写入输出流：表单字段部分
//            if (fields != null && fields.size() > 0) {
//                StringBuilder sb = new StringBuilder();
//                for (Map.Entry entry : fields.entrySet()) {
//                    sb.append(PREFIX).append(BOUNDARY).append(CRLF);
//                    // 注意：name里面的值为服务器端需要的key
//                    sb.append("Content-Disposition: form-data; name=\"" + entry.getKey() + "\"" ).append(CRLF);
//                    sb.append(CRLF);
//                    sb.append(entry.getValue());
//                    sb.append(CRLF);
//                }
//                out.write(sb.toString().getBytes());
//            }
//
//            // 3.1 向服务器写入输出流：表单文件部分
//            if (files != null && files.size() > 0) {
//                for (Map.Entry entry : files.entrySet()) {
//                    File file = (File)entry.getValue();
//                    if (file == null) {
//                        throw new Exception("name为\""+ entry.getKey()+"\"的文件对象为空");
////                        return;
//                    }
//
//                    StringBuilder sb = new StringBuilder();
//                    sb.append(PREFIX).append(BOUNDARY).append(CRLF);
//                    // 注意：name里面的值为服务器端需要的key
//                    sb.append("Content-Disposition: form-data; name=\"" + entry.getKey() + "\"; filename=\""+ file.getName() +"\"" ).append(CRLF);
//                    sb.append("Content-Type: application/octet-stream; charset=utf-8").append(CRLF);
////                    sb.append("Content-Type: application/octet-stream").append(CRLF);
//                    sb.append(CRLF);
//                    out.write(sb.toString().getBytes());
//
//                    InputStream is = new FileInputStream(file);
//                    byte[] buffer = new byte[1024]; // 定义缓冲区
//                    int len = 0; // 定义读取的长度
//                    while ((len = is.read(buffer)) != -1) { // 按照缓冲区的大小，循环读取
//                        out.write(buffer, 0, len); // 根据读取的长度写入到os对象中
//                    }
//                    out.write(CRLF.getBytes());
//                    is.close(); // 释放资源
//                }
//            }
//
//            // 3.1 向服务器写入输出流：结束部分
//            // 注意：最后结尾是两个横杠“--”
//            byte[] endData = (PREFIX + BOUNDARY + "--" + CRLF).getBytes();
//            out.write(endData);
//            out.flush();
//            out.close();
//
//            // 4 得到响应
////            if (connection.getResponseCode() == 200) {
//            // 获取响应的输入流对象
//            InputStream is = connection.getInputStream();
//            // 创建字节输出流对象
//            ByteArrayOutputStream baos = new ByteArrayOutputStream();
//            // 定义读取的长度
//            int len = 0;
//            // 定义缓冲区
//            byte buffer[] = new byte[1024];
//            // 按照缓冲区的大小，循环读取
//            while ((len = is.read(buffer)) != -1) {
//                // 根据读取的长度写入到os对象中
//                baos.write(buffer, 0, len);
//            }
//            // 释放资源
//            is.close();
//            baos.close();
//            // 返回字符串
//            final String resultStr = new String(baos.toByteArray());
//
//            callback.onFinished(resultStr);
////            } else {
////                System.out.print(">>> 请求失败:" + connection.getResponseMessage());
////                callback.onFailure(connection.getResponseMessage());
////            }
//
//        }
//        catch (Exception e) {
//            e.printStackTrace();
//            callback.onFailure(e.getMessage());
//        }
//        finally {
//            connection.disconnect();
//        }
//    }


    ////////////////////////////////////////////////////////////////
    // 其它函数
    ////////////////////////////////////////////////////////////////

    /**
     * 从请求的头部获得文件大小
     * @param connection
     * @return
     */
    public String getFileSizeFromHead(HttpURLConnection connection) {
        String contentRange = connection.getHeaderField("Content-Range");
        String crStrArray[] = contentRange.split("/");
        if (crStrArray != null && crStrArray.length >= 2) {
            return crStrArray[1].trim();
        }
        else {
            return null;
        }
    }

}