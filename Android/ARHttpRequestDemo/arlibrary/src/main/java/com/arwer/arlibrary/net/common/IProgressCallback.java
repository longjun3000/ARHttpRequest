package com.arwer.arlibrary.net.common;

/**
 * Created by jun on 16/1/15.
 */
public interface IProgressCallback {
    /**
     * 进度开始时
     * @param maxVal 进度的最大值
     */
    public void onBegin(int maxVal);

    /**
     * 进度进行中
     * @param val 进度值
     */
    public void onProgress(int val);

    /**
     * 进度完成后
     * @param userData 用户自定义的值
     */
    public void onFinished(Object userData);

    /**
     * 失败后的回调方法
     * @param errMsg 错误消息
     */
    public void onFailure(String errMsg);
}