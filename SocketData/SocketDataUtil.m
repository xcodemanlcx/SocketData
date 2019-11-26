//
//  SocketDataUtil.m
//  SocketData
//
//  Created by leichunxiang on 2019/11/24.
//  Copyright © 2019 lcx. All rights reserved.
//

#import "SocketDataUtil.h"
#import <objc/runtime.h>
#import "YMSocketUtils.h"

@implementation SocketDataUtil

+(NSMutableData *)dealwithData:(NSMutableData *)mData withObj:(id)obj{
    //异常处理
    if (obj == nil) return mData;
    if(mData == nil) mData = [NSMutableData data];
    if (![mData isKindOfClass:NSMutableData.class]) return nil;
    
    unsigned int numIvars; //成员变量个数
    objc_property_t *propertys = class_copyPropertyList(NSClassFromString([NSString stringWithUTF8String:object_getClassName(obj)]), &numIvars);
    NSString *type = nil;
    NSString *name = nil;
    for (int i = 0; i < numIvars; i++) {
        objc_property_t thisProperty = propertys[i];
        //获取属性名
        name = [NSString stringWithUTF8String:property_getName(thisProperty)];
        NSLog(@"%d.name:%@",i,name);
        
        //获取成员变量的数据类型
        type = [[[NSString stringWithUTF8String:property_getAttributes(thisProperty)] componentsSeparatedByString:@","] objectAtIndex:0];
        NSLog(@"%d.type:%@",i,type);
        
        //获取属性值
        id propertyValue = [obj valueForKey:[(NSString *)name substringFromIndex:0]];
        NSLog(@"%d.propertyValue:%@",i,propertyValue);
        
        NSLog(@"\n");
        
        //类型拼接
        if ([type isEqualToString:TYPE_UINT8]) {
            uint8_t i = [propertyValue charValue];
            [mData appendData:[YMSocketUtils byteFromUInt8:i]];
        }else if([type isEqualToString:TYPE_STRING]){
            // 通过utf-8转为data
            NSData *data = [(NSString*)propertyValue dataUsingEncoding:NSUTF8StringEncoding];
            // 用2个字节拼接字符串的长度拼接在字符串data之前
            [mData appendData:[YMSocketUtils bytesFromUInt16:data.length]];
            // 然后拼接字符串
            [mData appendData:data];
        }else {
            NSLog(@"未知类型");
        }
    }
    
    // 释放C语言的结构体指针
    free(propertys);
    return mData;
}

//封包
+ (NSData *)packingWtihData:(NSData *)data type:(NSInteger )type{
    
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
+ (void)unpackingData:(NSData *)data withCacheData:(NSMutableData *)cacheData socketReadDataBlock:(dispatch_block_t)socketReadDataBlock
      socketHandleDataBlock:(void (^)(unsigned int serviceID,NSData *contentData))socketHandleDataBlock{
    // 缓存
    if (data) {
        [cacheData appendData:data];
    }
    //因为服务标识和长度字节占8位，所以大于8才是一个正确的数据包
    while (cacheData.length > 8) {
        // 包总长度（含包头）
        NSData *totalLengthData = [data subdataWithRange:NSMakeRange(0, 4)];
        unsigned int totalLength = 0;
        [totalLengthData getBytes:&totalLength length:4];
        
        /** 通常iOS比较常用的就是CFSwapInt16BigToHost、CFSwapInt32BigToHost，把大端转换为本机支持的模式，如果本机是大端了则不做任何改变
        unsigned int dataLenInt = CFSwapInt32BigToHost(*(unsigned int*)([totalLengthData bytes]));
         */
        
        if (cacheData.length < totalLength) {
            //缓存包总长度不够， 则继续拼接
            if(socketReadDataBlock){
                socketReadDataBlock();
            }
            break;
        }else {
            //1 截取完整数据包
            NSData *totalData = [cacheData subdataWithRange:NSMakeRange(0, totalLength)];
            //2 包内容
            NSData *contenData = [totalData subdataWithRange:NSMakeRange(8, data.length-8)];
            //3 服务标识
            NSData *serviceIDData = [totalData subdataWithRange:NSMakeRange(0, 4)];
            unsigned int serviceID = 0;
            [serviceIDData getBytes:&serviceID length:4];
            //4 数据处理
            if (socketHandleDataBlock) {
                socketHandleDataBlock(serviceID,contenData);
            }
            //5 清除已处理过的包数据
            [cacheData replaceBytesInRange:NSMakeRange(0, totalLength) withBytes:nil length:0];
            //6 进入while判断，是否需要继续处理多余包数据
        }
    }
    
    //缓存包总长度不够， 则继续拼接
    if(socketReadDataBlock){
        socketReadDataBlock();
    }
    
}


@end
