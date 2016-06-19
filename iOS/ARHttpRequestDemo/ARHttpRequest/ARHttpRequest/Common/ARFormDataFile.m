/**
 * @file ARFormDataFile.m
 * @brief FormData提交表单时，附加的文件对象
 * @details
 * @version v1.0
 * @author 创建人：LongJun
 * @date 创建日期：2015-07-03
 * @copyright Copyright (c) 2009-2016 ArwerSoftware All rights reserved.
 *
 */
#import "ARFormDataFile.h"

@implementation ARFormDataFile

- (instancetype)initWithParams:(NSString*)keyName fileName:(NSString*)fileName filePath:(NSString*)filePath
{
    return [self initWithParams:keyName fileName:fileName filePath:filePath contentType:nil];
}

- (instancetype)initWithParams:(NSString*)keyName fileName:(NSString*)fileName filePath:(NSString*)filePath contentType:(NSString*)contentType
{
    if ((self = [super init])) {
        self.keyName = keyName;
        self.fileName = fileName;
        self.filePath = filePath;
        self.contentType = contentType;
    }
    return self;
}

@end
