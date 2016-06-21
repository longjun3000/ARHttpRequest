package com.arwer.arlibrary.utils;

import java.io.File;

/**
 * Created by jun on 16/6/14.
 */
public class IOUtils {
    /**
     * 获取本地文件或URL的文件名. 包含后缀
     *
     * @param path 本地文件或URL路径
     * @return 文件名
     */
    public static String getFileName(String path) {
        if (path == null || path.trim().length() < 1) {
            return "";
        }

        int query = path.lastIndexOf('?');
        if (query > 0) {
            path = path.substring(0, query);
        }

        int filenamePos = path.lastIndexOf(File.separatorChar);
        return (filenamePos >= 0) ? path.substring(filenamePos + 1) : path;
    }

    /**
     * 拼接路径片段为一个完整路径
     *
     * @param origPath 原始路径字符串
     * @param pathComponent 要添加的路径片段
     * @return 拼接后的路径字符串
     */
    public static String addFilePathComponent(String origPath, String pathComponent) {
        return new File(origPath, pathComponent).getAbsolutePath();
    }

    /**
     * 重命名文件
     *
     * @param srcPath 原名
     * @param dstPath 重命名后的文件名
     * @return 成功为true
     */
    public static boolean rename(String srcPath, String dstPath) {
        File file = new File(srcPath);
        return file.isFile() && file.renameTo(new File(dstPath));
    }

}
