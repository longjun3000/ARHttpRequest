package com.arwer.arlibrary.net.common;

/**
 * Created by jun on 16/2/23.
 */
public interface IHttpCallback {

    /**
     * 完成网络请求后的回调方法
     * @param respString 服务器返回的响应字符串
     */
    public void onFinished(String respString);

//    /**
//     * 中断请求，中断下载/上传等网络请求响应操作。
//     */
//    public void onCancel();

    /**
     * 请求失败后的回调方法
     * @param errMsg 错误消息
     */
    public void onFailure(String errMsg);

}
