package com.arwer.arlibrary;

import android.app.Application;
import android.test.ApplicationTestCase;

import com.arwer.arlibrary.net.common.IHttpCallback;
import com.arwer.arlibrary.net.urlconnection.HttpRequest;

/**
 * <a href="http://d.android.com/tools/testing/testing_android.html">Testing Fundamentals</a>
 */
public class ApplicationTest extends ApplicationTestCase<Application> {
    public ApplicationTest() {
        super(Application.class);
    }

//    public void testGetJSON() {
//        try {
//
//            HttpRequest httpRequest = new HttpRequest("http://10.200.2.211:3000/dev/mock/api/48e82320-efff-11e5-b524-8fc3522b1799/checkVersion");
//            httpRequest.get(1000*15, new IHttpCallback() {
//                @Override
//                public void onFinished(String respString) {
//                    System.out.println(respString);
//                }
//
//                @Override
//                public void onFailure(String errMsg) {
//                    System.out.println(errMsg);
//                }
//            });
//        }
//        catch (Exception e) {
//            e.printStackTrace();
//        }
//    }

    public void testPostJSON() {
        try {
            String urlString = "http://localhost:3000/dev/mock/api/48e82320-efff-11e5-b524-8fc3522b1799/checkVersion";
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.postJson(urlString, 0, "{\"aaa\":\"111\"}", null, 1000*10, new IHttpCallback() {
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
}