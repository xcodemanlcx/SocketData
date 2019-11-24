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

@end
