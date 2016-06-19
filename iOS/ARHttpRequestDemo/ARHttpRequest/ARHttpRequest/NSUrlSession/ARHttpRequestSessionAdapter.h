/**
 * @file ARHttpRequestSessionAdapter.h
 * @brief 实现IRLNetwork接口，封装NSURLSession对网络通信的操作
 * @details 注：后台下载部分暂未实现
 * @version v1.0
 * @author 创建人：LongJun
 * @date 创建日期：2016-05-30
 * @copyright Copyright (c) 2009-2016 ArwerSoftware All rights reserved.
 *
 * @date 2016-06-18
 * @details 完善队列部分功能
 * @author LongJun
 *
 * @date 修改日期，例：xxxx年x月xx日
 * @details 修改历史记录：详细说明修改的内容。
 * @author 修改人的名字及单位
 *
 */
#import <Foundation/Foundation.h>
#import "IARHttpRequest.h"

@interface ARHttpRequestSessionAdapter : NSObject
<IARHttpRequest>

@end
