//
//  SocketDataShareManager.m
//  SocketData
//
//  Created by leichunxiang on 2019/11/24.
//  Copyright © 2019 lcx. All rights reserved.
//

#import "SocketDataShareManager.h"

static NSMutableData *cacheData;
static NSUInteger totalLength;

@implementation SocketDataShareManager

+(instancetype)shareInstance{
    static SocketDataShareManager *shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [SocketDataShareManager new];
        cacheData = [NSMutableData new];
    });
    return shareInstance;
}

//封包
- (NSData *)packingWtihData:(NSData *)data type:(NSUInteger )type{
    
    NSLog(@"封包：serviceID == %lul,contentData string == %@",type,[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    /** 后台约定的编码格式
    NSStringEncoding GBKEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *dataString = @"dataString";
    NSData *bodyData = [dataString dataUsingEncoding:GBKEncoding];
     */
    
    NSMutableData *mData = [NSMutableData new];
    // 1 数据类型
    NSData *typeData = [NSData dataWithBytes:&type length:4];
    [mData appendData:typeData];
    // 2 总长度:4（数据长度容器）+4（服务标识）+数据长度
    NSUInteger dataLength = 4+4+data.length;
    NSData *lengthData = [NSData dataWithBytes:&dataLength length:4];
    [mData appendData:lengthData];
    // 3 最后拼接数据
    [mData appendData:data];
    
    return mData.copy;
}

//拆包
- (void)unpackingData:(NSData *)data 
      socketHandleDataBlock:(void (^)(unsigned int serviceID,NSData *contentData))socketHandleDataBlock{
    // 缓存
    if (data) {
        [cacheData appendData:data];
    }
    //因为服务标识和长度字节占8位，所以大于8才是一个正确的数据包
    while (cacheData.length > 8) {
        // 包总长度（含包头）
        if (totalLength == 0) {
            NSData *totalLengthData = [cacheData subdataWithRange:NSMakeRange(4, 4)];
            [totalLengthData getBytes:&totalLength length:4];
        }
 
        /** 通常iOS比较常用的就是CFSwapInt16BigToHost、CFSwapInt32BigToHost，把大端转换为本机支持的模式，如果本机是大端了则不做任何改变
        unsigned int dataLenInt = CFSwapInt32BigToHost(*(unsigned int*)([totalLengthData bytes]));
         */
        
        if (cacheData.length < totalLength) {
            // 长度不够，继续读取
            break;
        }else {
            //1 截取完整数据包
            NSData *totalData = [cacheData subdataWithRange:NSMakeRange(0, totalLength)];
            //2 包内容
            NSData *contenData = [totalData subdataWithRange:NSMakeRange(8, totalData.length-8)];
            //3 服务标识
            NSData *serviceIDData = [totalData subdataWithRange:NSMakeRange(0, 4)];
            unsigned int serviceID = 0;
            [serviceIDData getBytes:&serviceID length:4];
            //4 数据处理
            if (socketHandleDataBlock) {
                socketHandleDataBlock(serviceID,contenData);
            }
            //5 清除已处理过的包数据,数据长度置0
            [cacheData replaceBytesInRange:NSMakeRange(0, totalLength) withBytes:nil length:0];
            totalLength = 0;
            //6 进入while判断，是否需要继续拼接
        }
    }
}

@end
