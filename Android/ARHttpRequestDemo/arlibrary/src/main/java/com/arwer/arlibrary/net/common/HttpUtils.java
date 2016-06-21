package com.arwer.arlibrary.net.common;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by jun on 16/2/20.
 */
public class HttpUtils {

    /**
     * 根据字典参数，创建一个Get请求的完整URL字符串
     *
     * @param urlString 服务端接口URL，如：http://www.abc.com/aaa
     * @param paramDict 参数字典。
     * @return 返回完整的URL字符串。如：http://www.abc.com/aaa?key1=val1&key2=val2
     */
    public static String createGetUrlByDictParam(String urlString, HashMap<String, String> paramDict) throws UnsupportedEncodingException {

        if (paramDict == null || paramDict.size() < 1) {
//            return URLEncoder.encode(urlString, "UTF-8");
            return urlString;
        }

        StringBuffer fullUrl = new StringBuffer();
        // 遍历参数拼接成完整的带参数的url
        for (Map.Entry entry : paramDict.entrySet()) {
            if (fullUrl.length() > 0) fullUrl.append("&");
            fullUrl.append(entry.getKey());
            fullUrl.append("=");

            String val = entry.getValue().toString().replaceAll(" ", "%20"); //URLEncoder.encode会把空格转换成+号，url格式还是不对，所以这里先转换
            fullUrl.append(URLEncoder.encode(val, "UTF-8"));
        }
        String lastCharStr = urlString.substring(urlString.length() -1);
        if (lastCharStr.length() > 0 && !lastCharStr.equals("?")) fullUrl.insert(0, "?");
        fullUrl.insert(0, urlString);

//        return URLEncoder.encode(fullUrl.toString(), "UTF-8");
        return fullUrl.toString();
    }

    /**
     * 编码一个url的最后部分
     *
     * @param urlString 服务端接口URL，如：http://localhost:3000/download/凯文·凯利：Out of Control.pdf
     * @return 返回完整的编码后的URL字符串。如：http://localhost:3000/download/%E5%87%AF%E6%96%87%C2%B7%E5%87%AF%E5%88%A9%EF%BC%9AOut%20of%20Control.pdf
     */
    public static String encodeUrlLastComponent(String urlString) throws UnsupportedEncodingException {
        int lastSP = urlString.lastIndexOf("/");
        String lastFilename = urlString.substring(lastSP+1);
        String urlPrePart = urlString.substring(0, lastSP+1); //+1即带上/符号
        String encodeFilename = URLEncoder.encode(lastFilename, "UTF-8");
        String newUrlString = urlPrePart + encodeFilename.replaceAll("\\+", "%20");
        return newUrlString;

    }

}
