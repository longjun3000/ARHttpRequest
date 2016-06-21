package com.arwer.arhttprequest;

import android.app.Application;
import android.test.ApplicationTestCase;

import com.arwer.arlibrary.net.common.IHttpCallback;
import com.arwer.arlibrary.net.common.IHttpRequest;
import com.arwer.arlibrary.net.common.IProgressCallback;
import com.arwer.arlibrary.net.urlconnection.HttpRequest;
import com.arwer.arlibrary.threads.TaskQueue;

import java.io.File;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by long on 16/6/21.
 */
public class HttpRequestAppTest extends ApplicationTestCase<Application> {
    public HttpRequestAppTest() {
        super(Application.class);
    }


    private IHttpRequest mHttpRequest;
    public IHttpRequest getHttpRequest() {
        if (mHttpRequest == null) {
            // 创建一个基于HttpURLConnection的适配器
            mHttpRequest = new HttpRequest();
            // 创建一个基于XXXX的适配器
            // ...
        }
        return mHttpRequest;
    }

    // 测试GET
    public void testGet() {
        try {

            String urlString = "http://www.baidu.com";
            getHttpRequest().get(urlString, 0, 1000*15, new IHttpCallback() {
                @Override
                public void onFinished(String respString) {
                    System.out.println(respString);
                }

                @Override
                public void onFailure(String errMsg) {
                    System.out.println(errMsg);
                }
            });
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 测试POST JSON
    public void testPostJson() {
        try {
            String urlString = "http://192.168.1.100:3000/dev/mock/api/48e82320-efff-11e5-b524-8fc3522b1799/checkVersion";
            getHttpRequest().postJson(urlString, 1, "{\"aaa\":\"111\"}", null, 1000*10, new IHttpCallback() {
                @Override
                public void onFinished(String respString) {
                    System.out.println(respString);
                }

                @Override
                public void onFailure(String errMsg) {
                    System.out.println(errMsg);
                }
            });

        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }


    // 测试表单提交
    public void testPostFormData() {
        try {


            // 接口地址
            String urlString = "http://localhost:3000/dev/entity/file-upload";
            // 表单字段列表
            Map<String, String> fields = new HashMap<String, String>();
            fields.put("aaa", "111");
            fields.put("bbb", "222");
            // 文件列表
            // 注：Map中的key即为Web表单中input标签的name
            Map<String, File> files = new HashMap<String, File>();
//            File file1 = new File("/Users/jun/Documents/appcompat_v7.zip"); //1.2M
//            files.put("uploadFiles2", new File("/Users/jun/temp/test_upload_files/db.sqlite")); //20kb
            files.put("uploadFiles3", new File("/Users/jun/temp/无标题.png")); //448kb
//            files.put("uploadFiles4", new File("/Users/jun/temp/test_upload_files/中文test.txt")); //362 byte

            //
            getHttpRequest().postFormData(urlString, 2, null, files, null, 1000 * 100, new IHttpCallback() {
                @Override
                public void onFinished(String respString) {
                    System.out.print(respString);
                    assertTrue("成功：" + respString, true);
                }

                @Override
                public void onFailure(String errMsg) {
                    System.out.print(errMsg);
                    assertFalse("失败：" + errMsg, false);
                }
            });

        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 测试文件下载
    public void testDownloadFile() {
        try {


            // 要下载的文件的地址
            String urlString = "http://localhost:3000/download/凯文·凯利：Out of Control.pdf"; //4M
//            String urlString = "http://localhost:3000/download/eeee.java"; //2K
//    String urlString = "http://localhost:3000/download/Steven Levy：黑客——计算机革命的英雄 (25周年纪念版).mobi";//1.1M
            // 下载的文件最终保存的目录，仅目录
            String destPath = "/Users/jun/temp/down/";
            // 下载的文件临时保存的文件路径，包含文件名的完整路径。（断点续传时使用）
            String tempPath = "/Users/jun/temp/xxx.tmp";

            //
            getHttpRequest().downloadFile(urlString, 3, destPath, tempPath, null, 1000 * 100, new IProgressCallback() {
                @Override
                public void onBegin(int maxVal) {
                    System.out.println("max: " + maxVal);
                }

                @Override
                public void onProgress(int val) {
                    System.out.println("progress val: " + val);
                }

                @Override
                public void onFinished(Object userData) {
                    System.out.println("download finished, dest file:" + userData.toString());
                    assertTrue("成功: dest file:" + userData.toString(), true);
                }

                @Override
                public void onFailure(String errMsg) {
                    System.out.println(errMsg);
                    assertFalse("失败：" + errMsg, false);
                }
            });

        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    boolean isQueueFinished = false;

    // 测试队列
    public void testQueue() {

        try {
            System.out.println(">>> ===== 测试开始 =====");
            isQueueFinished = false;

            IHttpRequest httpRequest = getHttpRequest();
            httpRequest.setQueueIsOn(true);
            httpRequest.setMaxConcurrentThreadCount(1);

            // Request Task1
//            String urlString1 = "http://localhost:3000/dev/mock/api/48e82320-efff-11e5-b524-8fc3522b1799/checkVersion";
            String urlString1 = "http://www.baidu.com";
            int taskTag = 1; //taskTag=taskName，不同任务请使用不同的tag
            httpRequest.get(urlString1, taskTag, 1000*15, new IHttpCallback() {
                @Override
                public void onFinished(String respString) {
                    System.out.println(">>> task1 result: " + respString.substring(0,20) + "...");
                    System.out.println(">>> task1 finished time: " + (new Date().toString()));
                }

                @Override
                public void onFailure(String errMsg) {
                    System.out.println(errMsg);
                }
            });

            // Request Task2
            String urlString2 = "http://192.168.1.100:3000/dev/mock/api/48e82320-efff-11e5-b524-8fc3522b1799/checkVersion";
            taskTag = 2; //taskTag=taskName，不同任务请使用不同的tag
            httpRequest.postJson(urlString2, taskTag, "{\"aaa\":\"111\"}", new IHttpCallback() {
                @Override
                public void onFinished(String respString) {
                    System.out.println(">>> task2 result: " + respString);
                    System.out.println(">>> task2 finished time: " + (new Date().toString()));
                }

                @Override
                public void onFailure(String errMsg) {
                    System.out.println(errMsg);
                }
            });


            // 设置整个队列完成后的回调
            httpRequest.setQueueFinishedCallback(new TaskQueue.IQueueFinishedCallback() {
                @Override
                public void onFinished(Map<String, Object> result) {
                    System.out.println(">>> All task finished, total=" + result.size());
                    for (Map.Entry entry : result.entrySet()) {
//                        System.out.println(">>> TaskQueue finished, taskName=" + entry.getKey() + ", value=" + (entry.getValue()==null ? "null" : entry.getValue().toString()) );
                        System.out.println(">>> taskName=" + entry.getKey() + ", value=" + entry.getValue());
                    }

                    isQueueFinished = true;
                }
            });
            // 开始队列
            httpRequest.queueStart();

            // 阻塞单元测试进程，等待所有任务完成再退出
            while (!isQueueFinished) {
                Thread.sleep(2000);
            }
            System.out.println(">>> ===== 测试结束 =====");
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }


}