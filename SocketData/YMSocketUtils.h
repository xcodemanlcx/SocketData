//
//  YMSocketUtils.h
//  YueMao
//
//  Created by cndw on 16/4/25.
//
//


#import <Foundation/Foundation.h>

// 后面NSString这是运行时能获取到的C语言的类型
static NSString * const TYPE_UINT8   = @"TC";// char是1个字节，8位
static NSString * const TYPE_UINT16   = @"TS";// short是2个字节，16位
static NSString * const TYPE_UINT32   = @"TI";
static NSString * const TYPE_UINT64   = @"TQ";
static NSString * const TYPE_STRING   = @"T@\"NSString\"";
static NSString * const TYPE_ARRAY   = @"T@\"NSArray\"";

@interface YMSocketUtils : NSObject
/**
 *  反转字节序列
 *
 *  @param srcData 原始字节NSData
 *
 *  @return 反转序列后字节NSData
 */
+ (NSData *)dataWithReverse:(NSData *)srcData;

/** 将数值转成字节。编码方式：低位在前，高位在后 */
+ (NSData *)byteFromUInt8:(uint8_t)val;
+ (NSData *)bytesFromUInt16:(uint16_t)val;
+ (NSData *)bytesFromUInt32:(uint32_t)val;
+ (NSData *)bytesFromUInt64:(uint64_t)val;
+ (NSData *)bytesFromValue:(NSInteger)value byteCount:(int)byteCount;
+ (NSData *)bytesFromValue:(NSInteger)value byteCount:(int)byteCount reverse:(BOOL)reverse;

/** 将字节转成数值。解码方式：前序字节为低位，后续字节为高位 */
+ (uint8_t)uint8FromBytes:(NSData *)data;
+ (uint16_t)uint16FromBytes:(NSData *)data;
+ (uint32_t)uint32FromBytes:(NSData *)data;
+ (NSInteger)valueFromBytes:(NSData *)data;
+ (NSInteger)valueFromBytes:(NSData *)data reverse:(BOOL)reverse;

/*** 16进制字符串转换为data。24211D3498FF62AF  -->  <24211D34 98FF62AF> */
+ (NSData *)dataFromHexString:(NSString *)hexString;

/** data转换为16进制。<24211D34 98FF62AF>  -->  24211D3498FF62AF */
+ (NSString *)hexStringFromData:(NSData *)data;

/** hex字符串转换为ascii码。00de0f1a8b24211D3498FF62AF -->  3030646530663161386232343231314433343938464636324146 */
+ (NSString *)asciiStringFromHexString:(NSString *)hexString;

/** ascii码转换为hex字符串。343938464636324146 --> 498FF62AF */
+ (NSString *)hexStringFromASCIIString:(NSString *)asciiString;

@end
