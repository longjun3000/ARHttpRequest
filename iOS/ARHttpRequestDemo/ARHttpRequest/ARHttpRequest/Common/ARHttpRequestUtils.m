/**
 * @file ARHttpRequestUtils.m
 * @brief 工具类
 * @details
 * @version v1.0
 * @author 创建人：LongJun
 * @date 创建日期：2016-05-30
 * @copyright Copyright (c) 2009-2016 ArwerSoftware All rights reserved.
 *
 */
#import "ARHttpRequestUtils.h"

@implementation ARHttpRequestUtils

/**
 * 根据字典参数，创建一个Get请求的完整URL字符串
 *
 * @param urlString 服务端接口URL，如：http://www.abc.com/aaa
 * @param paramDict 参数字典。
 * @return 返回完整的URL字符串。如：http://www.abc.com/aaa?key1=val1&key2=val2
 */
+ (NSMutableString*)createGetUrlByDictParam:(NSString*)urlString paramDict:(NSMutableDictionary*)paramDict
{
    NSMutableString *fullUrl = [[NSMutableString alloc] init];
    // 遍历参数拼接成完整的带参数的url
    for (NSString *key in paramDict.allKeys) {
        if (fullUrl.length > 0) [fullUrl appendString:@"&"];
        [fullUrl appendFormat:@"%@=%@", key, [paramDict objectForKey:key] ];
    }
    NSString *lastCharStr = [urlString substringFromIndex:(urlString.length-1)];
    if (fullUrl.length > 0 && ![lastCharStr isEqualToString:@"?"]) [fullUrl insertString:@"?" atIndex:0];
    [fullUrl insertString:urlString atIndex:0];
    return fullUrl;
}

/**
 * 编码一个url的最后部分
 *
 * @param urlString 服务端接口URL，如：http://localhost:3000/download/凯文·凯利：Out of Control.pdf
 * @param paramDict 参数字典。
 * @return 返回完整的编码后的URL字符串。如：http://localhost:3000/download/%E5%87%AF%E6%96%87%C2%B7%E5%87%AF%E5%88%A9%EF%BC%9AOut%20of%20Control.pdf
 */
+ (NSString*)encodeUrlLastComponent:(NSString*)urlString
{
    NSRange lastS = [urlString rangeOfString:@"/" options:NSBackwardsSearch];//从字符串后面往前找分隔符“/”
    NSString *urlPrePart = [urlString substringToIndex:lastS.location];
    NSString *encodeFilename = [[urlString lastPathComponent] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *newUrlString = [NSString stringWithFormat:@"%@/%@", urlPrePart, encodeFilename];
    return newUrlString;
}

@end
