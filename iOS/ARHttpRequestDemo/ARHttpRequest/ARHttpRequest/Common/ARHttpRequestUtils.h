/**
 * @file ARHttpRequestUtils.h
 * @brief 工具类
 * @details
 * @version v1.0
 * @author 创建人：LongJun
 * @date 创建日期：2016-05-30
 * @copyright Copyright (c) 2009-2016 ArwerSoftware All rights reserved.
 *
 */
#import <Foundation/Foundation.h>

@interface ARHttpRequestUtils : NSObject

/**
 * 根据字典参数，创建一个Get请求的完整URL字符串
 *
 * @param urlString 服务端接口URL，如：http://www.abc.com/aaa
 * @param paramDict 参数字典。
 * @return 返回完整的URL字符串。如：http://www.abc.com/aaa?key1=val1&key2=val2
 */
+ (NSString*)createGetUrlByDictParam:(NSString*)urlString paramDict:(NSMutableDictionary*)paramDict;

/**
 * 编码一个URL字符串，返回完整的编码后的URL字符串
 *
 * @param urlString 服务端接口URL，如：http://localhost:3000/download/凯文·凯利：Out of Control.pdf
 * @param paramDict 参数字典。
 * @return 返回完整的编码后的URL字符串。如：http://localhost:3000/download/%E5%87%AF%E6%96%87%C2%B7%E5%87%AF%E5%88%A9%EF%BC%9AOut%20of%20Control.pdf
 */
+ (NSString*)encodeUrl:(NSString*)urlString;

/**
 * 编码一个url最后一个“/”之后的部分，返回完整的编码后的URL字符串
 *
 * @param urlString 服务端接口URL，如：http://localhost:3000/download/凯文·凯利：Out of Control.pdf
 * @param paramDict 参数字典。
 * @return 返回完整的编码后的URL字符串。如：http://localhost:3000/download/%E5%87%AF%E6%96%87%C2%B7%E5%87%AF%E5%88%A9%EF%BC%9AOut%20of%20Control.pdf
 */
+ (NSString*)encodeUrlLastComponent:(NSString*)urlString;

/**
 * 编码URL参数字符串为网络URL允许的格式
 *
 * @param urlString 服务端接口URL，如：http://localhost:3000/test/xxx?word=有?号和空 格这样
 * @param paramDict 参数字典。
 * @return 返回编码后URL允许的参数值字符串。如：
 */
+ (NSString*)encodeUrlParamValue:(NSString*)paramValue;

@end
