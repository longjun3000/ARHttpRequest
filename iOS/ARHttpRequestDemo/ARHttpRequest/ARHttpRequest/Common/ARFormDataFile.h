/**
 * @file ARFormDataFile.h
 * @brief FormData提交表单时，附加的文件对象
 * @details
 * @version v1.0
 * @author 创建人：LongJun
 * @date 创建日期：2015-07-03
 * @copyright Copyright (c) 2009-2016 ArwerSoftware All rights reserved.
 *
 */
#import <Foundation/Foundation.h>

//ARFormDataFile的附加文件
@interface ARFormDataFile : NSObject

@property (nonatomic, retain) NSString *keyName; //Key Name
@property (nonatomic, retain) NSString *filePath; //文件路径
@property (nonatomic, retain) NSString *fileName; //文件名
@property (nonatomic, retain) NSString *contentType; //Content Type

- (instancetype)initWithParams:(NSString*)keyName fileName:(NSString*)fileName filePath:(NSString*)filePath;

- (instancetype)initWithParams:(NSString*)keyName fileName:(NSString*)fileName filePath:(NSString*)filePath contentType:(NSString*)contentType;

@end
